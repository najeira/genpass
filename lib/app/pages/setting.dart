import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:genpass/app/gloabls.dart';
import 'package:genpass/app/providers.dart';
import 'package:genpass/app/widgets/setting_caption.dart';
import 'package:genpass/domain/hash_algorithm.dart';
import 'package:genpass/domain/settings.dart';

const _padding = EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0);

final _confirmationProvider =
    StateNotifierProvider.autoDispose<StateController<bool>, bool>((ref) {
  return StateController<bool>(false);
});

class SettingPage extends StatelessWidget {
  const SettingPage._({
    Key? key,
  }) : super(key: key);

  static Future<void> push(BuildContext context, int index) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<Setting>(
        builder: (BuildContext context) {
          return ProviderScope(
            overrides: [
              selectedSettingIndexProvider.overrideWithValue(index),
            ],
            child: const SettingPage._(),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Setting"),
      ),
      body: ListView(
        children: const <Widget>[
          Padding(
            padding: _padding,
            child: _PasswordLengthSlider(),
          ),
          Divider(),
          Padding(
            padding: _padding,
            child: _PinLengthSlider(),
          ),
          Divider(),
          Padding(
            padding: _padding,
            child: _Algorithms(),
          ),
          Divider(),
        ],
      ),
    );
  }
}

class _PasswordLengthSlider extends ConsumerWidget {
  const _PasswordLengthSlider({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setting = watchSelectedSetting(ref);
    return _Slider(
      onChanged: (int value) {
        final ctrl = readSelectedSettingController(ref);
        ctrl.state = ctrl.state.copyWith(passwordLength: value);
      },
      title: "Password length",
      icon: kIconPassword,
      value: setting.passwordLength,
      min: 8,
      max: 20,
    );
  }
}

class _PinLengthSlider extends ConsumerWidget {
  const _PinLengthSlider({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setting = watchSelectedSetting(ref);
    return _Slider(
      onChanged: (int value) {
        final ctrl = readSelectedSettingController(ref);
        ctrl.state = ctrl.state.copyWith(pinLength: value);
      },
      title: "PIN length",
      icon: kIconPin,
      value: setting.pinLength,
      min: 3,
      max: 10,
    );
  }
}

class _Slider extends StatelessWidget {
  const _Slider({
    Key? key,
    required this.onChanged,
    required this.icon,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
  }) : super(key: key);

  final ValueChanged<int> onChanged;
  final IconData icon;
  final String title;
  final int value;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SettingCaption(
          title: title,
          icon: icon,
        ),
        Slider(
          label: value.toString(),
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min,
          onChanged: (double value) {
            onChanged(value.toInt());
          },
        ),
      ],
    );
  }
}

class _Algorithms extends ConsumerWidget {
  const _Algorithms({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setting = watchSelectedSetting(ref);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SettingCaption(
          title: "Algorithms",
          icon: kIconAlgorithm,
        ),
        RadioListTile<HashAlgorithm>(
          title: const Text("MD5"),
          value: HashAlgorithm.md5,
          groupValue: setting.hashAlgorithm,
          onChanged: (HashAlgorithm? value) => _onHashAlgorithmChanged(
            context, ref, value),
        ),
        RadioListTile<HashAlgorithm>(
          title: const Text("SHA512"),
          value: HashAlgorithm.sha512,
          groupValue: setting.hashAlgorithm,
          onChanged: (HashAlgorithm? value) => _onHashAlgorithmChanged(
            context, ref, value),
        ),
      ],
    );
  }

  void _onHashAlgorithmChanged(
    BuildContext context,
    WidgetRef ref,
    HashAlgorithm? value,
  ) {
    final confirmation = ref.read(_confirmationProvider);
    if (confirmation) {
      _updateHashAlgorithm(context, ref, value);
      return;
    }

    showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text(
            "Changing the algorithm changes "
            "the generating password.",
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ).then((bool? confirm) {
      // confirmed
      final ctrl = ref.read(_confirmationProvider.notifier);
      ctrl.state = true;

      if (confirm == true) {
        _updateHashAlgorithm(context, ref, value);
      }
    });
  }

  void _updateHashAlgorithm(
    BuildContext context,
    WidgetRef ref,
    HashAlgorithm? value,
  ) {
    final ctrl = readSelectedSettingController(ref);
    ctrl.state = ctrl.state.copyWith(hashAlgorithm: value);
  }
}
