import 'package:flutter/material.dart';

import '../service/crypto.dart';

import 'settings.dart';

class Generators extends ChangeNotifier {
  Generators() : items = <Generator>[];

  final List<Generator> items;

  void dispose() {
    for (final Generator item in items) {
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
  Generator(this._setting) : assert(_setting != null);

  Setting _setting;

  Setting get setting => _setting;

  set setting(Setting setting) {
    assert(setting != null);
    _setting = _setting;
    _update(_lastMaster, _lastDomain);
  }

  String _lastMaster;
  String _lastDomain;

  String password;
  String pin;

  void clear() {
    _lastMaster = null;
    _lastDomain = null;
    if (password != null || pin != null) {
      password = null;
      pin = null;
      notifyListeners();
    }
  }

  void update(String master, String domain) {
    _lastMaster = master;
    _lastDomain = domain;
    _update(master, domain);
  }

  void _update(String master, String domain) {
    final String password = Crypto.generatePassword(
      setting.hashAlgorithm,
      domain,
      master,
      setting.passwordLength,
    );

    final String pin = Crypto.generatePin(
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
