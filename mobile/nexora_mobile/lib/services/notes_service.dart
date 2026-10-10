import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/note_model.dart';
import 'token_storage.dart';

class NotesService {
  static const String _baseUrl = 'http://10.0.2.2:5000/api';
  final TokenStorage _tokenStorage = TokenStorage();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _tokenStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<NoteModel>> getNotes() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/notes'),
      headers: await _authHeaders(),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((j) => NoteModel.fromJson(j)).toList();
    }
    throw Exception('Failed to load notes: ${response.statusCode}');
  }

  Future<NoteModel> createNote({
    required String title,
    required String content,
    bool isPinned = false,
    VisibilityLevel visibility = VisibilityLevel.private,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/notes'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'title': title,
        'content': content,
        'isPinned': isPinned,
        'visibility': visibility.index,
      }),
    );
    if (response.statusCode == 201) {
      return NoteModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create note: ${response.statusCode}');
  }

  Future<void> deleteNote(String id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/notes/$id'),
      headers: await _authHeaders(),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete note: ${response.statusCode}');
    }
  }
}
