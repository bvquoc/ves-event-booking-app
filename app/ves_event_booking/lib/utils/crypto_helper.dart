import 'package:crypto/crypto.dart';
import 'dart:convert';

class CryptoHelper {
  static String hmacSha256(String key, String data) {
    final hmac = Hmac(sha256, utf8.encode(key));
    final digest = hmac.convert(utf8.encode(data));
    return digest.toString();
  }
}
