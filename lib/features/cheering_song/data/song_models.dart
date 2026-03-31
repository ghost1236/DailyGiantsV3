class CheeringSong {
  final int id;
  final String title;
  final String lyrics;
  final String url;
  final String? url2;
  final String? lyrics2;
  final String? url3;
  final String? lyrics3;
  final String? number;
  final String? thumbnail;
  final String isPlaying;
  final String? sub;
  final String? youtubeUrl;

  CheeringSong({
    required this.id,
    required this.title,
    this.lyrics = '',
    this.url = '',
    this.url2,
    this.lyrics2,
    this.url3,
    this.lyrics3,
    this.number,
    this.thumbnail,
    this.isPlaying = 'N',
    this.sub,
    this.youtubeUrl,
  });

  factory CheeringSong.fromJson(Map<String, dynamic> json) {
    return CheeringSong(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      lyrics: json['lyrics'] ?? '',
      url: json['url'] ?? '',
      url2: json['url2'],
      lyrics2: json['lyrics2'],
      url3: json['url3'],
      lyrics3: json['lyrics3'],
      number: json['number']?.toString(),
      thumbnail: json['thumbnail'],
      isPlaying: json['isPlaying'] ?? 'N',
      sub: json['sub'],
    );
  }

  String get audioUrl {
    if (url.startsWith('http')) return url;
    return 'http://smiling.kr:5580/cheersong$url';
  }
}
