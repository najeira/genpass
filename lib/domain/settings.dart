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
    this.passwordLength = _defaultPasswordLength,
    this.pinLength = _defaultPinLength,
    this.hashAlgorithm = _defaultHashAlgorithm,
  });

  final int passwordLength;
  final int pinLength;
  final HashAlgorithm hashAlgorithm;
}

class Settings {
  Settings(this.items);

  Settings.single() : this(<Setting>[const Setting()]);

  final List<Setting> items;

  static Future<Settings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keySettings);
    return decode(str);
  }

  Future<void> save() async {
    final str = encode(this);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySettings, str);
  }

  static Settings decode(String? str) {
    if (str == null || str.isEmpty) {
      return Settings.single();
    }

    final list = jsonDecode(str) as List<Object?>;
    final items = list.map((elem) {
      final map = elem as Map<String, Object?>;
      final passwordLength = map[_keyPasswordLength] as int;
      final pinLength = map[_keyPinLength] as int;
      final hashAlgorithm = map[_keyHashAlgorithm] as String;
      return Setting(
        passwordLength: passwordLength,
        pinLength: pinLength,
        hashAlgorithm: HashAlgorithmFactory.fromName(hashAlgorithm),
      );
    }).toList();

    return Settings(items);
  }

  static String encode(Settings settings) {
    return jsonEncode(settings.items.map((Setting setting) {
      return <String, Object?>{
        _keyPasswordLength: setting.passwordLength,
        _keyPinLength: setting.pinLength,
        _keyHashAlgorithm: setting.hashAlgorithm.name,
      };
    }).toList());
  }
}
