class BiometricService {
  BiometricService._();
  static final BiometricService instance = BiometricService._();

  /// Returns true if the device has biometric hardware and at least one
  /// biometric (fingerprint/face) enrolled.
  Future<bool> isAvailable() async {
    return false;
  }

  /// Returns the list of enrolled biometric types.
  Future<List<String>> getEnrolledBiometrics() async {
    return const [];
  }

  /// Returns true if at least one fingerprint/biometric is enrolled.
  Future<bool> isEnrolled() async {
    return false;
  }

  /// Biometric auth is disabled. Keep API for existing call sites.
  Future<bool> authenticate({String reason = 'Authenticate to continue'}) async {
    return true;
  }
}
