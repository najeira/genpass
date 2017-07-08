import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:crypto/crypto.dart' as crypto;

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

class GenPassPageState extends State<GenPassPage> {
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
  
  @override
  void initState() {
    super.initState();
    siteTextController = new TextEditingController();
    passTextController = new TextEditingController();
  }
  
  @override
  void dispose() {
    super.dispose();
    siteTextController.dispose();
    passTextController.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final bool validSite = (siteError == null || siteError.isEmpty);
    final bool validPass = (passError == null || passError.isEmpty);
    final bool valid = validSite && validPass;
    
    final String siteText = siteTextController.text ?? "";
    final String passText = passTextController.text ?? "";
    final String hashText = valid ? generatePassword(siteText, passText) : "";
    final String pinText = valid ? generatePin(siteText, passText) : "";
    
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
              onPressed: null,
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
                Clipboard.setData(new ClipboardData(text: hashText)).then((Null _){
                  scaffoldKey.currentState.showSnackBar(new SnackBar(
                    content: new Text("Password copied to clipboard")));
                }).catchError((ex) {
                  debugPrint(ex.toString());
                });
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
                Clipboard.setData(new ClipboardData(text: pinText)).then((Null _){
                  scaffoldKey.currentState.showSnackBar(new SnackBar(
                    content: new Text("PIN copied to clipboard")));
                }).catchError((ex) {
                  debugPrint(ex.toString());
                });
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
  
  void onSettingsPressed() {
    Navigator.of(context)?.push(
      new MaterialPageRoute(
        builder: (BuildContext context) {
          return new SettingsPage();
        }),
    );
  }
  
  // Super Gen Pass Algorithm
  static String generatePassword(String domain, String password) {
    final String secret = "";
    final String targetText = "${password}${secret}:${domain}";
    final String generated = hashRound(targetText, 10, crypto.md5, 10);
    return generated;
  }
  
  static String hashPassword(String input, crypto.Hash hash) {
    var digest = hash.convert(input.codeUnits);
    var output = BASE64.encode(digest.bytes);
    output = output.replaceAll(r"+", r"9");
    output = output.replaceAll(r"/", r"8");
    output = output.replaceAll(r"=", r"A");
    return output;
  }
  
  static bool validatePassword(String value) {
    return value.startsWith(new RegExp(r"[a-z]")) &&
      value.contains(new RegExp(r"[A-Z]")) &&
      value.contains(new RegExp(r"[0-9]"));
  }
  
  static String hashRound(String input, int length, crypto.Hash hash, int round) {
    if (round > 0 || !validatePassword(input)) {
      return hashRound(hashPassword(input, hash), length, hash, round - 1);
    }
    return input.substring(0, length);
  }
  
  // OATH HOTP Algorithm
  static String generateOtp(String domain, String secret) {
    var hmac = new crypto.Hmac(crypto.sha1, secret.codeUnits);
    var digest = hmac.convert(domain.codeUnits);
    var hash = digest.bytes;
    final int offset = hash[hash.length - 1] & 0xf;
    final int binary = (((hash[offset] & 0x7f) << 24)
    | ((hash[offset + 1] & 0xff) << 16)
    | ((hash[offset + 2] & 0xff) << 8)
    | (hash[offset + 3] & 0xff));
    final int otp = binary % digitsPower[4];
    var result = otp.toString();
    while (result.length < 4) {
      result = "0" + result;
    }
    return result;
  }
  
  static String generatePin(String domain, String password) {
    var pin = generateOtp(domain, password);
    int suffix = 0;
    int loopOverrun = 0;
    while (!validatePin(pin)) {
      final String suffixedDomain = "${domain} ${suffix.toString()}";
      pin = generateOtp(suffixedDomain, password);
      loopOverrun++;
      suffix++;
      if (loopOverrun > 100) {
        return "";
      }
    }
    return pin;
  }
  
  static bool validatePin(String pin) {
    if (pin.length == 4) {
      final int start = int.parse(pin.substring(0, 2));
      final int end = int.parse(pin.substring(2, 4));
      if (start == 19 || (start == 20 && end < 30)) {
        // 19xx pins look like years, so might as well ditch them.
        return false;
      } else if (start == end) {
        return false;
      }
    }
    
    if (pin.length % 2 == 0) {
      bool paired = true;
      for (int i = 0; i < pin.length - 1; i += 2) {
        if (pin.codeUnitAt(i) != pin.codeUnitAt(i + 1)) {
          paired = false;
        }
      }
      if (paired) {
        return false;
      }
    }
    
    if (isNumericalRun(pin)) {
      return false;
    } else if (isIncompleteNumericalRun(pin)) {
      return false;
    } else if (blacklistedPins.contains(pin)) {
      return false;
    }
    return true;
  }
  
  static bool isNumericalRun(String pin) {
    int prevDigit = int.parse(pin[0]);
    int prevDiff = 0x7FFFFFFF;
    bool isRun = true; // assume it's true...
    for (int i = 1; isRun && i < pin.length; i++) {
      final int digit = int.parse(pin[i]);
      final int diff = digit - prevDigit;
      if (prevDiff != 0x7FFFFFFF && diff != prevDiff) {
        isRun = false; // ... and prove it's false
      }
      prevDiff = diff;
      prevDigit = digit;
    }
    return isRun;
  }
  
  static bool isIncompleteNumericalRun(String pin) {
    int consecutive = 0;
    int last = pin.codeUnitAt(0);
    for (int i = 1; i < pin.length; i++) {
      final int c = pin.codeUnitAt(i);
      if (last == c) {
        consecutive++;
      } else {
        consecutive = 0;
      }
      last = c;
      if (consecutive >= 2) {
        return true;
      }
    }
    return false;
  }
  
  static final List<int> digitsPower = [
    1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000];
  
  static final List<String> blacklistedPins = <String>[
    "90210", "8675309" /* Jenny */, "1004" /* 10-4 */,
    // in this document http://www.datagenetics.com/blog/september32012/index.html
    // these were shown to be the least commonly used. Now they won't be used at all.
    "8068", "8093", "9629", "6835", "7637", "0738", "8398", "6793", "9480", "8957", "0859",
    "7394", "6827", "6093", "7063", "8196", "9539", "0439", "8438", "9047", "8557"
  ];
}

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new SettingsPageState();
  }
}

class SettingsPageState extends State<SettingsPage> {
  HashAlgorithm hashAlgorithm = HashAlgorithm.md5;
  
  bool confirmAlgorithm = false;
  int passwordLength = 10;
  int pinLength = 4;
  
  @override
  Widget build(BuildContext context) {
    final BoxDecoration decoration = new BoxDecoration(
      border: new Border(
        bottom: new BorderSide(color: Colors.grey[400], width: 1.0)),
    );
    
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Settings"),
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
      case "help":
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

enum HashAlgorithm {
  md5,
  sha1,
  sha256,
}

class Settings {
  int passwordLength;
  int pinLength;
  HashAlgorithm hashAlgorithm;
}
