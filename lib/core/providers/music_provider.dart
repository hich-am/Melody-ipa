import 'package:flutter/foundation.dart';
import '../models/track.dart';
import '../services/jamendo_api.dart';

class MusicProvider extends ChangeNotifier {
  final JamendoApi _api = JamendoApi();
  
  List<Track> currentTracks = [];
  bool isLoading = false;
  Track? currentTrack;

  Future<void> loadPopularTracks() async {
    _setLoading(true);
    currentTracks = await _api.getPopularTracks();
    _setLoading(false);
  }

  Future<void> loadGenreTracks(String genre) async {
    _setLoading(true);
    currentTracks = await _api.getTracksByGenre(genre);
    _setLoading(false);
  }

  Future<void> searchTracks(String query) async {
    if (query.trim().isEmpty) return;
    _setLoading(true);
    currentTracks = await _api.searchTracks(query);
    _setLoading(false);
  }

  void setCurrentTrack(Track track) {
    currentTrack = track;
    notifyListeners();
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
