import 'package:flutter/material.dart';

import 'service.dart';

class SettingsPage extends StatefulWidget {
  final Settings settings;
  
  SettingsPage(this.settings);
  
  @override
  State<StatefulWidget> createState() {
    return new SettingsPageState();
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
    final BoxDecoration decoration = new BoxDecoration(
      border: new Border(
        bottom: new BorderSide(color: Colors.grey[400], width: 1.0)),
    );
    
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Settings"),
        leading: new IconButton(
          icon: const BackButtonIcon(),
          tooltip: 'Back',
          onPressed: () {
            Navigator.of(context).maybePop(new Settings(
              passwordLength: passwordLength,
              pinLength: pinLength,
              hashAlgorithm: hashAlgorithm,
            ));
          }
        ),
      ),
      body: new ListView(
        children: <Widget>[
          new Container(
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
          new Container(
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
          new Container(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
            decoration: decoration,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text("Algorithms", style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                )),
                new RadioListTile<HashAlgorithm>(
                  title: new Text("MD5"),
                  value: HashAlgorithm.md5,
                  groupValue: hashAlgorithm,
                  onChanged: onHashAlgorithmChanged,
                ),
                new RadioListTile<HashAlgorithm>(
                  title: new Text("SHA1"),
                  value: HashAlgorithm.sha1,
                  groupValue: hashAlgorithm,
                  onChanged: onHashAlgorithmChanged,
                ),
                new RadioListTile<HashAlgorithm>(
                  title: new Text("SHA256"),
                  value: HashAlgorithm.sha256,
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
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Text(title, style: const TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w500,
        )),
        new Slider(
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
    return new InkWell(
      onTap: () {
        onItemPressed(value);
      },
      child: new Container(
        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
        decoration: decoration,
        child: new Text(title, style: const TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w500,
        )),
      ),
    );
  }
  
  void onItemPressed(String value) {
    switch (value) {
      case "about":
        showDialog(context: context, child: new SimpleDialog(
          children: <Widget>[
            new Container(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
              child: new Text("Icon made by Freepik from www.flaticon.com"),
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
      child: new AlertDialog(
        content: new Text(
          "Changing the algorithm changes the generated password.",
          maxLines: null),
        actions: <Widget>[
          new FlatButton(
            child: new Text("Cacel"),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          new FlatButton(
            child: new Text("OK"),
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
