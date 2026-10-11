import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/calendar_event_model.dart';
import 'token_storage.dart';

class CalendarService {
  static const String _baseUrl = 'http://10.0.2.2:5000/api';
  final TokenStorage _tokenStorage = TokenStorage();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _tokenStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<CalendarEventModel>> getEvents({DateTime? startUtc, DateTime? endUtc}) async {
    final start = startUtc ?? DateTime.now().toUtc().subtract(const Duration(days: 7));
    final end = endUtc ?? DateTime.now().toUtc().add(const Duration(days: 30));

    final uri = Uri.parse('$_baseUrl/calendar').replace(queryParameters: {
      'startUtc': start.toIso8601String(),
      'endUtc': end.toIso8601String(),
    });

    final response = await http.get(uri, headers: await _authHeaders());
    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((e) => CalendarEventModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load events: ${response.statusCode}');
  }

  Future<CalendarEventModel> createEvent({
    required String title,
    String? description,
    String? location,
    required DateTime startTimeUtc,
    required DateTime endTimeUtc,
    bool isAllDay = false,
    int visibility = 0,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/calendar'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'title': title,
        'description': description,
        'location': location,
        'startTimeUtc': startTimeUtc.toIso8601String(),
        'endTimeUtc': endTimeUtc.toIso8601String(),
        'isAllDay': isAllDay,
        'visibility': visibility,
      }),
    );

    if (response.statusCode == 201) {
      return CalendarEventModel.fromJson(jsonDecode(response.body));
    }
    final err = jsonDecode(response.body);
    throw Exception(err['detail'] ?? 'Failed to create event');
  }
}
