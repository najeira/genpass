import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import 'crypto.dart';
import 'service.dart';

import 'history.dart';
import 'settings.dart';

const String kAppName = "Gen Pass";

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GenPassPage(),
    );
  }
}

class GenPassPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return GenPassPageState();
  }
}

class GenPassPageState extends State<GenPassPage> with WidgetsBindingObserver {
  final ValueNotifier<Settings> _settingsNotifier = ValueNotifier<Settings>(Settings());
  final ValueNotifier<String> _siteNotifier = ValueNotifier<String>("");
  final ValueNotifier<String> _passNotifier = ValueNotifier<String>("");

  History history;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // load from preference.
    Settings.load().then((Settings settings) {
      _settingsNotifier.value = settings;
    });

    History.load().then((History history) {
      this.history = history;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _settingsNotifier?.dispose();
    _siteNotifier?.dispose();
    _passNotifier?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      if (addHistory()) {
        History.save(history).then((_) {
          debugPrint("history saved");
        }).catchError((Object ex) {
          debugPrint(ex.toString());
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(kAppName),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _onSettingsPressed,
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
              child: _PassInputRow(textNotifier: _passNotifier),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
              child: _SiteInputRow(
                textNotifier: _siteNotifier,
                onPressed: _onHistoryPressed,
              ),
            ),
            const Divider(),
            Container(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
              child: _ResultRow(
                icon: Icons.vpn_key,
                settingsNotifier: _settingsNotifier,
                passNotifier: _passNotifier,
                siteNotifier: _siteNotifier,
                generator: _generatePassword,
                onCopy: (String value) {
                  _onCopyTextToClipboard(context, "Password", value);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
              child: _ResultRow(
                icon: Icons.casino,
                settingsNotifier: _settingsNotifier,
                passNotifier: _passNotifier,
                siteNotifier: _siteNotifier,
                generator: _generatePin,
                onCopy: (String value) {
                  _onCopyTextToClipboard(context, "PIN", value);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  String _generatePassword(Settings settings, String password, String site) {
    if (_Validator.validatePassword(password) != null) {
      return null;
    }
    if (_Validator.validateSite(site) != null) {
      return null;
    }
    return Crypto.generatePassword(
      settings.hashAlgorithm,
      site,
      password,
      settings.passwordLength,
    );
  }

  String _generatePin(Settings settings, String password, String site) {
    if (_Validator.validatePassword(password) != null) {
      return null;
    }
    if (_Validator.validateSite(site) != null) {
      return null;
    }
    return Crypto.generatePin(
      site,
      password,
      settings.pinLength,
    );
  }

  Future<void> _onCopyTextToClipboard(BuildContext context, String title, String text) {
    _copyTextToClipboard(context, title, text).then((_) {
      addHistory();
    });
  }

  void _onHistoryPressed() {
    Navigator.of(context)?.push(
      MaterialPageRoute<String>(
        builder: (BuildContext context) {
          return HistoryPage(
            text: _siteNotifier.value,
            history: history,
          );
        },
      ),
    )?.then((String siteText) {
      if (siteText != null && siteText.isNotEmpty) {
        debugPrint("siteText is ${siteText}");
        _siteNotifier.value = siteText;
      }
    });
  }

  void _onSettingsPressed() {
    Navigator.of(context)?.push(
      MaterialPageRoute<Settings>(
        builder: (BuildContext context) {
          return SettingsPage(_settingsNotifier.value);
        },
      ),
    )?.then((Settings settings) {
      if (settings == null) {
        return;
      }
      _settingsNotifier.value = settings;
      Settings.save(settings).then((_) {
        debugPrint("settings saved");
      }).catchError((Object ex) {
        debugPrint(ex.toString());
      });
    });
  }

  bool addHistory() {
    final String siteText = _siteNotifier.value;
    if (siteText == null || siteText.isEmpty) {
      return false;
    }
    history.add(siteText);
    return true;
  }
}

class _PassInputRow extends StatelessWidget {
  _PassInputRow({
    Key key,
    this.textNotifier,
  }) : super(key: key);

  final ValueNotifier<String> textNotifier;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ValueNotifier<bool>>(
      builder: (BuildContext context) => ValueNotifier<bool>(false),
      child: Consumer<ValueNotifier<bool>>(
        builder: (BuildContext context, ValueNotifier<bool> showNotifier, Widget child) {
          final bool show = showNotifier.value ?? false;
          return _InputRow(
            textNotifier: textNotifier,
            textInputType: TextInputType.visiblePassword,
            inputIcon: Icons.bubble_chart,
            labelText: "password",
            hintText: "your master password",
            validator: _Validator.validatePassword,
            obscureText: !show,
            actionIcon: show ? Icons.visibility : Icons.visibility_off,
            onPressed: () {
              showNotifier.value = !show;
            },
          );
        },
      ),
    );
  }
}

class _SiteInputRow extends StatelessWidget {
  _SiteInputRow({
    Key key,
    @required this.textNotifier,
    @required this.onPressed,
  }) : super(key: key);

  final ValueNotifier<String> textNotifier;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _InputRow(
      textNotifier: textNotifier,
      textInputType: TextInputType.url,
      inputIcon: Icons.business,
      labelText: "domain / site",
      hintText: "example.com",
      validator: _Validator.validateSite,
      actionIcon: Icons.assignment,
      onPressed: onPressed,
    );
  }
}

typedef _ValidatorFunc = String Function(String);

class _InputRow extends StatelessWidget {
  _InputRow({
    Key key,
    @required this.textNotifier,
    @required this.validator,
    @required this.inputIcon,
    @required this.textInputType,
    @required this.labelText,
    @required this.hintText,
    this.obscureText = false,
    @required this.actionIcon,
    @required this.onPressed,
  }) : super(key: key);

  final ValueNotifier<String> textNotifier;
  final _ValidatorFunc validator;
  final IconData inputIcon;
  final TextInputType textInputType;
  final String labelText;
  final String hintText;
  final bool obscureText;
  final IconData actionIcon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final TextStyle inputStyle = themeData.textTheme.subhead;
    return ValueListenableBuilder(
      valueListenable: textNotifier,
      builder: (BuildContext context, String text, Widget child) {
        return Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  icon: Icon(inputIcon, size: 24.0),
                  labelText: labelText,
                  hintText: hintText,
                  errorText: validator(text),
                ),
                style: inputStyle.copyWith(
                  fontSize: 18.0,
                ),
                keyboardType: textInputType,
                obscureText: obscureText ?? false,
                onChanged: (String value) {
                  textNotifier.value = value;
                },
                onSubmitted: (String value) {
                  textNotifier.value = value;
                },
              ),
            ),
            IconButton(
              icon: Icon(
                actionIcon,
                size: 28.0,
                color: themeData.primaryColor,
              ),
              onPressed: onPressed,
            ),
          ],
        );
      },
    );
  }
}

typedef _Generator = String Function(Settings, String, String);

typedef _CopyCallback = void Function(String);

class _ResultRow extends StatelessWidget {
  _ResultRow({
    Key key,
    @required this.settingsNotifier,
    @required this.passNotifier,
    @required this.siteNotifier,
    @required this.generator,
    @required this.icon,
    @required this.onCopy,
  }) : super(key: key);

