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
    home: const _RootPage(),
  ));
}

class _MasterTextEditingController extends TextEditingController {}

class _DomainTextEditingController extends TextEditingController {}

class _RootPage extends StatelessWidget {
  const _RootPage();

  @override
  Widget build(BuildContext context) {
    final GenPassData data = GenPassData();
    return MultiProvider(
      providers: [
        ListenableProvider<_MasterTextEditingController>(
          builder: (BuildContext context) => _MasterTextEditingController(),
        ),
        ListenableProvider<_DomainTextEditingController>(
          builder: (BuildContext context) => _DomainTextEditingController(),
        ),
        FutureProvider<History>(
          builder: (BuildContext context) => History.load(),
        ),
        FutureProvider<GenPassData>(
          initialData: data,
          builder: (BuildContext context) {
            return Settings.load().then<GenPassData>((Settings settings) {
              data.settingsNotifier.value = settings;
              return data;
            });
          },
        ),
      ],
      child: const GenPassPage(),
    );
  }
}

class GenPassPage extends StatefulWidget {
  const GenPassPage();

  @override
  State<StatefulWidget> createState() {
    return _GenPassPageState();
  }
}

class _GenPassPageState extends State<GenPassPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      if (_addHistory()) {
        Provider.of<History>(context, listen: false)?.save()?.then((_) {
          debugPrint("history saved");
        })?.catchError((Object ex) {
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
        return Consumer<GenPassData>(
          builder: (BuildContext context, GenPassData data, Widget child) {
            return SingleChildScrollView(
              child: _buildColumn(context, data),
            );
          },
        );
      },
    );
  }

  Widget _buildColumn(BuildContext context, GenPassData data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 8.0),
        const _SectionTitle(title: "Form"),
        Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 0.0, 8.0, 0.0),
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider<ValueNotifier<String>>.value(
                value: data.masterNotifier,
              ),
              ValueListenableProvider<String>.value(
                value: data.masterErrorNotifier,
              ),
            ],
            child: const _MasterInputRow(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 8.0, 8.0, 16.0),
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider<ValueNotifier<String>>.value(
                value: data.domainNotifier,
              ),
              ValueListenableProvider<String>.value(
                value: data.domainErrorNotifier,
              ),
            ],
            child: _DomainInputRow(
              onPressed: _onHistoryPressed,
            ),
          ),
        ),
        const Divider(),
        const _SectionTitle(title: "Generator"),
        Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 8.0, 8.0, 0.0),
          child: ValueListenableProvider<String>.value(
            value: data.passNotifier,
            child: _ResultRow(
              title: kTitlePassword,
              icon: kIconPassword,
              onCopy: (String value) {
                _onCopyTextToClipboard(context, kTitlePassword, value);
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 8.0, 8.0, 8.0),
          child: ValueListenableProvider<String>.value(
            value: data.pinNotifier,
            child: _ResultRow(
              title: kTitlePin,
              icon: kIconPin,
              onCopy: (String value) {
                _onCopyTextToClipboard(context, "PIN", value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onCopyTextToClipboard(BuildContext context, String title, String text) {
    return copyTextToClipboard(context, title, text).then<void>((_) {
      return _addHistory();
    });
  }

  void _onHistoryPressed() {
    final History history = Provider.of<History>(context, listen: false);
    if (history == null) {
      debugPrint("History is not provided");
      return;
    }

    final GenPassData data = Provider.of<GenPassData>(context, listen: false);
    if (data == null) {
      debugPrint("GenPassData is not provided");
      return;
    }

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
        final _DomainTextEditingController controller =
            Provider.of<_DomainTextEditingController>(context, listen: false);
        controller.text = domainText;
        data.domainNotifier.value = domainText;
        debugPrint("domainText is ${domainText}");
      }
    });
  }

  void _onSettingsPressed() {
    final GenPassData data = Provider.of<GenPassData>(context, listen: false);
    if (data == null) {
      debugPrint("GenPassData is not provided");
      return;
    }

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
    final History history = Provider.of<History>(context, listen: false);
    if (history == null) {
      debugPrint("History is not provided");
      return false;
    }

    final GenPassData data = Provider.of<GenPassData>(context, listen: false);
    if (data == null) {
      debugPrint("GenPassData is not provided");
      return false;
    }

    final String domainText = data.domainNotifier.value;
    if (domainText == null || domainText.isEmpty) {
      debugPrint("domainText is empty");
      return false;
    }

    history.add(domainText);
    debugPrint("${domainText} is added to history");
    return true;
  }
}

class _MasterInputRow extends StatelessWidget {
  const _MasterInputRow({
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
            labelText: "master password",
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
  const _DomainInputRow({
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
  const _InputRow({
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
    @required this.title,
    @required this.icon,
    @required this.onCopy,
  }) : super(key: key);

  final String title;

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
          final ThemeData themeData = Theme.of(context);
          final TextStyle textStyle = themeData.textTheme.body1;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    icon,
                    size: kFontSize,
                    color: textStyle.color,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    title,
                    style: textStyle,
                  ),
                ],
              ),
              _buildRow(
                context,
                showNotifier: showNotifier,
                text: text,
              ),
            ],
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
    final bool valid = (text != null && text.isNotEmpty);
    final Color iconColor = valid ? themeData.primaryColor : themeData.disabledColor;
    final bool show = showNotifier.value ?? false;

    String showText = text;
    if (valid && !show) {
      showText = "*".padRight(text.length, "*");
    }

    return Row(
      children: <Widget>[
        const SizedBox(width: 22.0),
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

Future<void> copyTextToClipboard(BuildContext context, String title, String text) {
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 8.0, 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
