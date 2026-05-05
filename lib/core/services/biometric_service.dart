import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  BiometricService._();
  static final BiometricService instance = BiometricService._();

  final LocalAuthentication _auth = LocalAuthentication();

  /// Returns true if the device has biometric hardware and at least one
  /// biometric (fingerprint/face) enrolled.
  Future<bool> isAvailable() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  /// Returns the list of enrolled biometric types.
  Future<List<BiometricType>> getEnrolledBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  /// Returns true if at least one fingerprint/biometric is enrolled.
  Future<bool> isEnrolled() async {
    final types = await getEnrolledBiometrics();
    return types.isNotEmpty;
  }

  /// Triggers the system biometric prompt.
  /// Returns true on success, false on failure/cancel.
  Future<bool> authenticate({String reason = 'Authenticate to continue'}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } on PlatformException catch (e) {
      // NotEnrolled / NotAvailable etc.
      if (e.code == 'NotEnrolled' ||
          e.code == 'NotAvailable' ||
          e.code == 'PasscodeNotSet') {
        return false;
      }
      return false;
    }
  }
}
