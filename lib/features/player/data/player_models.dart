class Player {
  final int idx;
  final String name;
  final int number;
  final String position;
  final String imageUrl;
  final String link;

  Player({
    required this.idx,
    required this.name,
    required this.number,
    required this.position,
    this.imageUrl = '',
    this.link = '',
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      idx: json['idx'] ?? 0,
      name: json['name'] ?? '',
      number: int.tryParse(json['number']?.toString() ?? '0') ?? 0,
      position: json['position'] ?? '',
      imageUrl: json['imgUrl'] ?? '',
      link: json['link'] ?? '',
    );
  }

  String get pcode {
    final match = RegExp(r'pc=(\d+)').firstMatch(link);
    return match?.group(1) ?? '';
  }

  bool get isPlayer {
    final pos = position;
    return pos == '투수' ||
        pos == '포수' ||
        pos == '내야수' ||
        pos == '외야수';
  }
}

class PlayerDetail {
  final Player player;
  final Map<String, dynamic> stats;
  final List<Map<String, dynamic>> yearlyStats;

  PlayerDetail({
    required this.player,
    this.stats = const {},
    this.yearlyStats = const [],
  });
}
