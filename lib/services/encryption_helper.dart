
import 'package:encrypt/encrypt.dart' as encrypt;
class EncryptionHelper {
  static final key = encrypt.Key.fromLength(32);
  static final iv = encrypt.IV.fromLength(16);
  static final encrypter = encrypt.Encrypter(encrypt.AES(key));

  static String encryptText(String text) {
    return encrypter.encrypt(text, iv: iv).base64;
  }

  static String decryptText(String text) {
    return encrypter.decrypt64(text, iv: iv);
  }
}