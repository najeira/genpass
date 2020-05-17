import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'model.dart';
import 'service.dart';

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
          _buildItem(
            context,
            title: "About",
            icon: Icons.info_outline,
            value: "about",
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    String title,
    IconData icon,
    String value,
  }) {
    return InkWell(
      onTap: () {
        _onItemPressed(context, value);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 4.0),
        child: _Caption(
          icon: icon,
          title: title,
        ),
      ),
    );
  }

  void _onItemPressed(BuildContext context, String value) {
    switch (value) {
      case "about":
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const <Widget>[
                      Text("GenPass app is made by najeira."),
                      Text("Icon made by Freepik from www.flaticon.com"),
                    ],
                  ),
                ),
              ],
            );
          },
        );
        break;
    }
  }

  void _onBackPressed(BuildContext context) {
    Navigator.of(context).maybePop(
      Settings(
        passwordLength: Provider.of<_PasswordLengthNotifier>(context, listen: false).value,
        pinLength: Provider.of<_PinLengthNotifier>(context, listen: false).value,
        hashAlgorithm: Provider.of<_HashAlgorithmNotifier>(context, listen: false).value,
      ),
    );
  }
}

class _Slider<T extends ValueNotifier<int>> extends StatelessWidget {
  const _Slider({
    @required this.icon,
    @required this.title,
    @required this.min,
    @required this.max,
  });

  final IconData icon;
  final String title;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _Caption(
          title: title,
          icon: icon,
        ),
        Consumer<T>(
          builder: (BuildContext context, T valueNotifier, Widget child) {
            final int value = valueNotifier.value;
            return Slider(
              label: value.toString(),
              value: value.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: (max - min),
              onChanged: (double value) {
                valueNotifier.value = value.toInt();
              },
            );
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
    final ValueNotifier<bool> confirmation = Provider.of<ValueNotifier<bool>>(context, listen: false);
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
    @required this.icon,
    @required this.title,
  });

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
            size: textTheme.bodyText2.fontSize,
          ),
          const SizedBox(width: 8.0),
          Text(
            title,
            style: TextStyle(
              fontSize: textTheme.bodyText2.fontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
