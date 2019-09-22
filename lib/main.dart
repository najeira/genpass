import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import 'history.dart';
import 'model.dart';
import 'service.dart';
import 'settings.dart';

const String kAppName = "Gen Pass";
const double kFontSize = 18.0;

void main() {
  runApp(MaterialApp(
    title: kAppName,
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: GenPassPage(),
  ));
}

class _MasterTextEditingController extends TextEditingController {}

class _DomainTextEditingController extends TextEditingController {}

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
    return MultiProvider(
      providers: [
        ListenableProvider<_MasterTextEditingController>(
          builder: (BuildContext context) => _MasterTextEditingController(),
        ),
        ListenableProvider<_DomainTextEditingController>(
          builder: (BuildContext context) => _DomainTextEditingController(),
        ),
      ],
      child: _build(context),
    );
  }

  Widget _build(BuildContext context) {
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
              child: MultiProvider(
                providers: [
                  ChangeNotifierProvider<ValueNotifier<String>>.value(value: data.masterNotifier),
                  ValueListenableProvider<String>.value(value: data.masterErrorNotifier),
                ],
                child: _MasterInputRow(),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 16.0),
              child: MultiProvider(
                providers: [
                  ChangeNotifierProvider<ValueNotifier<String>>.value(value: data.domainNotifier),
                  ValueListenableProvider<String>.value(value: data.domainErrorNotifier),
                ],
                child: _DomainInputRow(
                  onPressed: _onHistoryPressed,
                ),
              ),
            ),
            const Divider(),
            Container(
              padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 0.0),
              child: ValueListenableProvider<String>.value(
                value: data.passNotifier,
                child: _ResultRow(
                  icon: kIconPassword,
                  onCopy: (String value) {
                    _onCopyTextToClipboard(context, "Password", value);
                  },
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
              child: ValueListenableProvider<String>.value(
                value: data.pinNotifier,
                child: _ResultRow(
                  icon: kIconPin,
                  onCopy: (String value) {
                    _onCopyTextToClipboard(context, "PIN", value);
                  },
                ),
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
          return SettingsPage(settings: data.settingsNotifier.value);
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ListenableProvider<TextEditingController>.value(
          value: Provider.of<_MasterTextEditingController>(context, listen: false),
        ),
        ChangeNotifierProvider<ValueNotifier<bool>>(
          builder: (BuildContext context) => ValueNotifier<bool>(false),
        ),
      ],
      child: Consumer<ValueNotifier<bool>>(
        builder: (BuildContext context, ValueNotifier<bool> showNotifier, Widget child) {
          final bool show = showNotifier.value ?? false;
          return _InputRow(
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
    @required this.onPressed,
  }) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ListenableProvider<TextEditingController>.value(
      value: Provider.of<_DomainTextEditingController>(context, listen: false),
      child: _InputRow(
        textInputType: TextInputType.url,
        inputIcon: Icons.business,
        labelText: "domain / site",
        hintText: "example.com",
        actionIcon: Icons.assignment,
        onPressed: onPressed,
      ),
    );
  }
}

class _InputRow extends StatelessWidget {
  _InputRow({
    Key key,
    @required this.inputIcon,
    @required this.textInputType,
    @required this.labelText,
    @required this.hintText,
    this.obscureText = false,
    @required this.actionIcon,
    @required this.onPressed,
  }) : super(key: key);

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
    return Row(
      children: <Widget>[
        Expanded(
          child: _buildTextField(context),
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
  }

  Widget _buildTextField(BuildContext context) {
    return Consumer2<TextEditingController, String>(
      builder: (
        BuildContext context,
        TextEditingController controller,
        String errorText,
        Widget child,
      ) {
        return TextField(
          controller: controller,
          decoration: InputDecoration(
            icon: Icon(inputIcon, size: 24.0),
            labelText: labelText,
            hintText: hintText,
            errorText: errorText,
          ),
          style: const TextStyle(
            fontSize: kFontSize,
          ),
          keyboardType: textInputType,
          obscureText: obscureText ?? false,
          onChanged: (String value) => _onTextChanged(context, value),
          onSubmitted: (String value) => _onTextChanged(context, value),
        );
      },
    );
  }

  void _onTextChanged(BuildContext context, String value) {
    Provider.of<ValueNotifier<String>>(context, listen: false)?.value = value;
  }
}

typedef _CopyCallback = void Function(String);

class _ResultRow extends StatelessWidget {
  _ResultRow({
    Key key,
    @required this.icon,
    @required this.onCopy,
  }) : super(key: key);

  final IconData icon;

  final _CopyCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ValueNotifier<bool>>(
      builder: (BuildContext context) => ValueNotifier<bool>(false),
      child: Consumer2<String, ValueNotifier<bool>>(
        builder: (
          BuildContext context,
          String text,
          ValueNotifier<bool> showNotifier,
          Widget child,
        ) {
          return _buildRow(
            context,
            showNotifier: showNotifier,
            text: text,
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
              fontSize: kFontSize,
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
