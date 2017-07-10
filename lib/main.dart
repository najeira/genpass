import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'crypto.dart';
import 'service.dart';

import 'history.dart';
import 'settings.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Gen Pass',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new GenPassPage(),
    );
  }
}

class GenPassPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new GenPassPageState();
  }
}

class GenPassPageState extends State<GenPassPage> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  
  final GlobalKey<FormFieldState<String>> siteTextKey = new GlobalKey<FormFieldState<String>>();
  TextEditingController siteTextController;
  String siteError;
  
  final GlobalKey<FormFieldState<String>> passTextKey = new GlobalKey<FormFieldState<String>>();
  TextEditingController passTextController;
  String passError;
  
  bool showPassword = false;
  bool showHash = false;
  bool showPin = false;
  
  Settings settings = new Settings();
  
  History history;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    siteTextController = new TextEditingController();
    passTextController = new TextEditingController();
    
    // load from preference.
    Settings.load().then((Settings settings) {
      setState(() {
        this.settings = settings;
      });
    });
    
    History.load().then((History history) {
      this.history = history;
    });
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    siteTextController.dispose();
    passTextController.dispose();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      if (addHistory()) {
        History.save(history).then((_) {
          debugPrint("history saved");
        }).catchError((ex) {
          debugPrint(ex.toString());
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final String siteText = siteTextController.text ?? "";
    siteError = validateSiteValue(siteText);
    
    final String passText = passTextController.text ?? "";
    passError = validatePassValue(passText);
    
    final bool validSite = (siteError == null || siteError.isEmpty);
    final bool validPass = (passError == null || passError.isEmpty);
    final bool valid = validSite && validPass;
    
    final String hashText = valid ? Crypto.generatePassword(
      settings.hashAlgorithm, siteText, passText, settings.passwordLength) : "";
    final String pinText = valid ? Crypto.generatePin(
      siteText, passText, settings.pinLength) : "";
    
    return new Scaffold(
      key: scaffoldKey,
      appBar: new AppBar(
        leading: new Icon(Icons.business_center),
        title: new Text("Gen Pass"),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.settings),
            onPressed: onSettingsPressed,
          ),
        ],
      ),
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
            padding: const EdgeInsets.fromLTRB(2.0, 4.0, 8.0, 2.0),
            child: buildInputRow(context,
              key: siteTextKey,
              controller: siteTextController,
              inputIcon: Icons.business,
              labelText: "domain / site",
              hintText: "example.com",
              errorText: siteError,
              onChanged: (String value) {
                setState(() {
                  siteError = validateSiteValue(value);
                });
              },
              actionIcon: Icons.assignment,
              onPressed: onHistoryPressed,
            ),
          ),
          new Container(
            padding: const EdgeInsets.fromLTRB(2.0, 2.0, 8.0, 16.0),
            child: buildInputRow(context,
              key: passTextKey,
              controller: passTextController,
              inputIcon: Icons.bubble_chart,
              labelText: "password",
              hintText: "your master password",
              errorText: passError,
              obscureText: !showPassword,
              onChanged: (String value) {
                setState(() {
                  passError = validatePassValue(value);
                });
              },
              actionIcon: showPassword ? Icons.visibility : Icons.visibility_off,
              onPressed: () {
                setState(() {
                  showPassword = !showPassword;
                });
              },
            ),
          ),
          new Container(
            margin: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
            padding: const EdgeInsets.fromLTRB(8.0, 16.0, 0.0, 4.0),
            decoration: new BoxDecoration(
              border: new Border(
                top: new BorderSide(color: Colors.grey[300], width: 1.0)),
            ),
            child: buildPasswordRow(
              context,
              icon: Icons.vpn_key,
              value: hashText,
              obscure: !showHash,
              onVisibilityChanged: () {
                setState(() {
                  showHash = !showHash;
                });
              },
              onCopy: () {
                copyTextToClipboard("Password", hashText);
              },
            ),
          ),
          new Container(
            padding: const EdgeInsets.fromLTRB(16.0, 4.0, 8.0, 4.0),
            child: buildPasswordRow(
              context,
              icon: Icons.casino,
              value: pinText,
              obscure: !showPin,
              onVisibilityChanged: () {
                setState(() {
                  showPin = !showPin;
                });
              },
              onCopy: () {
                copyTextToClipboard("PIN", pinText);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget buildInputRow(BuildContext context, {
    Key key,
    TextEditingController controller,
    IconData inputIcon,
    String labelText,
    String hintText,
    String errorText,
    bool obscureText,
    ValueChanged<String> onChanged,
    IconData actionIcon,
    VoidCallback onPressed,
  }) {
    final ThemeData themeData = Theme.of(context);
    final TextStyle inputStyle = themeData.textTheme.subhead;
    return new Row(
      children: <Widget>[
        new Expanded(child: new TextField(
          key: key,
          controller: controller,
          decoration: new InputDecoration(
            icon: new Icon(inputIcon, size: 24.0),
            labelText: labelText,
            hintText: hintText,
            errorText: errorText,
          ),
          style: inputStyle.copyWith(
            fontSize: 18.0,
          ),
          keyboardType: TextInputType.emailAddress,
          obscureText: obscureText ?? false,
          onChanged: onChanged,
        )),
        new IconButton(
          icon: new Icon(
            actionIcon,
            size: 28.0,
            color: themeData.primaryColor,
          ),
          onPressed: onPressed,
        ),
      ],
    );
  }
  
  Widget buildPasswordRow(BuildContext context, {
    IconData icon,
    String value,
    bool obscure,
    VoidCallback onVisibilityChanged,
    VoidCallback onCopy,
  }) {
    final ThemeData themeData = Theme.of(context);
    final bool valid = ((value != null) && value.isNotEmpty);
    final Color iconColor = valid ? themeData.primaryColor : Colors.grey[300];
    if (valid) {
      if (obscure) {
        value = "*".padRight(value.length, "*");
      }
    }
    return new Row(
      children: <Widget>[
        new Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: new Icon(icon,
            size: 24.0,
            color: valid ? Colors.grey[800] : Colors.grey[500],
          ),
        ),
        new Expanded(child: new Text(value ?? "", style: const TextStyle(
          fontSize: 18.0,
        ))),
        new IconButton(icon: new Icon(
          obscure ? Icons.visibility_off : Icons.visibility,
          size: 28.0,
          color: iconColor,
        ), onPressed: valid ? onVisibilityChanged : null),
        new IconButton(icon: new Icon(
          Icons.content_copy,
          size: 28.0,
          color: iconColor,
        ), onPressed: valid ? onCopy : null),
      ],
    );
  }
  
  String validateSiteValue(String value) {
    if (value == null || value.isEmpty) {
      return "enter domain/site";
    }
    return null;
  }
  
  String validatePassValue(String value) {
    if (value == null || value.isEmpty) {
      return "enter keyword";
    } else if (value.length < 8) {
      return "over 8 characters";
    }
    return null;
  }
  
  void onHistoryPressed() {
    final String siteText = siteTextController.text;
    var future = Navigator.of(context)?.push(
      new MaterialPageRoute<String>(
        builder: (BuildContext context) {
          return new HistoryPage(text: siteText, history: history);
        },
      ),
    );
    future.then((String siteText) {
      if (siteText != null && siteText.isNotEmpty) {
        setState(() {
          this.siteTextController.text = siteText;
        });
      }
    });
  }
  
  void onSettingsPressed() {
    var future = Navigator.of(context)?.push(
      new MaterialPageRoute<Settings>(
        builder: (BuildContext context) {
          return new SettingsPage(settings);
        },
      ),
    );
    future.then((Settings settings) {
      if (settings == null) {
        return;
      }
      setState(() {
        this.settings = settings;
      });
      Settings.save(settings).then((_) {
        debugPrint("settings saved");
      }).catchError((ex) {
        debugPrint(ex.toString());
      });
    });
  }
  
  bool addHistory() {
    final bool validSite = (siteError == null || siteError.isEmpty);
    final bool validPass = (passError == null || passError.isEmpty);
    if (!validSite || !validPass) {
      return false;
    }
    final String siteText = siteTextController.text;
    if (siteText == null || siteText.isEmpty) {
      return false;
    }
    history.add(siteText);
    return true;
  }
  
  void copyTextToClipboard(String title, String text) {
    Clipboard.setData(new ClipboardData(text: text)).then((_) {
      scaffoldKey.currentState?.showSnackBar(new SnackBar(
        content: new Text("${title} copied to clipboard")));
      addHistory();
    }).catchError((ex) {
      debugPrint(ex.toString());
    });
  }
}
