import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'widgets/result_row.dart';

import 'gloabls.dart';
import 'history.dart';
import 'model.dart';
import 'service.dart';
import 'settings.dart';

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
      _addHistory();
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
    return SingleChildScrollView(
      child: _buildColumn(context),
    );
  }

  Widget _buildColumn(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _SectionTitle(title: "Form"),
        const Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 0.0, 8.0, 0.0),
          child: const _MasterInputRow(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 8.0, 8.0, 24.0),
          child: _DomainInputRow(
            onActionPressed: _onHistoryPressed,
          ),
        ),
        const Divider(),
        const _SectionTitle(title: "Generator"),
        const Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 8.0, 8.0, 0.0),
          child: const _PasswordResultRow(),
        ),
        const Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 8.0, 8.0, 0.0),
          child: const _PinResultRow(),
        ),
      ],
    );
  }

  void _onHistoryPressed() {
    final History history = Provider.of<History>(context, listen: false);
    if (history == null) {
      log.warning("History is not provided");
      return;
    }

    final GenPassData data = Provider.of<GenPassData>(context, listen: false);
    if (data == null) {
      log.warning("GenPassData is not provided");
      return;
    }

    Navigator.of(context)?.push(
      MaterialPageRoute<String>(
        builder: (BuildContext context) {
          return HistoryPage(
            text: data.domainNotifier.text,
            history: history,
          );
        },
      ),
    )?.then((String domainText) {
      if (domainText != null && domainText.isNotEmpty) {
        data.domainNotifier.text = domainText;
        log.config("domain is ${domainText}");
      }
    });
  }

  void _onSettingsPressed() {
    final GenPassData data = Provider.of<GenPassData>(context, listen: false);
    if (data == null) {
      log.warning("GenPassData is not provided");
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
        log.config("settings succeeded to save");
      }).catchError((Object error, StackTrace stackTrace) {
        log.warning("settings failed to save", error, stackTrace);
      });
    });
  }

  Future<bool> _addHistory() async {
    final History history = Provider.of<History>(context, listen: false);
    if (history == null) {
      log.warning("History is not provided");
      return false;
    }

    final GenPassData data = Provider.of<GenPassData>(context, listen: false);
    if (data == null) {
      log.warning("GenPassData is not provided");
      return false;
    }

    final String domainText = data.domainNotifier.text;
    if (domainText == null || domainText.isEmpty) {
      log.config("domain is empty");
      return false;
    }

    history.add(domainText);
    await history.save();
    log.config("domain ${domainText} is added to history");
    return true;
  }
}

class _MasterInputRow extends StatelessWidget {
  const _MasterInputRow({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    log.fine("_MasterInputRow.build");
    return Selector<GenPassData, Tuple2<TextEditingController, ErrorMessageNotifier>>(
      selector: (BuildContext context, GenPassData value) {
        log.fine("_MasterInputRow.Selector.selector");
        return Tuple2<TextEditingController, ErrorMessageNotifier>(
          value.masterNotifier,
          value.masterErrorNotifier,
        );
      },
      builder: (BuildContext context, Tuple2<TextEditingController, ErrorMessageNotifier> value, Widget child) {
        log.fine("_MasterInputRow.Selector.builder");
        return MultiProvider(
          providers: [
            ListenableProvider<TextEditingController>.value(
              value: value.item1,
            ),
            ValueListenableProvider<ErrorMessage>.value(
              value: value.item2,
              child: child,
            ),
            ChangeNotifierProvider<ValueNotifier<bool>>(
              create: (BuildContext context) => ValueNotifier<bool>(false),
            ),
          ],
          child: child,
        );
      },
      child: _build(context),
    );
  }

  Widget _build(BuildContext context) {
    log.fine("_MasterInputRow.Consumer");
    return Consumer<ValueNotifier<bool>>(
      builder: (BuildContext context, ValueNotifier<bool> showNotifier, Widget child) {
        log.fine("_MasterInputRow.Consumer.builder");
        final bool show = showNotifier.value ?? false;
        return _InputRow(
          textInputType: TextInputType.visiblePassword,
          inputIcon: Icons.bubble_chart,
          labelText: "master password",
          hintText: "your master password",
          obscureText: !show,
          actionIcon: show ? Icons.visibility : Icons.visibility_off,
          onActionPressed: () {
            showNotifier.value = !show;
          },
        );
      },
    );
  }
}

class _DomainInputRow extends StatelessWidget {
  const _DomainInputRow({
    Key key,
    @required this.onActionPressed,
  })  : assert(onActionPressed != null),
        super(key: key);

