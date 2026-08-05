import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keyUserName = 'userName';
  static const String _keyBopNumber = 'bopNumber';
  static const String _keyPalpayNumber = 'palpayNumber';
  static const String _keyJawwalpayNumber = 'jawwalpayNumber';
  static const String _keyPinCode = 'pinCode';
  static const String _keyUseBiometrics = 'useBiometrics';
  static const String _keyIsSetupComplete = 'isSetupComplete';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Profile Identity ---
  static Future<void> saveProfile({
    required String name,
    required String bop,
    required String palpay,
    required String jawwalpay,
  }) async {
    await _prefs.setString(_keyUserName, name);
    await _prefs.setString(_keyBopNumber, bop);
    await _prefs.setString(_keyPalpayNumber, palpay);
    await _prefs.setString(_keyJawwalpayNumber, jawwalpay);
    await _prefs.setBool(_keyIsSetupComplete, true);
  }

  static String get userName => _prefs.getString(_keyUserName) ?? '';
  static String get bopNumber => _prefs.getString(_keyBopNumber) ?? '';
  static String get palpayNumber => _prefs.getString(_keyPalpayNumber) ?? '';
  static String get jawwalpayNumber => _prefs.getString(_keyJawwalpayNumber) ?? '';
  static bool get isSetupComplete => _prefs.getBool(_keyIsSetupComplete) ?? false;

  // --- Security ---
  static Future<void> setPinCode(String pin) async {
    await _prefs.setString(_keyPinCode, pin);
  }

  static String? get pinCode => _prefs.getString(_keyPinCode);

  static Future<void> setUseBiometrics(bool use) async {
    await _prefs.setBool(_keyUseBiometrics, use);
  }

  static bool get useBiometrics => _prefs.getBool(_keyUseBiometrics) ?? false;
}
