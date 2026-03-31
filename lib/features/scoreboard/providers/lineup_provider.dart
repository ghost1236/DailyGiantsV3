import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/parser.dart' as html_parser;
import '../data/lineup_models.dart';
import '../../../core/constants/api_constants.dart';

final lineupProvider =
    AsyncNotifierProvider<LineupNotifier, LineupData?>(LineupNotifier.new);

class LineupNotifier extends AsyncNotifier<LineupData?> {
  static const _kboBaseUrl = 'https://www.koreabaseball.com';
  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  @override
  Future<LineupData?> build() async {
    return _fetchLineup();
  }

  dynamic _parseResponse(Response response) {
    final data = response.data;
    if (data is String) {
      return json.decode(data);
    }
    return data;
  }

  Future<LineupData?> _fetchLineup() async {
    // 1. Get today's game list
    final today = DateTime.now();
    final dateStr =
        '${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';

    final gameListRes = await _dio.post(
      '$_kboBaseUrl/ws/Main.asmx/GetKboGameList',
      data: 'leId=1&srId=0,1,3,4,5,6,7,9&date=$dateStr',
      options: Options(
        contentType: 'application/x-www-form-urlencoded',
        responseType: ResponseType.plain,
      ),
    );

    final gameListData = _parseResponse(gameListRes) as Map<String, dynamic>;
    final gameList = gameListData['game'] as List;

    // 2. Find Lotte game
    Map<String, dynamic>? lotteGame;
    for (final game in gameList) {
      final awayNm = game['AWAY_NM'] as String? ?? '';
      final homeNm = game['HOME_NM'] as String? ?? '';
      if (awayNm.contains('롯데') || homeNm.contains('롯데')) {
        lotteGame = Map<String, dynamic>.from(game as Map);
        break;
      }
    }

    if (lotteGame == null) return null;

    final gameId = lotteGame['G_ID'] as String;
    final awayTeam = lotteGame['AWAY_NM'] as String;
    final homeTeam = lotteGame['HOME_NM'] as String;
    final awayPitcher = (lotteGame['T_PIT_P_NM'] as String?)?.trim() ?? '';
    final homePitcher = (lotteGame['B_PIT_P_NM'] as String?)?.trim() ?? '';
    final seasonId = lotteGame['SEASON_ID'].toString();
    final srId = lotteGame['SR_ID'].toString();

    // 3. Fetch lineup
    final lineupRes = await _dio.post(
      '$_kboBaseUrl/ws/Schedule.asmx/GetLineUpAnalysis',
      data: 'leId=1&srId=$srId&seasonId=$seasonId&gameId=$gameId',
      options: Options(
        contentType: 'application/x-www-form-urlencoded',
        responseType: ResponseType.plain,
      ),
    );

    final lineupData = _parseResponse(lineupRes) as List;
    if (lineupData.isEmpty) return null;

    // [0] = lineup check, [1] = home team info, [2] = away team info,
    // [3] = home lineup JSON string, [4] = away lineup JSON string
    bool isLineup = false;
    try {
      final checkList = lineupData[0];
      if (checkList is List && checkList.isNotEmpty) {
        final ck = checkList[0]['LINEUP_CK'];
        isLineup = ck == true || ck == 1 || ck == 'true';
      }
    } catch (_) {}

    List<LineupPlayer> homeLineup = [];
    List<LineupPlayer> awayLineup = [];

    if (lineupData.length >= 5) {
      homeLineup = _parseLineupJson(lineupData[3]);
      awayLineup = _parseLineupJson(lineupData[4]);
    }

    // 4. Fetch inning scores from scoreboard HTML
    final inningResult = await _fetchInningScores(awayTeam, homeTeam);

    return LineupData(
      isLineupRegistered: isLineup,
      awayTeam: awayTeam,
      homeTeam: homeTeam,
      awayPitcher: awayPitcher,
      homePitcher: homePitcher,
      awayLineup: awayLineup,
      homeLineup: homeLineup,
      gameTime: (lotteGame['G_TM'] as String?)?.trim() ?? '',
      stadium: (lotteGame['S_NM'] as String?)?.trim() ?? '',
      gameStatus: lotteGame['GAME_STATE_SC']?.toString() ?? '1',
      awayScore: int.tryParse(lotteGame['T_SCORE_CN']?.toString() ?? '') ?? 0,
      homeScore: int.tryParse(lotteGame['B_SCORE_CN']?.toString() ?? '') ?? 0,
      currentInning: lotteGame['GAME_INN_NO'] != null
          ? int.tryParse(lotteGame['GAME_INN_NO'].toString())
          : null,
      awayId: (lotteGame['AWAY_ID'] as String?)?.trim() ?? '',
      homeId: (lotteGame['HOME_ID'] as String?)?.trim() ?? '',
      awayRank: int.tryParse(lotteGame['T_RANK_NO']?.toString() ?? '') ?? 0,
      homeRank: int.tryParse(lotteGame['B_RANK_NO']?.toString() ?? '') ?? 0,
      tvInfo: (lotteGame['TV_IF'] as String?)?.trim() ?? '',
      innings: inningResult.innings,
      awayHits: inningResult.awayHits,
      homeHits: inningResult.homeHits,
      awayErrors: inningResult.awayErrors,
      homeErrors: inningResult.homeErrors,
      awayBases: inningResult.awayBases,
      homeBases: inningResult.homeBases,
    );
  }

