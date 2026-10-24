import '../config/api_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ai_models.dart';
import 'token_storage.dart';

class AIService {
  static const String _baseUrl = ApiConfig.baseUrl;
  final TokenStorage _tokenStorage = TokenStorage();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _tokenStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<AIResponseModel> askAI(String prompt, {String? context}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/ai/ask'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'prompt': prompt,
        'context': context,
      }),
    );

    if (response.statusCode == 200) {
      return AIResponseModel.fromJson(jsonDecode(response.body));
    }
    final err = jsonDecode(response.body);
    throw Exception(err['detail'] ?? 'Failed to query AI');
  }

  Future<CoachResponseModel> getCoachFeedback(String message, {String? situation}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/ai/coach'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'message': message,
        'situation': situation,
      }),
    );

    if (response.statusCode == 200) {
      return CoachResponseModel.fromJson(jsonDecode(response.body));
    }
    final err = jsonDecode(response.body);
    throw Exception(err['detail'] ?? 'Failed to get coach feedback');
  }
}
