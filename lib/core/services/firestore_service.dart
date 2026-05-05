import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/track.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─────────────────────────────────────────────────────
  // Favorites
  // ─────────────────────────────────────────────────────

  /// Real-time stream of the user's favorites.
  Stream<List<Track>> favoritesStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Track.fromFirestoreMap(doc.id, doc.data()))
            .toList());
  }

  /// Add a track to favorites.
  Future<void> addFavorite(String uid, Track track) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(track.id)
        .set(track.toMap());
  }

  /// Remove a track from favorites.
  Future<void> removeFavorite(String uid, String trackId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(trackId)
        .delete();
  }

  /// Check if a track is in favorites (one-time read).
  Future<bool> isFavorite(String uid, String trackId) async {
    final doc = await _db
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(trackId)
        .get();
    return doc.exists;
  }

  /// Get favorites as a one-time fetch.
  Future<List<Track>> getFavorites(String uid) async {
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .get();
    return snap.docs
        .map((doc) => Track.fromFirestoreMap(doc.id, doc.data()))
        .toList();
  }
}
