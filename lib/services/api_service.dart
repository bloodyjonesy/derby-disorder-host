import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

/// API service for HTTP requests to the game server
class ApiService {
  final String baseUrl;
  final http.Client _client;

  ApiService({String? baseUrl})
      : baseUrl = baseUrl ?? AppConstants.defaultSocketUrl,
        _client = http.Client();

  /// Create a new room and return the room code
  Future<String?> createRoom() async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/rooms'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data['roomCode'] as String?;
      } else {
        throw Exception('Failed to create room: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get room information
  Future<Map<String, dynamic>?> getRoom(String roomCode) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/rooms/$roomCode'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to get room: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
