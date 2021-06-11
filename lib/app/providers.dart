import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:genpass/domain/history.dart';
import 'package:genpass/domain/result.dart';
import 'package:genpass/domain/settings.dart';
import 'package:genpass/service/crypto.dart';

final themeModeProvider =
    StateNotifierProvider<StateController<ThemeMode>, ThemeMode>((ref) {
  return StateController<ThemeMode>(ThemeMode.system);
});

final historyProvider = ChangeNotifierProvider<History>((ref) {
  return History();
});

final settingListProvider =
    ChangeNotifierProvider<SettingList>((ref) {
  return SettingList();
});

final _launchFutureProvider = FutureProvider<void>((ref) async {
  await Future<void>.delayed(const Duration(milliseconds: 3000));
});

final _isLaunchingProvider = Provider<bool>((ref) {
  final l = ref.watch(_launchFutureProvider);
  return l.when(
    data: (_) => false,
    loading: () => true,
    error: (_, __) => false,
  );
});

final isLaunchingProvider = Provider<bool>((ref) {
  final h = ref.watch(historyProvider);
  final s = ref.watch(settingListProvider);
  final l = ref.watch(_isLaunchingProvider);
  return h.isLoading || s.isLoading || l;
});

final selectedSettingIndexProvider = ScopedProvider<int>(null);

final selectedSettingProvider = StateNotifierProvider.family
    .autoDispose<SettingController, Setting, int>((ref, index) {
  final settings = ref.watch(settingListProvider);
  return SettingController(settings, index);
});

Setting selectedSetting(ScopedReader reader) {
  final index = reader(selectedSettingIndexProvider);
  return reader(selectedSettingProvider(index));
}

SettingController selectedSettingController(ScopedReader reader) {
  final index = reader(selectedSettingIndexProvider);
  return reader(selectedSettingProvider(index).notifier);
}

final masterTextEditingProvider =
    ChangeNotifierProvider<TextEditingController>((ref) {
  return TextEditingController();
});

final masterErrorTextProvider = Provider<String?>((ref) {
  final text = ref.watch(masterTextEditingProvider);
  if (text.text.isEmpty || text.text.length < 8) {
    return "enter 8 or more characters";
  }
  return null;
});

final masterVisibleProvider =
    StateNotifierProvider<StateController<bool>, bool>((ref) {
  return StateController<bool>(false);
});

final domainTextEditingProvider =
    ChangeNotifierProvider<TextEditingController>((ref) {
  return TextEditingController();
});

final domainErrorTextProvider = Provider<String?>((ref) {
  final text = ref.watch(domainTextEditingProvider);
  if (text.text.isEmpty) {
    return "enter";
  }
  return null;
});

final passwordVisibilityProvider = StateNotifierProvider.family
    .autoDispose<StateController<bool>, bool, int>((ref, index) {
  return StateController<bool>(false);
});

final pinVisibilityProvider = StateNotifierProvider.family
    .autoDispose<StateController<bool>, bool, int>((ref, index) {
  return StateController<bool>(false);
});

final resultProvider = Provider.family.autoDispose<Result, int>((ref, index) {
  final master = ref.watch(masterTextEditingProvider);
  final masterError = ref.watch(masterErrorTextProvider);
  final domain = ref.watch(domainTextEditingProvider);
  final domainError = ref.watch(domainErrorTextProvider);
  final setting = ref.watch(selectedSettingProvider(index));

  if (masterError != null || domainError != null) {
    return const Result(
      password: "",
      pin: "",
    );
  }

  final password = Crypto.generatePassword(
    setting.hashAlgorithm,
    domain.text,
    master.text,
    setting.passwordLength,
  );
  final pin = Crypto.generatePin(
    domain.text,
    master.text,
    setting.pinLength,
  );
  return Result(
    password: password,
    pin: pin,
  );
});

final resultPasswordProvider =
    Provider.family.autoDispose<String, int>((ref, index) {
  final visible = ref.watch(passwordVisibilityProvider(index));
  final result = ref.watch(resultProvider(index));
  final text = result.password;
  if (text.isEmpty) {
    return "-";
  } else if (!visible) {
    return "".padRight(text.length, "*");
  }
  return text;
});

final resultPinProvider =
    Provider.family.autoDispose<String, int>((ref, index) {
  final visible = ref.watch(pinVisibilityProvider(index));
  final result = ref.watch(resultProvider(index));
  final text = result.pin;
  if (text.isEmpty) {
    return "-";
  } else if (!visible) {
    return "".padRight(text.length, "*");
  }
  return text;
});