  List<LineupPlayer> _parseLineupJson(dynamic data) {
    try {
      String jsonStr;
      if (data is List && data.isNotEmpty) {
        jsonStr = data[0] as String;
      } else if (data is String) {
        jsonStr = data;
      } else {
        return [];
      }

      final parsed = json.decode(jsonStr);
      final rows = parsed['rows'] as List? ?? [];

      return rows.map<LineupPlayer>((row) {
        final cells = row['row'] as List;
        return LineupPlayer(
          order: int.tryParse(cells[0]['Text'] ?? '') ?? 0,
          position: cells[1]['Text'] ?? '',
          name: cells[2]['Text'] ?? '',
          war: cells[3]['Text'] ?? '',
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<_InningResult> _fetchInningScores(
      String awayTeam, String homeTeam) async {
    try {
      final res = await _dio.get(
        ApiConstants.scoreboardUrl,
        options: Options(responseType: ResponseType.plain),
      );
      final doc = html_parser.parse(res.data as String);
      final gameBlocks = doc.querySelectorAll('div.smsScore');

      for (final block in gameBlocks) {
        final teamEls = block.querySelectorAll('.teamT');
        if (teamEls.length < 2) continue;
        final away = teamEls[0].text.trim();
        final home = teamEls[1].text.trim();

        if (away != awayTeam && home != homeTeam) continue;

        // Found the matching game block
        final scoreTable = block.querySelector('table.tScore');
        if (scoreTable == null) return _InningResult.empty();

        final rows = scoreTable.querySelectorAll('tbody tr');
        if (rows.length < 2) return _InningResult.empty();

        final awayCells = rows[0].querySelectorAll('td');
        final homeCells = rows[1].querySelectorAll('td');

        // Last 4 cells are R, H, E, B
        final inningCount =
            awayCells.length >= 4 ? awayCells.length - 4 : 0;

        final innings = <InningData>[];
        for (var i = 0; i < inningCount; i++) {
          final aText = awayCells[i].text.trim();
          final hText = i < homeCells.length ? homeCells[i].text.trim() : '-';
          innings.add(InningData(
            inning: i + 1,
            awayScore: aText,
            homeScore: hText,
          ));
        }

        int awayHits = 0, homeHits = 0;
        int awayErrors = 0, homeErrors = 0;
        int awayBases = 0, homeBases = 0;
        if (awayCells.length >= 4) {
          final len = awayCells.length;
          awayHits = int.tryParse(awayCells[len - 3].text.trim()) ?? 0;
          awayErrors = int.tryParse(awayCells[len - 2].text.trim()) ?? 0;
          awayBases = int.tryParse(awayCells[len - 1].text.trim()) ?? 0;
        }
        if (homeCells.length >= 4) {
          final len = homeCells.length;
          homeHits = int.tryParse(homeCells[len - 3].text.trim()) ?? 0;
          homeErrors = int.tryParse(homeCells[len - 2].text.trim()) ?? 0;
          homeBases = int.tryParse(homeCells[len - 1].text.trim()) ?? 0;
        }

        return _InningResult(
          innings: innings,
          awayHits: awayHits,
          homeHits: homeHits,
          awayErrors: awayErrors,
          homeErrors: homeErrors,
          awayBases: awayBases,
          homeBases: homeBases,
        );
      }
    } catch (_) {}
    return _InningResult.empty();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchLineup);
  }
}

class _InningResult {
  final List<InningData> innings;
  final int awayHits, homeHits;
  final int awayErrors, homeErrors;
  final int awayBases, homeBases;

  _InningResult({
    required this.innings,
    this.awayHits = 0,
    this.homeHits = 0,
    this.awayErrors = 0,
    this.homeErrors = 0,
    this.awayBases = 0,
    this.homeBases = 0,
  });

  factory _InningResult.empty() => _InningResult(innings: []);
}
