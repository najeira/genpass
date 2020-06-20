import 'package:flutter/material.dart';

import '../service/crypto.dart';

import 'error_message.dart';
import 'settings.dart';

class GenPassData {
  final ValueNotifier<bool> darkThemeNotifier = ValueNotifier<bool>(false);

  final ValueNotifier<Setting> settingsNotifier = ValueNotifier<Setting>(Setting());

  final TextEditingController masterNotifier = TextEditingController();
  final ErrorMessageNotifier masterErrorNotifier = ErrorMessageNotifier();

  final TextEditingController domainNotifier = TextEditingController();
  final ErrorMessageNotifier domainErrorNotifier = ErrorMessageNotifier();

  final ValueNotifier<String> passNotifier = ValueNotifier<String>("");
  final ValueNotifier<String> pinNotifier = ValueNotifier<String>("");

  GenPassData() {
    settingsNotifier.addListener(_onUpdated);
    masterNotifier.addListener(_onUpdated);
    domainNotifier.addListener(_onUpdated);
  }

  void dispose() {
    darkThemeNotifier?.dispose();
    settingsNotifier?.dispose();
    masterNotifier?.dispose();
    domainNotifier?.dispose();
    passNotifier?.dispose();
    pinNotifier?.dispose();
    masterErrorNotifier?.dispose();
    domainErrorNotifier?.dispose();
  }

  void _onUpdated() {
    final String master = masterNotifier.value.text ?? "";
    final String domain = domainNotifier.value.text ?? "";

    masterErrorNotifier.value = _Validator.validateMaster(master);
    domainErrorNotifier.value = _Validator.validateDomain(domain);

    if (masterErrorNotifier.value == null && domainErrorNotifier.value == null) {
      final Setting settings = settingsNotifier.value;
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

  static ErrorMessage validateMaster(String value) {
    if (value == null || value.isEmpty || value.length < 8) {
      return ErrorMessage("enter 8 or more characters");
    }
    return null;
  }

  static ErrorMessage validateDomain(String value) {
    if (value == null || value.isEmpty) {
      return ErrorMessage("enter");
    }
    return null;
  }
}
