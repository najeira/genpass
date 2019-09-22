import 'package:flutter/material.dart';

import 'crypto.dart';
import 'service.dart';

const IconData kIconPassword = Icons.vpn_key;
const IconData kIconPin = Icons.casino;
const IconData kIconAlgorithm = Icons.card_travel;

class GenPassData {
  final ValueNotifier<Settings> settingsNotifier = ValueNotifier<Settings>(Settings());
  final ValueNotifier<String> masterNotifier = ValueNotifier<String>("");
  final ValueNotifier<String> domainNotifier = ValueNotifier<String>("");
  final ValueNotifier<String> passNotifier = ValueNotifier<String>("");
  final ValueNotifier<String> pinNotifier = ValueNotifier<String>("");
  final ValueNotifier<String> masterErrorNotifier = ValueNotifier<String>("");
  final ValueNotifier<String> domainErrorNotifier = ValueNotifier<String>("");

  GenPassData() {
    settingsNotifier.addListener(_onUpdated);
    masterNotifier.addListener(_onUpdated);
    domainNotifier.addListener(_onUpdated);
  }

  void dispose() {
    settingsNotifier?.dispose();
    masterNotifier?.dispose();
    domainNotifier?.dispose();
    passNotifier?.dispose();
    pinNotifier?.dispose();
    masterErrorNotifier?.dispose();
    domainErrorNotifier?.dispose();
  }

  void _onUpdated() {
    final String master = masterNotifier.value;
    final String domain = domainNotifier.value;

    masterErrorNotifier.value = _Validator.validateMaster(master);
    domainErrorNotifier.value = _Validator.validateDomain(domain);

    if (masterErrorNotifier.value == null && domainErrorNotifier.value == null) {
      final Settings settings = settingsNotifier.value;
      passNotifier.value = Crypto.generatePassword(
        settings.hashAlgorithm,
        domain,
        master,
        settings.passwordLength,
      );
      pinNotifier.value = Crypto.generatePin(
        domain,
        master,
        settings.pinLength,
      );
    } else {
      passNotifier.value = "";
      pinNotifier.value = "";
    }
  }
}

class _Validator {
  _Validator._();

  static String validateMaster(String value) {
    if (value == null || value.isEmpty || value.length < 8) {
      return "enter 8 or more characters";
    }
    return null;
  }

  static String validateDomain(String value) {
    if (value == null || value.isEmpty) {
      return "enter";
    }
    return null;
  }
}