  final VoidCallback onActionPressed;

  @override
  Widget build(BuildContext context) {
    log.fine("_DomainInputRow.build");
    return Selector<GenPassData, Tuple2<TextEditingController, ErrorMessageNotifier>>(
      selector: (BuildContext context, GenPassData value) {
        log.fine("_DomainInputRow.Selector.selector");
        return Tuple2<TextEditingController, ErrorMessageNotifier>(
          value.domainNotifier,
          value.domainErrorNotifier,
        );
      },
      builder: (BuildContext context, Tuple2<TextEditingController, ErrorMessageNotifier> value, Widget child) {
        log.fine("_DomainInputRow.Selector.builder");
        return MultiProvider(
          providers: [
            ListenableProvider<TextEditingController>.value(
              value: value.item1,
            ),
            ValueListenableProvider<ErrorMessage>.value(
              value: value.item2,
              child: child,
            ),
          ],
          child: child,
        );
      },
      child: _build(context),
    );
  }

  Widget _build(BuildContext context) {
    log.fine("_DomainInputRow._InputRow");
    return _InputRow(
      textInputType: TextInputType.url,
      inputIcon: Icons.business,
      labelText: "domain / site",
      hintText: "example.com",
      actionIcon: Icons.assignment,
      onActionPressed: onActionPressed,
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
    @required this.onActionPressed,
  }) : super(key: key);

  final IconData inputIcon;
  final TextInputType textInputType;
  final String labelText;
  final String hintText;
  final bool obscureText;
  final IconData actionIcon;
  final VoidCallback onActionPressed;

  @override
  Widget build(BuildContext context) {
    log.fine("_InputRow(${labelText}).build");
    final ThemeData themeData = Theme.of(context);
    return Row(
      children: <Widget>[
        Expanded(
          child: _buildTextField(context),
        ),
        IconButton(
          icon: Icon(
            actionIcon,
            size: kActionIconSize,
            color: themeData.primaryColor,
          ),
          onPressed: onActionPressed,
        ),
      ],
    );
  }

  Widget _buildTextField(BuildContext context) {
    log.fine("_InputRow(${labelText}).Consumer2");
    final TextEditingController controller = Provider.of<TextEditingController>(context, listen: false);
    return Consumer<ErrorMessage>(
      builder: (
        BuildContext context,
        ErrorMessage errorMessage,
        Widget child,
      ) {
        log.fine("_InputRow(${labelText}).Consumer2.builder");
        return TextField(
          controller: controller,
          decoration: InputDecoration(
            icon: Icon(inputIcon, size: kInputIconSize),
            labelText: labelText,
            hintText: hintText,
            errorText: errorMessage?.value,
          ),
          keyboardType: textInputType,
          obscureText: obscureText ?? false,
        );
      },
    );
  }
}

class _PasswordResultRow extends StatelessWidget {
  const _PasswordResultRow({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    log.fine("_PasswordResultRow.build");
    return Selector<GenPassData, ValueNotifier<String>>(
      selector: (BuildContext context, GenPassData value) {
        log.fine("_PasswordResultRow.Selector.selector");
        return value.passNotifier;
      },
      builder: (BuildContext context, ValueNotifier<String> value, Widget child) {
        log.fine("_PasswordResultRow.Selector.builder");
        return ValueListenableProvider<String>.value(
          value: value,
          child: child,
        );
      },
      child: ResultRowController.provider(
        child: ResultRow(
          title: kTitlePassword,
          icon: kIconPassword,
        ),
      ),
    );
  }
}

class _PinResultRow extends StatelessWidget {
  const _PinResultRow({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    log.fine("_PinResultRow.Selector.build");
    return Selector<GenPassData, ValueNotifier<String>>(
      selector: (BuildContext context, GenPassData value) {
        log.fine("_PinResultRow.Selector.selector");
        return value.pinNotifier;
      },
      builder: (BuildContext context, ValueNotifier<String> value, Widget child) {
        log.fine("_PinResultRow.Selector.builder");
        return ValueListenableProvider<String>.value(
          value: value,
          child: child,
        );
      },
      child: ResultRowController.provider(
        child: ResultRow(
          title: kTitlePin,
          icon: kIconPin,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 16.0, 8.0, 8.0),
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
