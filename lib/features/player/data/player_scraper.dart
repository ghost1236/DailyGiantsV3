import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;

class PlayerDetailInfo {
  final String name;
  final String number;
  final String position;
  final String imageUrl;
  final String birthDate;
  final String height;
  final String weight;
  final String throwBat;
  final String career;
  final String joinYear;

  PlayerDetailInfo({
    required this.name,
    this.number = '',
    this.position = '',
    this.imageUrl = '',
    this.birthDate = '',
    this.height = '',
    this.weight = '',
    this.throwBat = '',
    this.career = '',
    this.joinYear = '',
  });
}

class PlayerScraper {
  static final _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'User-Agent': 'Mozilla/5.0 (Linux; Android 10)'},
    ),
  );

  static Future<PlayerDetailInfo> fetchDetail(String link) async {
    final url = 'https://www.giantsclub.com/html/$link';
    final response = await _dio.get(url,
        options: Options(responseType: ResponseType.plain));
    final doc = html_parser.parse(response.data);

    // 이미지
    String imageUrl = '';
    final imgEl = doc.querySelector('.roster_img img');
    if (imgEl != null) {
      imageUrl = imgEl.attributes['src'] ?? '';
    }

    // 이름, 등번호
    String name = '';
    String number = '';
    final nameEl = doc.querySelector('.roster_txt .name');
    if (nameEl != null) {
      final nbEl = nameEl.querySelector('.nb');
      number = nbEl?.text.trim() ?? '';
      name = nameEl.text.replaceAll(number, '').trim();
    }

    // 포지션
    String position = '';
    final posEl = doc.querySelector('.roster_txt .pos');
    if (posEl != null) {
      position = posEl.text.trim();
    }

    // dl > dt/dd 에서 상세 정보 추출
    String birthDate = '';
    String height = '';
    String weight = '';
    String throwBat = '';
    String career = '';
    String joinYear = '';

    final dtElements = doc.querySelectorAll('.roster_txt dl dt');
    final ddElements = doc.querySelectorAll('.roster_txt dl dd');

    for (int i = 0; i < dtElements.length && i < ddElements.length; i++) {
      final label = dtElements[i].text.trim();
      final value = ddElements[i].text.trim();

      if (label.contains('생년월일')) birthDate = value;
      if (label.contains('신장')) height = value;
      if (label.contains('체중')) weight = value;
      if (label.contains('투타')) throwBat = value;
      if (label.contains('경력') || label.contains('출신')) career = value;
      if (label.contains('입단')) joinYear = value;
    }

    return PlayerDetailInfo(
      name: name,
      number: number,
      position: position,
      imageUrl: imageUrl,
      birthDate: birthDate,
      height: height,
      weight: weight,
      throwBat: throwBat,
      career: career,
      joinYear: joinYear,
    );
  }
}
