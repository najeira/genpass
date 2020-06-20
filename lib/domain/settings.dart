import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'hash_algorithm.dart';

const int _defaultPasswordLength = 10;
const int _defaultPinLength = 4;
const HashAlgorithm _defaultHashAlgorithm = HashAlgorithm.md5;

const String _keySettings = "settings";
const String _keyPasswordLength = "passwordLength";
const String _keyPinLength = "pinLength";
const String _keyHashAlgorithm = "hashAlgorithm";

class Setting {
  const Setting({
    this.passwordLength: _defaultPasswordLength,
    this.pinLength: _defaultPinLength,
    this.hashAlgorithm: _defaultHashAlgorithm,
  });

  final int passwordLength;
  final int pinLength;
  final HashAlgorithm hashAlgorithm;
}

class Settings {
  const Settings([this.settings = const <Setting>[Setting()]]);

  final List<Setting> settings;

  static Future<Settings> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String str = prefs.getString(_keySettings);
    return decode(str);
  }

  Future<void> save() async {
    final String str = encode(this);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySettings, str);
  }

  static Settings decode(String str) {
    if (str == null || str.isEmpty) {
      return const Settings(<Setting>[Setting()]);
    }

    final List<dynamic> list = jsonDecode(str);
    final List<Setting> settings = list.map<Setting>((dynamic elem) {
      final Map<String, Object> map = elem;
      return Setting(
        passwordLength: map[_keyPasswordLength] ?? _defaultPasswordLength,
        pinLength: map[_keyPinLength] ?? _defaultPinLength,
        hashAlgorithm: HashAlgorithmFactory.fromName(map[_keyHashAlgorithm]) ?? _defaultHashAlgorithm,
      );
    }).toList();
    return Settings(settings);
  }

  static String encode(Settings settings) {
    return jsonEncode(settings.settings.map<Map<String, Object>>((Setting setting) {
      return <String, Object>{
        _keyPasswordLength: setting.passwordLength,
        _keyPinLength: setting.pinLength,
        _keyHashAlgorithm: setting.hashAlgorithm.name,
      };
    }).toList());
  }
}
