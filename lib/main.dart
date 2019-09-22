import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import 'history.dart';
import 'model.dart';
import 'service.dart';
import 'settings.dart';

const String kAppName = "Gen Pass";

void main() {
  runApp(MaterialApp(
    title: kAppName,
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: GenPassPage(),
  ));
}

class GenPassPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GenPassPageState();
  }
}

class _GenPassPageState extends State<GenPassPage> with WidgetsBindingObserver {
  final GenPassData data = GenPassData();

  History history;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // load from preference.
    Settings.load().then((Settings settings) {
      data.settingsNotifier.value = settings;
    });

    History.load().then((History history) {
      this.history = history;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    data?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      if (_addHistory()) {
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
              child: _MasterInputRow(
                textNotifier: data.masterNotifier,
                errorNotifier: data.masterErrorNotifier,
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 16.0),
              child: _DomainInputRow(
                textNotifier: data.domainNotifier,
                errorNotifier: data.domainErrorNotifier,
                onPressed: _onHistoryPressed,
              ),
            ),
            const Divider(),
            Container(
              padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 0.0),
              child: _ResultRow(
                icon: Icons.vpn_key,
                textNotifier: data.passNotifier,
                onCopy: (String value) {
                  _onCopyTextToClipboard(context, "Password", value);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
              child: _ResultRow(
                icon: Icons.casino,
                textNotifier: data.pinNotifier,
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

  Future<void> _onCopyTextToClipboard(BuildContext context, String title, String text) {
    _copyTextToClipboard(context, title, text).then((_) {
      _addHistory();
    });
  }

  void _onHistoryPressed() {
    Navigator.of(context)?.push(
      MaterialPageRoute<String>(
        builder: (BuildContext context) {
          return HistoryPage(
            text: data.domainNotifier.value,
            history: history,
          );
        },
      ),
    )?.then((String domainText) {
      if (domainText != null && domainText.isNotEmpty) {
        debugPrint("domainText is ${domainText}");
        data.domainNotifier.value = domainText;
      }
    });
  }

  void _onSettingsPressed() {
    Navigator.of(context)?.push(
      MaterialPageRoute<Settings>(
        builder: (BuildContext context) {
          return SettingsPage(data.settingsNotifier.value);
        },
      ),
    )?.then((Settings settings) {
      if (settings == null) {
        return;
      }
      data.settingsNotifier.value = settings;
      Settings.save(settings).then((_) {
        debugPrint("settings saved");
      }).catchError((Object ex) {
        debugPrint(ex.toString());
      });
    });
  }

  bool _addHistory() {
    final String domainText = data.domainNotifier.value;
    if (domainText == null || domainText.isEmpty) {
      return false;
    }
    history.add(domainText);
    return true;
  }
}

class _MasterInputRow extends StatelessWidget {
  _MasterInputRow({
    Key key,
    this.textNotifier,
    this.errorNotifier,
  }) : super(key: key);

  final ValueNotifier<String> textNotifier;
  final ValueNotifier<String> errorNotifier;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ValueNotifier<bool>>(
      builder: (BuildContext context) => ValueNotifier<bool>(false),
      child: Consumer<ValueNotifier<bool>>(
        builder: (BuildContext context, ValueNotifier<bool> showNotifier, Widget child) {
          final bool show = showNotifier.value ?? false;
          return _InputRow(
            textNotifier: textNotifier,
            errorNotifier: errorNotifier,
            textInputType: TextInputType.visiblePassword,
            inputIcon: Icons.bubble_chart,
            labelText: "password",
            hintText: "your master password",
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

class _DomainInputRow extends StatelessWidget {
  _DomainInputRow({
    Key key,
    @required this.textNotifier,
    @required this.errorNotifier,
    @required this.onPressed,
  }) : super(key: key);

  final ValueNotifier<String> textNotifier;
  final ValueNotifier<String> errorNotifier;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _InputRow(
      textNotifier: textNotifier,
      errorNotifier: errorNotifier,
      textInputType: TextInputType.url,
      inputIcon: Icons.business,
      labelText: "domain / site",
      hintText: "example.com",
      actionIcon: Icons.assignment,
      onPressed: onPressed,
    );
  }
}

class _InputRow extends StatefulWidget {
  _InputRow({
    Key key,
    @required this.textNotifier,
    @required this.errorNotifier,
    @required this.inputIcon,
    @required this.textInputType,
    @required this.labelText,
    @required this.hintText,
    this.obscureText = false,
    @required this.actionIcon,
    @required this.onPressed,
  }) : super(key: key);

  final ValueNotifier<String> textNotifier;
  final ValueNotifier<String> errorNotifier;
  final IconData inputIcon;
  final TextInputType textInputType;
  final String labelText;
  final String hintText;
  final bool obscureText;
  final IconData actionIcon;
  final VoidCallback onPressed;

  @override
  _InputRowState createState() => _InputRowState();
}

class _InputRowState extends State<_InputRow> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final TextStyle inputStyle = themeData.textTheme.subhead;
    return ValueListenableBuilder(
      valueListenable: widget.errorNotifier,
      builder: (BuildContext context, String error, Widget child) {
        return ValueListenableBuilder(
          valueListenable: widget.textNotifier,
          builder: (BuildContext context, String text, Widget child) {
            if (controller.text != text) {
              controller.text = text;
            }
            return Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      icon: Icon(widget.inputIcon, size: 24.0),
                      labelText: widget.labelText,
                      hintText: widget.hintText,
                      errorText: error,
                    ),
                    style: inputStyle.copyWith(
                      fontSize: 18.0,
                    ),
                    keyboardType: widget.textInputType,
                    obscureText: widget.obscureText ?? false,
                    onChanged: (String value) {
                      widget.textNotifier.value = value;
                    },
                    onSubmitted: (String value) {
                      widget.textNotifier.value = value;
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(
                    widget.actionIcon,
                    size: 28.0,
                    color: themeData.primaryColor,
                  ),
                  onPressed: widget.onPressed,
                ),
              ],
            );
          },
        );
      },
    );
  }
}

typedef _CopyCallback = void Function(String);

class _ResultRow extends StatelessWidget {
  _ResultRow({
    Key key,
    @required this.textNotifier,
    @required this.icon,
    @required this.onCopy,
  }) : super(key: key);

  final ValueNotifier<String> textNotifier;
  final IconData icon;
  final _CopyCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ValueNotifier<bool>>(
      builder: (BuildContext context) => ValueNotifier<bool>(false),
      child: Consumer<ValueNotifier<bool>>(
        builder: (BuildContext context, ValueNotifier<bool> showNotifier, Widget child) {
          return ValueListenableBuilder<String>(
            valueListenable: textNotifier,
            builder: (BuildContext context, String text, Widget child) {
              return _buildRow(
                context,
                showNotifier: showNotifier,
                text: text,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRow(
    BuildContext context, {
    ValueNotifier<bool> showNotifier,
    String text,
  }) {
    final ThemeData themeData = Theme.of(context);
    final bool valid = ((text != null) && text.isNotEmpty);
    final Color textColor = valid ? themeData.textTheme.caption.color : themeData.disabledColor;
    final Color iconColor = valid ? themeData.primaryColor : themeData.disabledColor;
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
            color: textColor,
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
