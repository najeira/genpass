import 'package:flutter/material.dart';
import 'package:genpass/model.dart';

import 'service.dart';

class SettingsPage extends StatefulWidget {
  final Settings settings;

  SettingsPage(this.settings);

  @override
  State<StatefulWidget> createState() {
    return _SettingsPageState();
  }
}

class _SettingsPageState extends State<SettingsPage> {
  final ValueNotifier<int> passwordLengthNotifier = ValueNotifier<int>(10);
  final ValueNotifier<int> pinLengthNotifier = ValueNotifier<int>(4);
  final ValueNotifier<HashAlgorithm> hashAlgorithmNotifier = ValueNotifier<HashAlgorithm>(HashAlgorithm.md5);

  @override
  void initState() {
    super.initState();
    passwordLengthNotifier.value = widget.settings.passwordLength;
    pinLengthNotifier.value = widget.settings.pinLength;
    hashAlgorithmNotifier.value = widget.settings.hashAlgorithm;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        leading: IconButton(
          icon: const BackButtonIcon(),
          tooltip: 'Back',
          onPressed: () {
            Navigator.of(context).maybePop(
              Settings(
                passwordLength: passwordLengthNotifier.value,
                pinLength: pinLengthNotifier.value,
                hashAlgorithm: hashAlgorithmNotifier.value,
              ),
            );
          },
        ),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: _Slider(
              valueNotifier: passwordLengthNotifier,
              title: "Password length",
              icon: kIconPassword,
              min: 8,
              max: 20,
            ),
          ),
          const Divider(),
          Container(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: _Slider(
              valueNotifier: pinLengthNotifier,
              title: "PIN length",
              icon: kIconPin,
              min: 3,
              max: 10,
            ),
          ),
          const Divider(),
          Container(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: _Algorithms(valueNotifier: hashAlgorithmNotifier),
          ),
          const Divider(),
          buildItem(
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

  Widget buildItem(
    BuildContext context, {
    String title,
    IconData icon,
    String value,
    BoxDecoration decoration,
  }) {
    return InkWell(
      onTap: () {
        _onItemPressed(value);
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 4.0),
        decoration: decoration,
        child: _Caption(
          icon: icon,
          title: title,
        ),
      ),
    );
  }

  void _onItemPressed(String value) {
    switch (value) {
      case "about":
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              children: <Widget>[
                Container(
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
}

class _Slider extends StatelessWidget {
  _Slider({
    @required this.valueNotifier,
    @required this.icon,
    @required this.title,
    @required this.min,
    @required this.max,
  });

  final ValueNotifier<int> valueNotifier;
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
        ValueListenableBuilder<int>(
          valueListenable: valueNotifier,
          builder: (BuildContext context, int value, Widget child) {
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

class _Algorithms extends StatefulWidget {
  _Algorithms({
    @required this.valueNotifier,
  });

  final ValueNotifier<HashAlgorithm> valueNotifier;

  @override
  _AlgorithmsState createState() => _AlgorithmsState();
}

class _AlgorithmsState extends State<_Algorithms> {
  bool confirmChanging = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<HashAlgorithm>(
      valueListenable: widget.valueNotifier,
      builder: (BuildContext context, HashAlgorithm value, Widget child) {
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
              groupValue: value,
              onChanged: _onHashAlgorithmChanged,
            ),
            RadioListTile<HashAlgorithm>(
              title: const Text("SHA512"),
              value: HashAlgorithm.sha512,
              groupValue: value,
              onChanged: _onHashAlgorithmChanged,
            ),
          ],
        );
      },
    );
  }

  void _onHashAlgorithmChanged(HashAlgorithm value) {
    if (confirmChanging) {
      widget.valueNotifier.value = value;
      return;
    }

    showDialog<bool>(
      context: context,
      child: AlertDialog(
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
      ),
    ).then((bool confirm) {
      if (confirm) {
        confirmChanging = true;
        widget.valueNotifier.value = value;
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
    const double fontSize = 18.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            size: fontSize,
          ),
          const SizedBox(width: 8.0),
          Text(
            title,
            style: const TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
