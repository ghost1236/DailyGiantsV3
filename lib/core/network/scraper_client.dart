import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';

class ScraperClient {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  Future<Document> fetchHtml(String url) async {
    final response = await _dio.get(url,
        options: Options(responseType: ResponseType.plain));
    return html_parser.parse(response.data);
  }
}
