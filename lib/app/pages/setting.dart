import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:genpass/app/gloabls.dart';
import 'package:genpass/app/providers.dart';
import 'package:genpass/app/widgets/setting_caption.dart';
import 'package:genpass/domain/hash_algorithm.dart';
import 'package:genpass/domain/settings.dart';

final _scopedSettingProvider = StateProvider<Setting>(
  (ref) => const Setting(),
);

class SettingPage extends StatelessWidget {
  const SettingPage._({
    super.key,
    required this.index,
  });

  final int index;

  static Future<void> push(BuildContext context, int index) async {
    final nav = Navigator.of(context);

    final ps = ProviderScope.containerOf(context, listen: false);
    final items = await ps.read(settingListProvider.future);
    final item = items[index];

    final newItem = await nav.push<Setting?>(
      MaterialPageRoute<Setting>(
        builder: (BuildContext context) {
          return ProviderScope(
            overrides: [
              _scopedSettingProvider.overrideWith((ref) => item),
            ],
            child: SettingPage._(index: index),
          );
        },
      ),
    );
    if (newItem != null) {
      final notifier = ps.read(settingListProvider.notifier);
      await notifier.replaceAt(index, newItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        final ps = ProviderScope.containerOf(context, listen: false);
        final item = ps.read(_scopedSettingProvider);
        log.config("SettingPage.onPopInvoked: ${item}");
        Navigator.of(context).pop(item);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Generator ${index + 1}"),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: const <Widget>[
            _PasswordLengthSlider(),
            Divider(height: 32.0),
            _PinLengthSlider(),
            Divider(height: 32.0),
            _Algorithms(),
            Divider(height: 32.0),
            SizedBox(height: 100.0),
          ],
        ),
      ),
    );
  }
}

class _PasswordLengthSlider extends ConsumerWidget {
  const _PasswordLengthSlider({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(
      _scopedSettingProvider.select((value) => value.passwordLength),
    );
    return _Slider(
      onChanged: (int value) {
        final notifier = ref.read(_scopedSettingProvider.notifier);
        notifier.state = notifier.state.copyWith(
          passwordLength: value,
        );
      },
      title: "Password length",
      icon: kIconPassword,
      value: value,
      min: 8,
      max: 20,
    );
  }
}

class _PinLengthSlider extends ConsumerWidget {
  const _PinLengthSlider({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(_scopedSettingProvider.select(
      (value) => value.pinLength,
    ));
    return _Slider(
      onChanged: (int value) {
        final notifier = ref.read(_scopedSettingProvider.notifier);
        notifier.state = notifier.state.copyWith(
          pinLength: value,
        );
      },
      title: "PIN length",
      icon: kIconPin,
      value: value,
      min: 3,
      max: 10,
    );
  }
}

class _Slider extends StatelessWidget {
  const _Slider({
    super.key,
    required this.onChanged,
    required this.icon,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
  });

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
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(
      _scopedSettingProvider.select((value) => value.hashAlgorithm),
    );
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
          groupValue: value,
          onChanged: (HashAlgorithm? value) =>
              _onHashAlgorithmChanged(context, ref, value),
        ),
        RadioListTile<HashAlgorithm>(
          title: const Text("SHA512"),
          value: HashAlgorithm.sha512,
          groupValue: value,
          onChanged: (HashAlgorithm? value) =>
              _onHashAlgorithmChanged(context, ref, value),
        ),
      ],
    );
  }

  void _onHashAlgorithmChanged(
    BuildContext context,
    WidgetRef ref,
    HashAlgorithm? value,
  ) {
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) => const _Dialog(),
    ).then((bool? confirm) {
      if (confirm == true) {
        final notifier = ref.read(_scopedSettingProvider.notifier);
        notifier.state = notifier.state.copyWith(
          hashAlgorithm: value,
        );
      }
    });
  }
}

class _Dialog extends StatelessWidget {
  const _Dialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    log.fine("_AlertDialog.build");
    final themeData = Theme.of(context);
    return AlertDialog(
      icon: const Icon(Icons.warning_amber_rounded),
      title: const Text("Algorithm"),
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
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: themeData.colorScheme.onPrimary,
            backgroundColor: themeData.colorScheme.primary,
          ),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: const Text("OK"),
        ),
      ],
    );
  }
}
