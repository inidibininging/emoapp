import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing PIN authentication
class PinAuthenticationService {
  static const String _pinKey = 'app_pin';
  static const String _pinSetKey = 'app_pin_set';

  final LocalAuthentication _localAuth = LocalAuthentication();
  late SharedPreferences _prefs;

  /// Initialize the service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Check if PIN is set
  Future<bool> isPinSet() async {
    return _prefs.getBool(_pinSetKey) ?? false;
  }

  /// Set the PIN (first time setup)
  Future<void> setPin(String pin) async {
    await _prefs.setString(_pinKey, pin);
    await _prefs.setBool(_pinSetKey, true);
  }

  /// Update the PIN
  Future<void> updatePin(String newPin) async {
    await _prefs.setString(_pinKey, newPin);
  }

  /// Verify the PIN
  Future<bool> verifyPin(String pin) async {
    final storedPin = _prefs.getString(_pinKey);
    return storedPin == pin;
  }

  /// Reset PIN (clear it)
  Future<void> resetPin() async {
    await _prefs.remove(_pinKey);
    await _prefs.setBool(_pinSetKey, false);
  }

  /// Authenticate using biometrics if available
  Future<bool> authenticateWithBiometrics() async {
    try {
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final bool canAuthenticate = canCheckBiometrics;

      if (!canAuthenticate) {
        return false;
      }

      final bool result = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access the app',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      return result;
    } catch (e) {
      debugPrint('Error during biometric authentication: $e');
      return false;
    }
  }

  /// Get the stored PIN (for internal use only)
  String? getStoredPin() {
    return _prefs.getString(_pinKey);
  }
}
