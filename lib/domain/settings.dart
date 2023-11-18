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

class SettingList extends AsyncNotifier<List<Setting>> {
  @override
  Future<List<Setting>> build() => _load();

  List<Setting>? get _items => state.unwrapPrevious().valueOrNull; 

  Setting getAt(int index) {
    final items = _items;
    if (items != null && items.length > index) {
      return items[index];
    }
    return const Setting();
  }

  Future<void> add(Setting item) async {
    final items = _items;
    if (items != null) {
      final newValue = List<Setting>.of(items);
      newValue.add(item);
      state = AsyncValue.data(newValue);
    } else {
      state = AsyncValue.data(<Setting>[item]);
    }
    await _save();
  }

  Future<void> removeAt(int index) async {
    final items = _items;
    if (items != null && items.length > index) {
      final newValue = List<Setting>.of(items);
      newValue.removeAt(index);
      state = AsyncValue.data(newValue);
      await _save();
    }
  }

  Future<void> replaceAt(int index, Setting item) async {
    final items = _items;
    if (items != null && items.length > index) {
      final newValue = List<Setting>.of(items);
      newValue[index] = item;
      state = AsyncValue.data(newValue);
      await _save();
    }
  }

  Future<List<Setting>> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keySettings);
    final decodedItems = decode(str);
    log.config("settings is loaded ${decodedItems.length}");
    return decodedItems;
  }

  Future<void> _save() async {
    final items = _items;
    if (items == null) {
      return;
    }
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
