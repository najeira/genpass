import 'package:flutter/material.dart';

import '../service/crypto.dart';

import 'settings.dart';

class Generators extends ChangeNotifier {
  Generators() : items = <Generator>[];

  final List<Generator> items;

  @override
  void dispose() {
    for (final item in items) {
      item.dispose();
    }
    super.dispose();
  }

  void setSettings(Settings settings) {
    items.clear();
    items.addAll(settings.items.map((Setting setting) {
      return Generator(setting);
    }));
    notifyListeners();
  }

  void addSetting(Setting setting) {
    items.add(Generator(setting));
    notifyListeners();
  }

  void removeSettingAt(int index) {
    items.removeAt(index);
    notifyListeners();
  }
}

class Generator extends ChangeNotifier {
  Generator(this._setting);

  Setting _setting;

  Setting get setting => _setting;

  set setting(Setting setting) {
    _setting = setting;
    _update(_lastMaster, _lastDomain);
  }

  String _lastMaster = "";
  String _lastDomain = "";

  String password = "";
  String pin = "";

  void clear() {
    _lastMaster = "";
    _lastDomain = "";
    if (password.isNotEmpty || pin.isNotEmpty) {
      password = "";
      pin = "";
      notifyListeners();
    }
  }

  void update(String master, String domain) {
    _lastMaster = master;
    _lastDomain = domain;
    _update(master, domain);
  }

  void _update(String master, String domain) {
    final password = Crypto.generatePassword(
      setting.hashAlgorithm,
      domain,
      master,
      setting.passwordLength,
    );

    final pin = Crypto.generatePin(
      domain,
      master,
      setting.pinLength,
    );

    if (this.password != password || this.pin != pin) {
      this.password = password;
      this.pin = pin;
      notifyListeners();
    }
  }
}
