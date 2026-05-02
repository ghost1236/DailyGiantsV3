import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/lineup_models.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';

final lineupProvider =
    AsyncNotifierProvider<LineupNotifier, LineupData?>(LineupNotifier.new);

class LineupNotifier extends AsyncNotifier<LineupData?> {
  @override
  Future<LineupData?> build() async {
    return _fetchLineup();
  }

  Future<LineupData?> _fetchLineup() async {
    final client = ref.read(apiClientProvider);
    final response = await client.get(ApiConstants.scoreboard);
    final data = response.data;

    if (data is! Map<String, dynamic> ||
        data['code'] != '0000' ||
        data['awayTeam'] == null) {
      return null;
    }

    final innings = (data['innings'] as List?)
            ?.map((e) => InningData(
                  inning: e['inning'] ?? 0,
                  awayScore: e['awayScore']?.toString() ?? '-',
                  homeScore: e['homeScore']?.toString() ?? '-',
                ))
            .toList() ??
        [];

    final awayLineup = (data['awayLineup'] as List?)
            ?.map((e) => LineupPlayer(
                  order: e['order'] ?? 0,
                  position: e['position'] ?? '',
                  name: e['name'] ?? '',
                  war: e['war']?.toString() ?? '',
                ))
            .toList() ??
        [];

    final homeLineup = (data['homeLineup'] as List?)
            ?.map((e) => LineupPlayer(
                  order: e['order'] ?? 0,
                  position: e['position'] ?? '',
                  name: e['name'] ?? '',
                  war: e['war']?.toString() ?? '',
                ))
            .toList() ??
        [];

    return LineupData(
      isLineupRegistered: data['lineupRegistered'] == true,
      awayTeam: data['awayTeam'] ?? '',
      homeTeam: data['homeTeam'] ?? '',
      awayPitcher: data['awayPitcher'] ?? '',
      homePitcher: data['homePitcher'] ?? '',
      awayLineup: awayLineup,
      homeLineup: homeLineup,
      gameTime: data['gameTime'] ?? '',
      stadium: data['stadium'] ?? '',
      gameStatus: data['gameStatus']?.toString() ?? '0',
      awayScore: data['awayScore'] ?? 0,
      homeScore: data['homeScore'] ?? 0,
      currentInning: data['currentInning'],
      awayId: data['awayId'] ?? '',
      homeId: data['homeId'] ?? '',
      awayRank: data['awayRank'] ?? 0,
      homeRank: data['homeRank'] ?? 0,
      tvInfo: data['tvInfo'] ?? '',
      innings: innings,
      awayHits: data['awayHits'] ?? 0,
      homeHits: data['homeHits'] ?? 0,
      awayErrors: data['awayErrors'] ?? 0,
      homeErrors: data['homeErrors'] ?? 0,
      awayBases: data['awayBases'] ?? 0,
      homeBases: data['homeBases'] ?? 0,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchLineup);
  }
}
