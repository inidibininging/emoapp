import 'package:emoapp/services/pin_authentication_service.dart';
import 'package:emoapp/widgets/auth/pin_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

/// Screen for first-time PIN setup
class PinSetupScreen extends StatefulWidget {
  final VoidCallback onSetupComplete;

  const PinSetupScreen({
    Key? key,
    required this.onSetupComplete,
  }) : super(key: key);

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  late PinAuthenticationService _pinService;
  String? _firstPin;
  String _currentPin = '';
  bool _isConfirming = false;
  bool _pinsMatch = true;

  static const int PIN_LENGTH = 4;

  @override
  void initState() {
    super.initState();
    _pinService = GetIt.instance.get<PinAuthenticationService>();
  }

  void _handlePinChanged(String pin) {
    setState(() {
      _currentPin = pin;
    });
  }

  void _handlePinComplete() async {
    if (!_isConfirming) {
      // First PIN entry
      setState(() {
        _firstPin = _currentPin;
        _isConfirming = true;
        _currentPin = '';
      });
    } else {
      // Confirmation PIN entry
      if (_currentPin == _firstPin) {
        // PINs match, save and complete
        await _pinService.setPin(_firstPin!);
        if (mounted) {
          widget.onSetupComplete();
        }
      } else {
        // PINs don't match, show error and reset
        setState(() {
          _pinsMatch = false;
          _currentPin = '';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PINs do not match. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );

        // Reset after showing error
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _isConfirming = false;
              _firstPin = null;
              _pinsMatch = true;
            });
          }
        });
      }
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
                  color: Colors.blue[600],
                ),
                const SizedBox(height: 24),
                Text(
                  _isConfirming ? 'Confirm PIN' : 'Set Your PIN',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _isConfirming
                      ? 'Re-enter your PIN to confirm'
                      : 'Create a 4-digit PIN to secure your app',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                PinInputWidget(
                  pinLength: PIN_LENGTH,
                  obscureText: true,
                  onPinChanged: _handlePinChanged,
                  onComplete: _handlePinComplete,
                ),
                const SizedBox(height: 24),
                if (!_pinsMatch)
                  Text(
                    'PIN does not match. Please try again.',
                    style: TextStyle(
                      color: Colors.red[600],
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