  final ValueNotifier<Settings> settingsNotifier;
  final ValueNotifier<String> passNotifier;
  final ValueNotifier<String> siteNotifier;
  final _Generator generator;
  final IconData icon;
  final _CopyCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Settings>(
      valueListenable: settingsNotifier,
      builder: (BuildContext context, Settings settings, Widget child) {
        return ValueListenableBuilder<String>(
          valueListenable: passNotifier,
          builder: (BuildContext context, String password, Widget child) {
            return ValueListenableBuilder<String>(
              valueListenable: siteNotifier,
              builder: (BuildContext context, String site, Widget child) {
                final String text = generator(settings, password, site);
                return ChangeNotifierProvider<ValueNotifier<bool>>(
                  builder: (BuildContext context) => ValueNotifier<bool>(false),
                  child: Consumer<ValueNotifier<bool>>(
                    builder: (BuildContext context, ValueNotifier<bool> showNotifier, Widget child) {
                      return _buildRow(context, showNotifier: showNotifier, text: text);
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRow(
    BuildContext context, {
    ValueNotifier<bool> showNotifier,
    String text,
  }) {
    final ThemeData themeData = Theme.of(context);
    final bool valid = ((text != null) && text.isNotEmpty);
    final Color iconColor = valid ? themeData.primaryColor : Colors.grey[300];
    final bool show = showNotifier.value ?? false;

    String showText = text;
    if (valid && !show) {
      showText = "*".padRight(text.length, "*");
    }

    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: Icon(
            icon,
            size: 24.0,
            color: valid ? Colors.grey[800] : Colors.grey[500],
          ),
        ),
        Expanded(
          child: Text(
            showText ?? "",
            style: const TextStyle(
              fontSize: 18.0,
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            show ? Icons.visibility : Icons.visibility_off,
            size: 28.0,
            color: iconColor,
          ),
          onPressed: valid
              ? () {
                  showNotifier.value = !show;
                }
              : null,
        ),
        IconButton(
          icon: Icon(
            Icons.content_copy,
            size: 28.0,
            color: iconColor,
          ),
          onPressed: valid
              ? () {
                  onCopy(text);
                }
              : null,
        ),
      ],
    );
  }
}

class _Validator {
  _Validator._();

  static String validatePassword(String value) {
    if (value == null || value.isEmpty || value.length < 8) {
      return "enter 8 or more characters";
    }
    return null;
  }

  static String validateSite(String value) {
    if (value == null || value.isEmpty) {
      return "enter";
    }
    return null;
  }
}

Future<void> _copyTextToClipboard(BuildContext context, String title, String text) {
  return Clipboard.setData(ClipboardData(text: text)).then((_) {
    Scaffold.of(context, nullOk: true)?.showSnackBar(
      SnackBar(
        content: Text("${title} copied to clipboard"),
      ),
    );
  }).catchError((Object ex) {
    debugPrint(ex.toString());
  });
}
