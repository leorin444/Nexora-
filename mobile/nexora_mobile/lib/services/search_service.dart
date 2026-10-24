import '../config/api_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/search_models.dart';
import 'token_storage.dart';

class SearchService {
  static const String _baseUrl = ApiConfig.baseUrl;
  final TokenStorage _tokenStorage = TokenStorage();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _tokenStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<UnifiedSearchResponseModel> search(String query, {int limit = 5}) async {
    final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: {
      'q': query,
      'limit': limit.toString(),
    });

    final response = await http.get(uri, headers: await _authHeaders());

    if (response.statusCode == 200) {
      return UnifiedSearchResponseModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Search request failed: ${response.statusCode}');
  }
}
