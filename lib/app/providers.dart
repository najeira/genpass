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

final settingListProvider = ChangeNotifierProvider<SettingList>((ref) {
  return SettingList();
});

final _launchFutureProvider = FutureProvider<void>((ref) async {
  var wait = Duration.zero;
  assert(() {
    wait = const Duration(milliseconds: 3000);
    return true;
  }());
  await Future<void>.delayed(wait);
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

final selectedSettingIndexProvider = Provider<int>((ref) => 0);

final selectedSettingProvider = StateNotifierProvider.family
    .autoDispose<SettingController, Setting, int>((ref, index) {
  final settings = ref.watch(settingListProvider);
  return SettingController(settings, index);
});

Setting watchSelectedSetting(WidgetRef ref) {
  final index = ref.watch(selectedSettingIndexProvider);
  return ref.watch(selectedSettingProvider(index));
}

SettingController readSelectedSettingController(WidgetRef ref) {
  final index = ref.read(selectedSettingIndexProvider);
  return ref.read(selectedSettingProvider(index).notifier);
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
    Provider.family.autoDispose<Value, int>((ref, index) {
  final visible = ref.watch(passwordVisibilityProvider(index));
  final result = ref.watch(resultProvider(index));
  final text = result.password;
  return Value(
    rawText: text,
    visible: visible,
  );
});

final resultPinProvider =
    Provider.family.autoDispose<Value, int>((ref, index) {
  final visible = ref.watch(pinVisibilityProvider(index));
  final result = ref.watch(resultProvider(index));
  final text = result.pin;
  return Value(
    rawText: text,
    visible: visible,
  );
});
