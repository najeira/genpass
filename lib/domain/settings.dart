import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'hash_algorithm.dart';

const int _defaultPasswordLength = 10;
const int _defaultPinLength = 4;
const HashAlgorithm _defaultHashAlgorithm = HashAlgorithm.md5;

const String _keyPasswordLength = "passwordLength";
const String _keyPinLength = "pinLength";
const String _keyHashAlgorithm = "hashAlgorithm";

HashAlgorithm _getHashAlgorithm(String name) {
  switch (name) {
    case "md5":
      return HashAlgorithm.md5;
    case "sha512":
      return HashAlgorithm.sha512;
  }
  return null;
}

String _getHashAlgorithmName(HashAlgorithm algo) {
  switch (algo) {
    case HashAlgorithm.md5:
      return "md5";
    case HashAlgorithm.sha512:
      return "sha512";
  }
  return null;
}

class Settings {
  Settings({
    this.passwordLength: _defaultPasswordLength,
    this.pinLength: _defaultPinLength,
    this.hashAlgorithm: _defaultHashAlgorithm,
  });

  final int passwordLength;
  final int pinLength;
  final HashAlgorithm hashAlgorithm;

  static Future<Settings> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int pass = prefs.getInt(_keyPasswordLength) ?? _defaultPasswordLength;
    final int pin = prefs.getInt(_keyPinLength) ?? _defaultPinLength;
    final String algo = prefs.getString(_keyHashAlgorithm);
    final HashAlgorithm hash = _getHashAlgorithm(algo) ?? _defaultHashAlgorithm;
    return Settings(
      passwordLength: pass,
      pinLength: pin,
      hashAlgorithm: hash,
    );
  }

  static Future<void> save(Settings settings) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPasswordLength, settings.passwordLength);
    await prefs.setInt(_keyPinLength, settings.pinLength);
    await prefs.setString(_keyHashAlgorithm, _getHashAlgorithmName(settings.hashAlgorithm));
  }
}
