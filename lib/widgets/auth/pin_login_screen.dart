import 'package:emoapp/services/pin_authentication_service.dart';
import 'package:emoapp/widgets/auth/pin_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

/// Screen for PIN authentication
class PinLoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const PinLoginScreen({
    Key? key,
    required this.onLoginSuccess,
  }) : super(key: key);

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  late PinAuthenticationService _pinService;
  String _inputPin = '';
  bool _isError = false;
  int _attemptCount = 0;
  bool _isLocked = false;

  static const int PIN_LENGTH = 4;
  static const int MAX_ATTEMPTS = 3;

  @override
  void initState() {
    super.initState();
    _pinService = GetIt.instance.get<PinAuthenticationService>();
    _tryBiometricAuthentication();
  }

  /// Try biometric authentication first
  Future<void> _tryBiometricAuthentication() async {
    try {
      final success = await _pinService.authenticateWithBiometrics();
      if (success && mounted) {
        widget.onLoginSuccess();
      }
    } catch (e) {
      debugPrint('Biometric auth error: $e');
      // Fall back to PIN entry
    }
  }

  void _handlePinChanged(String pin) {
    setState(() {
      _inputPin = pin;
      _isError = false;
    });
  }

  Future<void> _handlePinComplete() async {
    final isValid = await _pinService.verifyPin(_inputPin);

    if (isValid) {
      if (mounted) {
        setState(() {
          _isError = false;
          _attemptCount = 0;
        });
      }
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        widget.onLoginSuccess();
      }
    } else {
      setState(() {
        _isError = true;
        _attemptCount++;
        _inputPin = '';

        if (_attemptCount >= MAX_ATTEMPTS) {
          _isLocked = true;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: _isLocked
              ? const Text('Too many failed attempts. Please try again later.')
              : Text(
                  'Invalid PIN. Attempts remaining: ${MAX_ATTEMPTS - _attemptCount}',
                ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: _isError ? Colors.red[600] : Colors.blue[600],
                ),
                const SizedBox(height: 24),
                Text(
                  'Enter PIN',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _isLocked
                      ? 'Too many failed attempts'
                      : 'Enter your 4-digit PIN to continue',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _isError ? Colors.red[600] : Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                if (!_isLocked)
                  PinInputWidget(
                    pinLength: PIN_LENGTH,
                    obscureText: true,
                    onPinChanged: _handlePinChanged,
                    onComplete: _handlePinComplete,
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      border: Border.all(color: Colors.red[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Please try again later',
                      style: TextStyle(color: Colors.red[600]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 24),
                if (_attemptCount > 0 && !_isLocked)
                  Text(
                    'Attempts remaining: ${MAX_ATTEMPTS - _attemptCount}',
                    style: TextStyle(
                      color: Colors.orange[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
