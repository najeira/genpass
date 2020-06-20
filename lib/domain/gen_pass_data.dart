import 'package:flutter/material.dart';

import '../service/crypto.dart';

import 'error_message.dart';
import 'generator.dart';
import 'settings.dart';

class GenPassData {
  final ValueNotifier<bool> darkThemeNotifier = ValueNotifier<bool>(false);

  final ValueNotifier<Settings> settingsNotifier = ValueNotifier<Settings>(Settings());

  final TextEditingController masterNotifier = TextEditingController();
  final ErrorMessageNotifier masterErrorNotifier = ErrorMessageNotifier();

  final TextEditingController domainNotifier = TextEditingController();
  final ErrorMessageNotifier domainErrorNotifier = ErrorMessageNotifier();

  final ValueNotifier<List<Generator>> generators = ValueNotifier<List<Generator>>(null);

  GenPassData() {
    generators.value = _createGenerators();

    settingsNotifier.addListener(_onSettingsUpdated);
    masterNotifier.addListener(_onInputUpdated);
    domainNotifier.addListener(_onInputUpdated);
  }

  void dispose() {
    darkThemeNotifier?.dispose();
    settingsNotifier?.dispose();
    masterNotifier?.dispose();
    domainNotifier?.dispose();
    for (final Generator generator in generators?.value) {
      generator.dispose();
    }
    generators?.dispose();
    masterErrorNotifier?.dispose();
    domainErrorNotifier?.dispose();
  }

  List<Generator> _createGenerators() {
    return settingsNotifier.value.settings.map((Setting setting) {
      return Generator(setting);
    }).toList();
  }

  void _onSettingsUpdated() {
    final List<Generator> generators = _createGenerators();
    _updateGenerators(generators);
    this.generators.value = generators;
  }

  void _onInputUpdated() {
    _updateGenerators(generators.value);
  }

  void _updateGenerators(List<Generator> generators) {
    final String master = masterNotifier.value.text ?? "";
    final String domain = domainNotifier.value.text ?? "";

    masterErrorNotifier.value = _Validator.validateMaster(master);
    domainErrorNotifier.value = _Validator.validateDomain(domain);

    final bool hasValue = masterErrorNotifier.value == null && domainErrorNotifier.value == null;

    for (final Generator generator in generators) {
      if (hasValue) {
        generator.update(master, domain);
      } else {
        generator.clear();
      }
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
