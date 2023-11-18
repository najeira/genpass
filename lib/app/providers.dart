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
    AsyncNotifierProvider<SettingList, List<Setting>>(() {
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

const _kEmptyResult = Result(
  password: "",
  pin: "",
);

final resultProvider = Provider.family.autoDispose<Result, int>((ref, index) {
  final master = ref.watch(masterTextEditingProvider.select(
    (value) => value.text,
  ));
  final masterError = ref.watch(masterErrorTextProvider);
  final domain = ref.watch(domainTextEditingProvider.select(
    (value) => value.text,
  ));
  final domainError = ref.watch(domainErrorTextProvider);
  final settings = ref.watch(settingListProvider);
  return settings.when(
    data: (settings) {
      if (settings.length <= index) {
        return _kEmptyResult;
      } else if (masterError != null || domainError != null) {
        return _kEmptyResult;
      }

      final setting = settings[index];
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
      return Result(
        password: password,
        pin: pin,
      );
    },
    error: (_, __) => _kEmptyResult,
    loading: () => _kEmptyResult,
  );
});

final resultPasswordProvider =
    Provider.family.autoDispose<Value, int>((ref, index) {
  final visible = ref.watch(passwordVisibilityProvider(index));
  final result = ref.watch(resultProvider(index).select(
    (value) => value.password,
  ));
  return Value(
    rawText: result,
    visible: visible,
  );
});

final resultPinProvider = Provider.family.autoDispose<Value, int>((ref, index) {
  final visible = ref.watch(pinVisibilityProvider(index));
  final result = ref.watch(resultProvider(index).select(
    (value) => value.pin,
  ));
  return Value(
    rawText: result,
    visible: visible,
  );
});
