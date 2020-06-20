import 'package:flutter/material.dart';

import 'error_message.dart';
import 'generator.dart';
import 'settings.dart';

class GenPassData {
  final ValueNotifier<bool> darkThemeNotifier = ValueNotifier<bool>(false);

  final TextEditingController masterNotifier = TextEditingController();
  final ErrorMessageNotifier masterErrorNotifier = ErrorMessageNotifier();

  final TextEditingController domainNotifier = TextEditingController();
  final ErrorMessageNotifier domainErrorNotifier = ErrorMessageNotifier();

  final Settings settings = Settings.single();
  final Generators generators = Generators();

  GenPassData(){
    generators.setSettings(settings);
    masterNotifier.addListener(_onInputUpdated);
    domainNotifier.addListener(_onInputUpdated);
  }

  void dispose() {
    darkThemeNotifier?.dispose();
    masterNotifier?.dispose();
    masterErrorNotifier?.dispose();
    domainNotifier?.dispose();
    domainErrorNotifier?.dispose();
    generators?.dispose();
  }

  void setSettings(Settings newSettings) {
    settings.items.clear();
    settings.items.addAll(newSettings.items);
    generators.setSettings(newSettings);

    settings.save();
  }

  void addSetting(Setting setting) {
    settings.items.add(setting);
    generators.addSetting(setting);
    _onInputUpdated();

    settings.save();
  }

  void removeSettingAt(int index) {
    settings.items.removeAt(index);
    generators.removeSettingAt(index);
    _onInputUpdated();

    settings.save();
  }

  Future<void> saveSettings() {
    return settings.save();
  }

  void _onInputUpdated() {
    final String master = masterNotifier.value.text ?? "";
    final String domain = domainNotifier.value.text ?? "";

    masterErrorNotifier.value = _Validator.validateMaster(master);
    domainErrorNotifier.value = _Validator.validateDomain(domain);

    final bool hasValue = masterErrorNotifier.value == null && domainErrorNotifier.value == null;

    for (final Generator generator in generators.items) {
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
