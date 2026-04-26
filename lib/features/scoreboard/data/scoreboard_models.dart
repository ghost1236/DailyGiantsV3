class GameScore {
  final String gameDate;
  final String time;
  final String awayTeam;
  final String homeTeam;
  final int awayScore;
  final int homeScore;
  final String status;
  final String stadium;
  final String gameKey;
  final List<InningScore> innings;
  final int awayHits;
  final int homeHits;
  final int awayErrors;
  final int homeErrors;
  final int awayBases;
  final int homeBases;
  final int awayRank;
  final int homeRank;
  final String? awayPitcher;
  final String? homePitcher;
  final int? currentInning;
  final String? tvInfo;

  GameScore({
    required this.gameDate,
    required this.time,
    required this.awayTeam,
    required this.homeTeam,
    required this.awayScore,
    required this.homeScore,
    required this.status,
    required this.stadium,
    this.gameKey = '',
    this.innings = const [],
    this.awayHits = 0,
    this.homeHits = 0,
    this.awayErrors = 0,
    this.homeErrors = 0,
    this.awayBases = 0,
    this.homeBases = 0,
    this.awayRank = 0,
    this.homeRank = 0,
    this.awayPitcher,
    this.homePitcher,
    this.currentInning,
    this.tvInfo,
  });

  factory GameScore.fromJson(Map<String, dynamic> json) {
    // gameStatus: "0"=경기전, "1"=경기중, "2"=종료, "3"=취소
    final statusMap = {
      '0': '경기전',
      '1': '경기중',
      '2': '종료',
      '3': '취소',
    };
    final statusCode = json['gameStatus']?.toString() ?? '0';

    final inningsList = (json['innings'] as List?)
            ?.map((e) => InningScore.fromJson(e))
            .toList() ??
        [];

    return GameScore(
      gameDate: json['gameDate'] ?? DateTime.now().toString().substring(0, 10),
      time: json['gameTime'] ?? '',
      awayTeam: json['awayTeam'] ?? '',
      homeTeam: json['homeTeam'] ?? '',
      awayScore: json['awayScore'] ?? 0,
      homeScore: json['homeScore'] ?? 0,
      status: statusMap[statusCode] ?? '경기전',
      stadium: json['stadium'] ?? '',
      gameKey: json['gameKey'] ?? '',
      innings: inningsList,
      awayHits: json['awayHits'] ?? 0,
      homeHits: json['homeHits'] ?? 0,
      awayErrors: json['awayErrors'] ?? 0,
      homeErrors: json['homeErrors'] ?? 0,
      awayBases: json['awayBases'] ?? 0,
      homeBases: json['homeBases'] ?? 0,
      awayRank: json['awayRank'] ?? 0,
      homeRank: json['homeRank'] ?? 0,
      awayPitcher: json['awayPitcher'],
      homePitcher: json['homePitcher'],
      currentInning: json['currentInning'],
      tvInfo: json['tvInfo'],
    );
  }

  bool get isLotteGame =>
      awayTeam.contains('롯데') || homeTeam.contains('롯데');

  bool get isLive => status == '경기중';
  bool get isFinished => status == '종료';
  bool get isScheduled => status == '경기전';
}

class InningScore {
  final int inning;
  final int? awayScore;
  final int? homeScore;

  InningScore({
    required this.inning,
    this.awayScore,
    this.homeScore,
  });

  factory InningScore.fromJson(Map<String, dynamic> json) {
    return InningScore(
      inning: json['inning'] ?? 0,
      awayScore: _parseScore(json['awayScore']),
      homeScore: _parseScore(json['homeScore']),
    );
  }

  static int? _parseScore(dynamic value) {
    if (value == null || value == '-' || value == '') return null;
    return int.tryParse(value.toString());
  }
}
