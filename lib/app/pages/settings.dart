import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:genpass/app/gloabls.dart';
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

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    Key key,
    this.settings,
  }) : super(key: key);

  final Settings settings;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<_PasswordLengthNotifier>(
          create: (BuildContext context) => _PasswordLengthNotifier(settings.passwordLength),
        ),
        ChangeNotifierProvider<_PinLengthNotifier>(
          create: (BuildContext context) => _PinLengthNotifier(settings.pinLength),
        ),
        ChangeNotifierProvider<_HashAlgorithmNotifier>(
          create: (BuildContext context) => _HashAlgorithmNotifier(settings.hashAlgorithm),
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
        title: const Text("Settings"),
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
          const Padding(
            padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: _ThemeModeRow(),
          ),
          const Divider(),
          const _AboutRow(),
          const Divider(),
        ],
      ),
    );
  }

  void _onBackPressed(BuildContext context) {
    Navigator.of(context).maybePop(
      Settings(
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
        _Caption(
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
            const _Caption(
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

class _Caption extends StatelessWidget {
  const _Caption({
    Key key,
    @required this.icon,
    @required this.title,
  }) : super(key: key);

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final TextTheme textTheme = themeData.textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            size: textTheme.subtitle1.fontSize,
          ),
          const SizedBox(width: 8.0),
          Text(
            title,
            style: TextStyle(
              fontSize: textTheme.subtitle1.fontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _onPressed(context),
      child: const Padding(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
        child: _Caption(
          icon: Icons.info_outline,
          title: "About",
        ),
      ),
    );
  }

  void _onPressed(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                ListTile(title: Text("GenPass app made by najeira")),
                // <div>Icons made by <a href="https://www.flaticon.com/authors/becris" title="Becris">Becris</a> from <a href="https://www.flaticon.com/" title="Flaticon">www.flaticon.com</a></div>
                ListTile(title: Text("App icon made by Becris from www.flaticon.com")),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ThemeModeRow extends StatelessWidget {
  const _ThemeModeRow({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ValueNotifier<ThemeMode> notifier = context.watch<ValueNotifier<ThemeMode>>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _Caption(
          title: "Theme Mode",
          icon: Icons.palette,
        ),
        RadioListTile<ThemeMode>(
          title: const Text("System"),
          value: ThemeMode.system,
          groupValue: notifier.value,
          onChanged: (ThemeMode value) => notifier.value = value,
        ),
        RadioListTile<ThemeMode>(
          title: const Text("Light"),
          value: ThemeMode.light,
          groupValue: notifier.value,
          onChanged: (ThemeMode value) => notifier.value = value,
        ),
        RadioListTile<ThemeMode>(
          title: const Text("Dark"),
          value: ThemeMode.dark,
          groupValue: notifier.value,
          onChanged: (ThemeMode value) => notifier.value = value,
        ),
      ],
    );
  }
}
