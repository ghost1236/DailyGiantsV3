class LineupData {
  final bool isLineupRegistered;
  final String awayTeam;
  final String homeTeam;
  final String awayPitcher;
  final String homePitcher;
  final List<LineupPlayer> awayLineup;
  final List<LineupPlayer> homeLineup;

  // Game info
  final String gameTime;
  final String stadium;
  final String gameStatus; // 1: 경기전, 2: 경기중, 3: 종료
  final int awayScore;
  final int homeScore;
  final int? currentInning;
  final String awayId;
  final String homeId;
  final int awayRank;
  final int homeRank;
  final String tvInfo;
  final List<InningData> innings;
  final int awayHits;
  final int homeHits;
  final int awayErrors;
  final int homeErrors;
  final int awayBases;
  final int homeBases;

  LineupData({
    required this.isLineupRegistered,
    required this.awayTeam,
    required this.homeTeam,
    required this.awayPitcher,
    required this.homePitcher,
    required this.awayLineup,
    required this.homeLineup,
    required this.gameTime,
    required this.stadium,
    required this.gameStatus,
    required this.awayScore,
    required this.homeScore,
    this.currentInning,
    required this.awayId,
    required this.homeId,
    required this.awayRank,
    required this.homeRank,
    required this.tvInfo,
    this.innings = const [],
    this.awayHits = 0,
    this.homeHits = 0,
    this.awayErrors = 0,
    this.homeErrors = 0,
    this.awayBases = 0,
    this.homeBases = 0,
  });

  String get statusText {
    switch (gameStatus) {
      case '2':
        return currentInning != null ? '$currentInning회' : '경기중';
      case '3':
        return '종료';
      default:
        return '경기전';
    }
  }

  bool get isLive => gameStatus == '2';
  bool get isFinished => gameStatus == '3';
  bool get isScheduled => gameStatus == '1';
}

class InningData {
  final int inning;
  final String awayScore;
  final String homeScore;

  InningData({
    required this.inning,
    required this.awayScore,
    required this.homeScore,
  });
}

class LineupPlayer {
  final int order;
  final String position;
  final String name;
  final String war;

  LineupPlayer({
    required this.order,
    required this.position,
    required this.name,
    required this.war,
  });
}
