import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:genpass/app/gloabls.dart';
import 'package:genpass/app/widgets/setting_caption.dart';
import 'package:genpass/domain/hash_algorithm.dart';
import 'package:genpass/domain/settings.dart';

class _PasswordLengthNotifier extends ValueNotifier<int> {
  _PasswordLengthNotifier(int value) : super(value);
}

class _PinLengthNotifier extends ValueNotifier<int> {
  _PinLengthNotifier(int value) : super(value);
}

class _HashAlgorithmNotifier extends ValueNotifier<HashAlgorithm> {
  _HashAlgorithmNotifier(HashAlgorithm value) : super(value);
}

class SettingPage extends StatelessWidget {
  const SettingPage({
    Key key,
    this.setting,
  }) : super(key: key);

  final Setting setting;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<_PasswordLengthNotifier>(
          create: (BuildContext context) => _PasswordLengthNotifier(setting.passwordLength),
        ),
        ChangeNotifierProvider<_PinLengthNotifier>(
          create: (BuildContext context) => _PinLengthNotifier(setting.pinLength),
        ),
        ChangeNotifierProvider<_HashAlgorithmNotifier>(
          create: (BuildContext context) => _HashAlgorithmNotifier(setting.hashAlgorithm),
        ),
      ],
      child: Builder(
        builder: (BuildContext context) => _buildScaffold(context),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Setting"),
        leading: IconButton(
          icon: const BackButtonIcon(),
          tooltip: 'Back',
          onPressed: () {
            _onBackPressed(context);
          },
        ),
      ),
      body: ListView(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: _Slider<_PasswordLengthNotifier>(
              title: "Password length",
              icon: kIconPassword,
              min: 8,
              max: 20,
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: _Slider<_PinLengthNotifier>(
              title: "PIN length",
              icon: kIconPin,
              min: 3,
              max: 10,
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: _Algorithms(),
          ),
          const Divider(),
        ],
      ),
    );
  }

  void _onBackPressed(BuildContext context) {
    Navigator.of(context).maybePop(
      Setting(
        passwordLength: context.read<_PasswordLengthNotifier>().value,
        pinLength: context.read<_PinLengthNotifier>().value,
        hashAlgorithm: context.read<_HashAlgorithmNotifier>().value,
      ),
    );
  }
}

class _Slider<T extends ValueNotifier<int>> extends StatelessWidget {
  const _Slider({
    Key key,
    @required this.icon,
    @required this.title,
    @required this.min,
    @required this.max,
  }) : super(key: key);

  final IconData icon;
  final String title;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    final T valueNotifier = context.watch<T>();
    final int value = valueNotifier.value;
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
          divisions: (max - min),
          onChanged: (double value) {
            valueNotifier.value = value.toInt();
          },
        ),
      ],
    );
  }
}

class _Algorithms extends StatelessWidget {
  const _Algorithms({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ValueNotifier<bool>>(
      create: (BuildContext context) => ValueNotifier<bool>(false),
      child: _build(context),
    );
  }

  Widget _build(BuildContext context) {
    return Consumer<_HashAlgorithmNotifier>(
      builder: (
        BuildContext context,
        _HashAlgorithmNotifier valueNotifier,
        Widget child,
      ) {
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
              groupValue: valueNotifier.value,
              onChanged: (HashAlgorithm value) => _onHashAlgorithmChanged(
                context,
                valueNotifier,
                value,
              ),
            ),
            RadioListTile<HashAlgorithm>(
              title: const Text("SHA512"),
              value: HashAlgorithm.sha512,
              groupValue: valueNotifier.value,
              onChanged: (HashAlgorithm value) => _onHashAlgorithmChanged(
                context,
                valueNotifier,
                value,
              ),
            ),
          ],
        );
      },
    );
  }

  void _onHashAlgorithmChanged(
    BuildContext context,
    _HashAlgorithmNotifier valueNotifier,
    HashAlgorithm value,
  ) {
    final ValueNotifier<bool> confirmation = context.read<ValueNotifier<bool>>();
    if (confirmation.value == true) {
      valueNotifier.value = value;
      return;
    }

    showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text("Changing the algorithm changes the generating password."),
          actions: <Widget>[
            FlatButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            FlatButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ).then((bool confirm) {
      if (confirm == true) {
        confirmation.value = true;
        valueNotifier.value = value;
      }
    });
  }
}
