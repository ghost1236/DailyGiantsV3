class GameScore {
  final String gameDate;
  final String time;
  final String awayTeam;
  final String homeTeam;
  final int awayScore;
  final int homeScore;
  final String status; // 경기전, 경기중, 종료
  final String stadium;
  final String gameKey;
  final List<InningScore> innings;
  final int awayHits;
  final int homeHits;
  final int awayErrors;
  final int homeErrors;
  final int awayBases;
  final int homeBases;

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
  });

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
}
