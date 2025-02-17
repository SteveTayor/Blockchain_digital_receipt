import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:shared_preferences/shared_preferences.dart';

class EncryptionHelper {
  static late encrypt.Key key;
  static late encrypt.IV iv;
  static late encrypt.Encrypter encrypter;

  // Initialize key and IV once
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final storedKey = prefs.getString('encryption_key');
    final storedIV = prefs.getString('encryption_iv');

    if (storedKey != null && storedIV != null) {
      key = encrypt.Key.fromBase64(storedKey);
      iv = encrypt.IV.fromBase64(storedIV);
    } else {
      key = encrypt.Key.fromSecureRandom(32);  // Generate only once
      iv = encrypt.IV.fromSecureRandom(16);

      await prefs.setString('encryption_key', key.base64);
      await prefs.setString('encryption_iv', iv.base64);
    }

    encrypter = encrypt.Encrypter(encrypt.AES(key));
  }

  static String encryptText(String text) {
    return encrypter.encrypt(text, iv: iv).base64;
  }

  static String decryptText(String text) {
    return encrypter.decrypt64(text, iv: iv);
  }
}
