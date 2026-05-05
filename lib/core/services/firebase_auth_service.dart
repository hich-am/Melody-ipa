import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirebaseAuthService {
  FirebaseAuthService._();
  static final FirebaseAuthService instance = FirebaseAuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Current authenticated Firebase user, or null if not logged in.
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─────────────────────────────────────────────────────
  // Sign In
  // ─────────────────────────────────────────────────────
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ─────────────────────────────────────────────────────
  // Sign Up
  // ─────────────────────────────────────────────────────
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime birthDate,
  }) async {
    // Validate age ≥ 13
    final age = _calculateAge(birthDate);
    if (age < 13) {
      throw Exception('You must be at least 13 years old to create an account.');
    }

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = credential.user!.uid;

    // Update display name so screens can show it
    await credential.user!.updateDisplayName('$firstName $lastName');

    // Store user profile in Firestore
    await _db.collection('users').doc(uid).set({
      'firstName': firstName,
      'lastName': lastName,
      'birthDate': birthDate.toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
    });

    return credential;
  }

  // ─────────────────────────────────────────────────────
  // Password Reset
  // ─────────────────────────────────────────────────────
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // ─────────────────────────────────────────────────────
  // Sign Out
  // ─────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ─────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────
  Future<UserModel?> fetchUserModel() async {
    final uid = currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestoreMap(uid, doc.data()!);
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
