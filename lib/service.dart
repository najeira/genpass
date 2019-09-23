import 'dart:async';
import 'dart:collection';

import 'package:shared_preferences/shared_preferences.dart';

const int _defaultPasswordLength = 10;
const int _defaultPinLength = 4;
const HashAlgorithm _defaultHashAlgorithm = HashAlgorithm.md5;

const String _keyPasswordLength = "passwordLength";
const String _keyPinLength = "pinLength";
const String _keyHashAlgorithm = "hashAlgorithm";
const String _keyHistoryEntries = "historyEntries";

enum HashAlgorithm {
  md5,
  sha512,
}

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

class History {
  final Set<String> entries = LinkedHashSet<String>();

  History.list(List<String> value) {
    if (value != null && value.isNotEmpty) {
      entries.addAll(value);
    }
  }

  void add(String entry) {
    entries.remove(entry);
    entries.add(entry);

    final int overflow = (entries.length - 100);
    for (int i = 0; i < overflow; i++) {
      entries.remove(entries.first);
    }
  }

  void remove(String entry) {
    entries.remove(entry);
  }

  static Future<History> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> value = prefs.getStringList(_keyHistoryEntries);
    return History.list(value);
  }

  Future<void> save() async {
    final List<String> value = entries.toList();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyHistoryEntries, value);
  }
}
