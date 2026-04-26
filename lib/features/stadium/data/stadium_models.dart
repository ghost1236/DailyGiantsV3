class Stadium {
  final int id;
  final String name;
  final String team;
  final String address;
  final String? seatMapImg;
  final double? lat;
  final double? lng;

  Stadium({
    required this.id,
    required this.name,
    required this.team,
    this.address = '',
    this.seatMapImg,
    this.lat,
    this.lng,
  });

  bool get isHome => team.contains('롯데');

  factory Stadium.fromJson(Map<String, dynamic> json) {
    return Stadium(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      team: json['team'] ?? '',
      address: json['address'] ?? '',
      seatMapImg: json['seatMapImg'],
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }
}

class StadiumDetail {
  final Stadium stadium;
  final List<StadiumInfo> transport;
  final List<StadiumInfo> parking;
  final List<StadiumInfo> seats;
  final List<StadiumInfo> food;
  final List<StadiumInfo> tips;

  StadiumDetail({
    required this.stadium,
    this.transport = const [],
    this.parking = const [],
    this.seats = const [],
    this.food = const [],
    this.tips = const [],
  });

  factory StadiumDetail.fromJson(Map<String, dynamic> json) {
    return StadiumDetail(
      stadium: Stadium.fromJson(json),
      transport: _parseInfoList(json['transport']),
      parking: _parseInfoList(json['parking']),
      seats: _parseInfoList(json['seats']),
      food: _parseInfoList(json['food']),
      tips: _parseInfoList(json['tips']),
    );
  }

  static List<StadiumInfo> _parseInfoList(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((e) => StadiumInfo.fromJson(e)).toList();
    }
    return [];
  }
}

class StadiumInfo {
  final String title;
  final String content;
  final String? imageUrl;
  final String? link;

  StadiumInfo({
    required this.title,
    required this.content,
    this.imageUrl,
    this.link,
  });

  factory StadiumInfo.fromJson(Map<String, dynamic> json) {
    // 카테고리별 필드명이 다름 → 유연 파싱
    // title: name, type, zone
    final title = json['title']
        ?? json['name']
        ?? json['type']
        ?? json['zone']
        ?? json['category']
        ?? '';

    // content: 여러 필드를 합쳐서 표시
    final parts = <String>[];
    for (final key in ['description', 'content', 'feature', 'menu', 'location']) {
      final v = json[key];
      if (v != null && v.toString().isNotEmpty) parts.add(v.toString());
    }
    // parking: fee, capacity, tip
    if (json['fee'] != null) parts.add('요금: ${json['fee']}');
    if (json['capacity'] != null) parts.add('수용: ${json['capacity']}');
    if (json['tip'] != null) parts.add(json['tip'].toString());
    // seats: viewLevel, price
    if (json['viewLevel'] != null) parts.add('뷰 등급: ${json['viewLevel']}');
    if (json['price'] != null) parts.add('가격: ${json['price']}');

    return StadiumInfo(
      title: title.toString(),
      content: parts.isNotEmpty ? parts.join('\n') : '',
      imageUrl: json['imageUrl'] ?? json['image'],
      link: json['link'] ?? json['url'],
    );
  }
}
