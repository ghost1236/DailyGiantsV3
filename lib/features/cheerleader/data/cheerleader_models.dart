class Cheerleader {
  final int idx;
  final String name;
  final String pos;
  final String stature;
  final List<String> imageUrls;

  static const String _baseUrl = 'https://www.giantsclub.com/html';

  Cheerleader({
    required this.idx,
    required this.name,
    this.pos = '',
    this.stature = '',
    this.imageUrls = const [],
  });

  factory Cheerleader.fromJson(Map<String, dynamic> json) {
    final imgList = json['imgList'] as List? ?? [];
    final urls = imgList.map((e) {
      final rawUrl = (e as Map<String, dynamic>)['imgUrl'] as String? ?? '';
      if (rawUrl.startsWith('http')) return rawUrl;
      // "./_Img/fan/..." → "/_Img/fan/..."
      final path = rawUrl.startsWith('.') ? rawUrl.substring(1) : rawUrl;
      return '$_baseUrl$path';
    }).toList();

    return Cheerleader(
      idx: json['idx'] ?? 0,
      name: json['name'] ?? '',
      pos: json['pos'] ?? '',
      stature: json['stature'] ?? '',
      imageUrls: List<String>.from(urls),
    );
  }

  String get mainImageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';
}
