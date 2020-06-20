import 'package:flutter/material.dart';

import '../service/crypto.dart';

import 'settings.dart';

class Generator extends ChangeNotifier {
  Generator(this.settings);

  final Setting settings;
  String password = "";
  String pin = "";

  void clear() {
    if (password != "" || pin != "") {
      password = password;
      pin = pin;
      notifyListeners();
    }
  }

  void update(String master, String domain) {
    final String password = Crypto.generatePassword(
      settings.hashAlgorithm,
      domain,
      master,
      settings.passwordLength,
    );
    final String pin = Crypto.generatePin(
      domain,
      master,
      settings.pinLength,
    );
    if (this.password != password || this.pin != pin) {
      this.password = password;
      this.pin = pin;
      notifyListeners();
    }
  }
}
