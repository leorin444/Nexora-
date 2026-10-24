import '../config/api_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_models.dart';
import 'token_storage.dart';

class AuthService {
  // Localhost endpoint for emulator/dev - update as needed for target platform
  static const String baseUrl = ApiConfig.baseUrl; 
  final TokenStorage _tokenStorage = TokenStorage();

  Future<AuthResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final authData = AuthResponse.fromJson(jsonDecode(response.body));
      await _tokenStorage.saveTokens(
        accessToken: authData.accessToken,
        refreshToken: authData.refreshToken,
      );
      return authData;
    } else {
      final errorJson = jsonDecode(response.body);
      throw Exception(errorJson['detail'] ?? errorJson['title'] ?? 'Login failed');
    }
  }

  Future<AuthResponse> register(String email, String password, String firstName, String lastName) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
      }),
    );

    if (response.statusCode == 200) {
      final authData = AuthResponse.fromJson(jsonDecode(response.body));
      await _tokenStorage.saveTokens(
        accessToken: authData.accessToken,
        refreshToken: authData.refreshToken,
      );
      return authData;
    } else {
      final errorJson = jsonDecode(response.body);
      throw Exception(errorJson['detail'] ?? errorJson['title'] ?? 'Registration failed');
    }
  }

  Future<UserProfile?> getCurrentUser() async {
    final token = await _tokenStorage.getAccessToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      final refreshed = await refreshToken();
      if (refreshed) {
        return getCurrentUser();
      }
    }
    return null;
  }

  Future<bool> refreshToken() async {
    final accessToken = await _tokenStorage.getAccessToken();
    final refreshToken = await _tokenStorage.getRefreshToken();

    if (accessToken == null || refreshToken == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      }),
    );

    if (response.statusCode == 200) {
      final authData = AuthResponse.fromJson(jsonDecode(response.body));
      await _tokenStorage.saveTokens(
        accessToken: authData.accessToken,
        refreshToken: authData.refreshToken,
      );
      return true;
    } else {
      await _tokenStorage.clearTokens();
      return false;
    }
  }

  Future<void> logout() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    final accessToken = await _tokenStorage.getAccessToken();

    if (refreshToken != null && accessToken != null) {
      try {
        await http.post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({'refreshToken': refreshToken}),
        );
      } catch (_) {}
    }
    await _tokenStorage.clearTokens();
  }
}
