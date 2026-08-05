import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../services/preferences_service.dart';
import 'profile_setup_screen.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  String _pin = '';
  final String _savedPin = PreferencesService.pinCode ?? '';

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    if (!PreferencesService.isSetupComplete) {
      _navigateToNext();
      return;
    }

    if (PreferencesService.useBiometrics) {
      try {
        final bool didAuthenticate = await auth.authenticate(
          localizedReason: 'قم بتأكيد هويتك لفتح التطبيق',
          options: const AuthenticationOptions(
            biometricOnly: false,
            stickyAuth: true,
          ),
        );
        if (didAuthenticate) {
          _navigateToNext();
        }
      } on PlatformException catch (e) {
        // Biometrics failed or not available, fallback to PIN if set
      }
    }
  }

  void _navigateToNext() {
    if (!mounted) return;
    if (PreferencesService.isSetupComplete) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileSetupScreen()));
    }
  }

  void _onNumPress(String num) {
    if (_pin.length < 4) {
      setState(() => _pin += num);
      if (_pin.length == 4) {
        if (_savedPin.isEmpty) {
          // Setting new PIN
          PreferencesService.setPinCode(_pin);
          _navigateToNext();
        } else if (_pin == _savedPin) {
          _navigateToNext();
        } else {
          // Wrong PIN
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرمز السري غير صحيح')));
          setState(() => _pin = '');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If no setup and no PIN, just skip this screen visually
    if (!PreferencesService.isSetupComplete && _savedPin.isEmpty) {
      return const Scaffold(backgroundColor: Color(0xFF0F172A));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: Color(0xFF10B981)),
            const SizedBox(height: 16),
            Text(
              _savedPin.isEmpty ? 'قم بتعيين رمز سري جديد' : 'أدخل الرمز السري',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _pin.length ? const Color(0xFF10B981) : Colors.transparent,
                    border: Border.all(color: const Color(0xFF10B981), width: 2),
                  ),
                );
              }),
            ),
            const SizedBox(height: 64),
            _buildNumPad(),
          ],
        ),
      ),
    );
  }

  Widget _buildNumPad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 1.2,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (var i = 1; i <= 9; i++) _buildNumBtn(i.toString()),
          _buildActionBtn(Icons.fingerprint, () => _checkAuth()),
          _buildNumBtn('0'),
          _buildActionBtn(Icons.backspace_outlined, () {
            if (_pin.isNotEmpty) {
              setState(() => _pin = _pin.substring(0, _pin.length - 1));
            }
          }),
        ],
      ),
    );
  }

  Widget _buildNumBtn(String text) {
    return InkWell(
      onTap: () => _onNumPress(text),
      customBorder: const CircleBorder(),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.05),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: Colors.white54, size: 28),
      ),
    );
  }
}
