import '../config/api_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message_model.dart';
import 'token_storage.dart';

class ChatService {
  static const String _baseUrl = ApiConfig.baseUrl;
  final TokenStorage _tokenStorage = TokenStorage();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _tokenStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<ChatMessageModel>> getMessages({int limit = 50, DateTime? beforeUtc}) async {
    final query = <String, String>{
      'limit': limit.toString(),
      if (beforeUtc != null) 'beforeUtc': beforeUtc.toIso8601String(),
    };

    final uri = Uri.parse('$_baseUrl/chat').replace(queryParameters: query);
    final response = await http.get(uri, headers: await _authHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((e) => ChatMessageModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load chat messages: ${response.statusCode}');
  }

  Future<ChatMessageModel> sendMessage(String content, {String? attachmentUrl, String? attachmentType}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/chat'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'content': content,
        'attachmentUrl': attachmentUrl,
        'attachmentType': attachmentType,
      }),
    );

    if (response.statusCode == 201) {
      return ChatMessageModel.fromJson(jsonDecode(response.body));
    }
    final err = jsonDecode(response.body);
    throw Exception(err['detail'] ?? 'Failed to send message');
  }
}
