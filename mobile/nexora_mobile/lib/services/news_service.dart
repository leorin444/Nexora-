import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_article_model.dart';
import 'token_storage.dart';

class NewsService {
  static const String _baseUrl = 'http://10.0.2.2:5000/api';
  final TokenStorage _tokenStorage = TokenStorage();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _tokenStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<NewsArticleModel>> getArticles({int? category, bool topStoriesOnly = false, int limit = 20}) async {
    final query = <String, String>{
      if (category != null) 'category': category.toString(),
      if (topStoriesOnly) 'topStoriesOnly': 'true',
      'limit': limit.toString(),
    };

    final uri = Uri.parse('$_baseUrl/news').replace(queryParameters: query);
    final response = await http.get(uri, headers: await _authHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((e) => NewsArticleModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load news articles: ${response.statusCode}');
  }
}
