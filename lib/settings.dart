import 'package:flutter/material.dart';

import 'service.dart';

class SettingsPage extends StatefulWidget {
  final Settings settings;
  
  SettingsPage(this.settings);
  
  @override
  State<StatefulWidget> createState() {
    return SettingsPageState();
  }
}

class SettingsPageState extends State<SettingsPage> {
  bool confirmAlgorithm = false;
  
  int passwordLength = 10;
  int pinLength = 4;
  HashAlgorithm hashAlgorithm = HashAlgorithm.md5;
  
  @override
  void initState() {
    super.initState();
    passwordLength = widget.settings.passwordLength;
    pinLength = widget.settings.pinLength;
    hashAlgorithm = widget.settings.hashAlgorithm;
  }
  
  @override
  Widget build(BuildContext context) {
    final BoxDecoration decoration = BoxDecoration(
      border: Border(
        bottom: BorderSide(color: Colors.grey[400], width: 1.0)),
    );
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        leading: IconButton(
          icon: const BackButtonIcon(),
          tooltip: 'Back',
          onPressed: () {
            Navigator.of(context).maybePop(Settings(
              passwordLength: passwordLength,
              pinLength: pinLength,
              hashAlgorithm: hashAlgorithm,
            ));
          }
        ),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            decoration: decoration,
            child: buildSlider(
              context,
              title: "Password length",
              value: passwordLength,
              min: 8,
              max: 20,
              onChanged: (int value) {
                setState(() {
                  passwordLength = value;
                });
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            decoration: decoration,
            child: buildSlider(
              context,
              title: "PIN length",
              value: pinLength,
              min: 3,
              max: 10,
              onChanged: (int value) {
                setState(() {
                  pinLength = value;
                });
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
            decoration: decoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Algorithms", style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                )),
                RadioListTile<HashAlgorithm>(
                  title: Text("MD5"),
                  value: HashAlgorithm.md5,
                  groupValue: hashAlgorithm,
                  onChanged: onHashAlgorithmChanged,
                ),
                RadioListTile<HashAlgorithm>(
                  title: Text("SHA512"),
                  value: HashAlgorithm.sha512,
                  groupValue: hashAlgorithm,
                  onChanged: onHashAlgorithmChanged,
                ),
              ],
            ),
          ),
          buildItem(context, title: "About", value: "about", decoration: decoration),
        ],
      ),
    );
  }
  
  Widget buildSlider(BuildContext context, {
    String title,
    int value,
    int min,
    int max,
    ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: const TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w500,
        )),
        Slider(
          label: value.toString(),
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: (max - min),
          onChanged: (double value) {
            if (onChanged != null) {
              onChanged(value.toInt());
            }
          },
        ),
      ],
    );
  }
  
  Widget buildItem(BuildContext context, {
    String title,
    String value,
    BoxDecoration decoration,
  }) {
    return InkWell(
      onTap: () {
        onItemPressed(value);
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
        decoration: decoration,
        child: Text(title, style: const TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w500,
        )),
      ),
    );
  }
  
  void onItemPressed(String value) {
    switch (value) {
      case "about":
        showDialog(context: context, child: SimpleDialog(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
              child: Text("Icon made by Freepik from www.flaticon.com"),
            ),
          ],
        ));
        break;
    }
  }
  
  void onHashAlgorithmChanged(HashAlgorithm value) {
    if (confirmAlgorithm) {
      setState(() {
        hashAlgorithm = value;
      });
      return;
    }
    
    var future = showDialog<bool>(
      context: context,
      child: AlertDialog(
        content: Text(
          "Changing the algorithm changes the generated password.",
          maxLines: null),
        actions: <Widget>[
          FlatButton(
            child: Text("Cacel"),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          FlatButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    );
    future.then((bool confirm) {
      if (confirm) {
        setState(() {
          confirmAlgorithm = true;
          hashAlgorithm = value;
        });
      }
    });
  }
}
