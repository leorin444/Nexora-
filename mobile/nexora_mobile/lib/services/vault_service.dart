import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vault_item_model.dart';
import 'token_storage.dart';

class VaultService {
  static const String _baseUrl = 'http://10.0.2.2:5000/api';
  final TokenStorage _tokenStorage = TokenStorage();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _tokenStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<VaultItemModel>> getItems({String? search}) async {
    final uri = Uri.parse('$_baseUrl/vault').replace(
      queryParameters: search != null && search.isNotEmpty ? {'search': search} : null,
    );

    final response = await http.get(uri, headers: await _authHeaders());
    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((e) => VaultItemModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load vault items: ${response.statusCode}');
  }

  Future<VaultItemModel> createItem({
    required String title,
    String? description,
    int itemType = 0,
    required String encryptedPayload,
    String? tags,
    int visibility = 0,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/vault'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'title': title,
        'description': description,
        'itemType': itemType,
        'encryptedPayload': encryptedPayload,
        'tags': tags,
        'visibility': visibility,
      }),
    );

    if (response.statusCode == 201) {
      return VaultItemModel.fromJson(jsonDecode(response.body));
    }
    final err = jsonDecode(response.body);
    throw Exception(err['detail'] ?? 'Failed to create vault item');
  }
}
