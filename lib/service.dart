import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

const int defaultPasswordLength = 10;
const int defaultPinLength = 4;
const HashAlgorithm defaultHashAlgorithm = HashAlgorithm.md5;

const String _keyPasswordLength = "passwordLength";
const String _keyPinLength = "pinLength";
const String _keyHashAlgorithm = "hashAlgorithm";

enum HashAlgorithm {
  md5,
  sha1,
  sha256,
}

HashAlgorithm _getHashAlgorithm(String name) {
  switch (name) {
    case "md5":
      return HashAlgorithm.md5;
    case "sha1":
      return HashAlgorithm.sha1;
    case "sha256":
      return HashAlgorithm.sha256;
  }
  return null;
}

String _getHashAlgorithmName(HashAlgorithm algo) {
  switch (algo) {
    case HashAlgorithm.md5:
      return "md5";
    case HashAlgorithm.sha1:
      return "sha1";
    case HashAlgorithm.sha256:
      return "sha256";
  }
  return null;
}

class Settings {
  final int passwordLength;
  final int pinLength;
  final HashAlgorithm hashAlgorithm;
  
  Settings({
    this.passwordLength: defaultPasswordLength,
    this.pinLength: defaultPinLength,
    this.hashAlgorithm: defaultHashAlgorithm,
  });
  
  static Future<Settings> load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var pass = prefs.getInt(_keyPasswordLength) ?? defaultPasswordLength;
    var pin = prefs.getInt(_keyPinLength) ?? defaultPinLength;
    var algo = prefs.getString(_keyHashAlgorithm);
    HashAlgorithm hash = _getHashAlgorithm(algo) ?? defaultHashAlgorithm;
    return new Settings(
      passwordLength: pass,
      pinLength: pin,
      hashAlgorithm: hash,
    );
  }
  
  static Future<Null> save(Settings settings) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(_keyPasswordLength, settings.passwordLength);
    prefs.setInt(_keyPinLength, settings.pinLength);
    prefs.setString(_keyHashAlgorithm, _getHashAlgorithmName(settings.hashAlgorithm));
    return prefs.commit();
  }
}
