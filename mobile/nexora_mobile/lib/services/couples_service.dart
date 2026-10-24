import '../config/api_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/couple_model.dart';
import 'token_storage.dart';

class CouplesService {
  static const String _baseUrl = ApiConfig.baseUrl;
  final TokenStorage _tokenStorage = TokenStorage();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _tokenStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<CoupleModel?> getCurrentCouple() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/couples/current'),
      headers: await _authHeaders(),
    );

    if (response.statusCode == 200) {
      return CoupleModel.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    }
    throw Exception('Failed to load couple: ${response.statusCode}');
  }

  Future<CoupleInvitationModel> createInvitation() async {
    final response = await http.post(
      Uri.parse('$_baseUrl/couples/invitations'),
      headers: await _authHeaders(),
    );

    if (response.statusCode == 201) {
      return CoupleInvitationModel.fromJson(jsonDecode(response.body));
    }
    final err = jsonDecode(response.body);
    throw Exception(err['detail'] ?? 'Failed to generate invitation');
  }

  Future<CoupleModel> acceptInvitation(String code) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/couples/invitations/accept'),
      headers: await _authHeaders(),
      body: jsonEncode({'invitationCode': code.trim().toUpperCase()}),
    );

    if (response.statusCode == 200) {
      return CoupleModel.fromJson(jsonDecode(response.body));
    }
    final err = jsonDecode(response.body);
    throw Exception(err['detail'] ?? 'Failed to accept invitation');
  }
}
