import 'package:encrypt/encrypt.dart' as enc;

class EncryptionService {
  // 128-bit key for ultra-fast local offline encryption
  static final _key = enc.Key.fromUtf8('MoneyIDOffline267Palestine2026Key');
  static final _iv = enc.IV.fromLength(16);

  static String encryptPayload(String rawText) {
    final encrypter = enc.Encrypter(enc.AES(_key));
    final encrypted = encrypter.encrypt(rawText, iv: _iv);
    return encrypted.base64;
  }

  static String decryptPayload(String base64Text) {
    try {
      final encrypter = enc.Encrypter(enc.AES(_key));
      return encrypter.decrypt64(base64Text, iv: _iv);
    } catch (e) {
      return base64Text; // Fallback if plain text
    }
  }

  static String encodeUnifiedQR({
    required String name,
    required String bopNumber,
    required String palpayNumber,
    required String jawwalpayNumber,
  }) {
    final raw = 'MONEYID|$name|$bopNumber|$palpayNumber|$jawwalpayNumber';
    return encryptPayload(raw);
  }

  static Map<String, String>? decodeUnifiedQR(String payload) {
    final decoded = decryptPayload(payload);
    final parts = decoded.split('|');
    if (parts.length >= 5 && parts[0] == 'MONEYID') {
      return {
        'name': parts[1],
        'bop': parts[2],
        'palpay': parts[3],
        'jawwal': parts[4],
      };
    }
    return null;
  }
}
