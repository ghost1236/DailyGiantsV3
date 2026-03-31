class TeamRank {
  final int rank;
  final String team;
  final int games;
  final int wins;
  final int losses;
  final int draws;
  final double winRate;
  final double gamesBehind;
  final String streak;
  final String recent;

  TeamRank({
    required this.rank,
    required this.team,
    required this.games,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.winRate,
    required this.gamesBehind,
    this.streak = '',
    this.recent = '',
  });

  factory TeamRank.fromJson(Map<String, dynamic> json) {
    return TeamRank(
      rank: int.tryParse(json['rank']?.toString() ?? '0') ?? 0,
      team: json['teamName'] ?? '',
      games: int.tryParse(json['matchCnt']?.toString() ?? '0') ?? 0,
      wins: int.tryParse(json['win']?.toString() ?? '0') ?? 0,
      losses: int.tryParse(json['lose']?.toString() ?? '0') ?? 0,
      draws: int.tryParse(json['draw']?.toString() ?? '0') ?? 0,
      winRate: double.tryParse(json['odds']?.toString() ?? '0') ?? 0,
      gamesBehind:
          double.tryParse(json['gameBehind']?.toString() ?? '0') ?? 0,
      streak: json['continuum'] ?? '',
      recent: json['recent'] ?? '',
    );
  }

  bool get isLotte => team.contains('롯데');
}

class TeamDiff {
  final int id;
  final String name;
  final String diff; // "승-패-무" or "■" for self

  TeamDiff({required this.id, required this.name, required this.diff});

  factory TeamDiff.fromJson(Map<String, dynamic> json) {
    return TeamDiff(
      id: json['id'] ?? 0,
      name: (json['name'] ?? '').toString().trim(),
      diff: json['diff'] ?? '',
    );
  }

  bool get isSelf => diff == '■';
}

class HitterRank {
  final int rank;
  final String name;
  final double avg;
  final int games;
  final int atBats;
  final int runs;
  final int hits;
  final int homeRuns;
  final int stolenBases;

  HitterRank({
    required this.rank,
    required this.name,
    required this.avg,
    required this.games,
    required this.atBats,
    required this.runs,
    required this.hits,
    required this.homeRuns,
    required this.stolenBases,
  });

  factory HitterRank.fromJson(Map<String, dynamic> json) {
    return HitterRank(
      rank: int.tryParse(json['rank']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      avg: double.tryParse(json['avg']?.toString() ?? '0') ?? 0,
      games: int.tryParse(json['game']?.toString() ?? '0') ?? 0,
      atBats: int.tryParse(json['ab']?.toString() ?? '0') ?? 0,
      runs: int.tryParse(json['r']?.toString() ?? '0') ?? 0,
      hits: int.tryParse(json['h']?.toString() ?? '0') ?? 0,
      homeRuns: int.tryParse(json['hr']?.toString() ?? '0') ?? 0,
      stolenBases: int.tryParse(json['sb']?.toString() ?? '0') ?? 0,
    );
  }
}

class PitcherRank {
  final int rank;
  final String name;
  final double era;
  final int games;
  final int wins;
  final int losses;
  final int saves;
  final int holds;
  final String innings;

  PitcherRank({
    required this.rank,
    required this.name,
    required this.era,
    required this.games,
    required this.wins,
    required this.losses,
    required this.saves,
    required this.holds,
    required this.innings,
  });

  factory PitcherRank.fromJson(Map<String, dynamic> json) {
    return PitcherRank(
      rank: int.tryParse(json['rank']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      era: double.tryParse(json['era']?.toString() ?? '0') ?? 0,
      games: int.tryParse(json['game']?.toString() ?? '0') ?? 0,
      wins: int.tryParse(json['win']?.toString() ?? '0') ?? 0,
      losses: int.tryParse(json['lose']?.toString() ?? '0') ?? 0,
      saves: int.tryParse(json['save']?.toString() ?? '0') ?? 0,
      holds: int.tryParse(json['hold']?.toString() ?? '0') ?? 0,
      innings: json['inning']?.toString() ?? '0',
    );
  }
}
