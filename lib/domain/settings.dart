import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genpass/app/gloabls.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'hash_algorithm.dart';

const int _defaultPasswordLength = 10;
const int _defaultPinLength = 4;
const HashAlgorithm _defaultHashAlgorithm = HashAlgorithm.md5;

const String _keySettings = "settings";
const String _keyPasswordLength = "passwordLength";
const String _keyPinLength = "pinLength";
const String _keyHashAlgorithm = "hashAlgorithm";

@immutable
class Setting {
  const Setting({
    this.passwordLength = _defaultPasswordLength,
    this.pinLength = _defaultPinLength,
    this.hashAlgorithm = _defaultHashAlgorithm,
  });

  final int passwordLength;
  final int pinLength;
  final HashAlgorithm hashAlgorithm;

  Setting copyWith({
    int? passwordLength,
    int? pinLength,
    HashAlgorithm? hashAlgorithm,
  }) {
    return Setting(
      passwordLength: passwordLength ?? this.passwordLength,
      pinLength: pinLength ?? this.pinLength,
      hashAlgorithm: hashAlgorithm ?? this.hashAlgorithm,
    );
  }
}

class SettingController extends StateController<Setting> {
  SettingController(
    this.parent,
    this.index,
  ) : super(parent.items[index]);

  final SettingList parent;

  final int index;

  @override
  set state(Setting value) {
    assert(parent.items[index] == state);
    super.state = parent.items[index] = value;
  }
}

class SettingList extends ChangeNotifier {
  SettingList() {
    load();
  }

  SettingList.items(List<Setting> items) {
    this.items.addAll(items);
  }

  final items = <Setting>[];

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void add(Setting item) {
    items.add(item);
    notifyListeners();
  }

  void removeAt(int index) {
    items.removeAt(index);
    notifyListeners();
  }

  Future<void> load() {
    _isLoading = true;
    try {
      return _load();
    } finally {
      _isLoading = false;
    }
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keySettings);
    final decodedItems = decode(str);
    items.addAll(decodedItems);
    log.config("settings is loaded ${items.length}");
    notifyListeners();
  }

  Future<void> save() async {
    final str = encode(items);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySettings, str);
    log.config("settings is saved ${items.length}");
  }

  static List<Setting> decode(String? str) {
    if (str == null || str.isEmpty) {
      return [const Setting()];
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
    return items;
  }

  static String encode(List<Setting> settings) {
    return jsonEncode(settings.map((e) {
      return <String, Object?>{
        _keyPasswordLength: e.passwordLength,
        _keyPinLength: e.pinLength,
        _keyHashAlgorithm: e.hashAlgorithm.name,
      };
    }).toList());
  }
}
