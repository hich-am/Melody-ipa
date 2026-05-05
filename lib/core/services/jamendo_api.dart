import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer';
import '../models/track.dart';

class JamendoApi {
  static const clientId = 'ad40341f';
  static const baseUrl = 'https://api.jamendo.com/v3.0';

  Future<List<Track>> getPopularTracks() async {
    final uri = Uri.parse('$baseUrl/tracks/?client_id=$clientId&format=json&limit=20&order=popularity_total');
    return _fetchTracks(uri);
  }

  Future<List<Track>> getTracksByGenre(String genre) async {
    final uri = Uri.parse('$baseUrl/tracks/?client_id=$clientId&format=json&tags=$genre&limit=20');
    return _fetchTracks(uri);
  }

  Future<List<Track>> searchTracks(String query) async {
    final uri = Uri.parse('$baseUrl/tracks/?client_id=$clientId&format=json&search=$query&limit=20');
    return _fetchTracks(uri);
  }

  Future<List<Track>> _fetchTracks(Uri uri) async {
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List<dynamic>? ?? [];
        return results.map((json) => Track.fromJamendoJson(json as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      log('Jamendo API error: $e');
    }
    return [];
  }
}
