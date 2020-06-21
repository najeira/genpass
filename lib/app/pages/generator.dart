import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'package:genpass/app/gloabls.dart';
import 'package:genpass/app/notifications/copy.dart';
import 'package:genpass/app/notifications/generator.dart';
import 'package:genpass/app/notifications/history.dart';
import 'package:genpass/app/notifications/visibility.dart';
import 'package:genpass/app/widgets/generator.dart';
import 'package:genpass/app/widgets/history_button.dart';
import 'package:genpass/app/widgets/input_row.dart';
import 'package:genpass/app/widgets/master_visibility_button.dart';
import 'package:genpass/domain/error_message.dart';
import 'package:genpass/domain/gen_pass_data.dart';
import 'package:genpass/domain/generator.dart';
import 'package:genpass/domain/history.dart';
import 'package:genpass/domain/settings.dart';

import 'help.dart';
import 'history.dart';

class GenPassPage extends StatefulWidget {
  const GenPassPage({
    Key key,
  }) : super(key: key);

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
            icon: const Icon(Icons.info),
            onPressed: _onHelpPressed,
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: _wrapNotificationListener(
        context,
        _buildColumn(context),
      ),
    );
  }

  Widget _wrapNotificationListener(BuildContext context, Widget child) {
    return NotificationListener<GeneratorNotification>(
      onNotification: (GeneratorNotification notification) {
        final GenPassData data = context.read();
        if (notification is GeneratorAddNotification) {
          // Adds a new generator with default setting.
          data.addSetting(const Setting());
        } else if (notification is GeneratorUpdateNotification) {
          data.updateGenerator(notification.generator);
        } else if (notification is GeneratorRemoveNotification) {
          data.removeSettingAt(notification.index);
        }
        return true;
      },
      child: NotificationListener<CopyNotification>(
        onNotification: (CopyNotification notification) {
          _addHistory();
          return true;
        },
        child: child,
      ),
    );
  }

  Widget _buildColumn(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _SectionTitle(title: "Form"),
        const Padding(
          padding: EdgeInsets.fromLTRB(12.0, 0.0, 8.0, 0.0),
          child: _MasterInputRow(),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(12.0, 8.0, 8.0, 24.0),
          child: _DomainInputRow(),
        ),
        const Divider(),
        const _GeneratorList(),
      ],
    );
  }

  void _onHelpPressed() {
    //HelpPage
    Navigator.of(context)?.push(
      MaterialPageRoute<Setting>(
        builder: (BuildContext context) {
          return const HelpPage();
        },
      ),
    );
  }

  Future<bool> _addHistory() async {
    final History history = context.read<History>();
    if (history == null) {
      log.warning("History is not provided");
      return false;
    }

    final GenPassData data = context.read<GenPassData>();
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
      child: const _MasterInputRowInner(),
    );
  }
}

class _MasterInputRowInner extends StatelessWidget {
  const _MasterInputRowInner({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    log.fine("_MasterInputRowInner.build");
    return _buildNotificationListener(context);
  }

  Widget _buildNotificationListener(BuildContext context) {
    return NotificationListener<VisibilityNotification>(
      onNotification: (VisibilityNotification notification) {
        final ValueNotifier<bool> notifier = context.read<ValueNotifier<bool>>();
        notifier.value = notification.visible;
        return true;
      },
      child: _buildInputRow(context),
    );
  }

  Widget _buildInputRow(BuildContext context) {
    return Consumer<ValueNotifier<bool>>(
      builder: (BuildContext context, ValueNotifier<bool> value, Widget child) {
        final bool visible = value.value ?? false;
        return InputRow(
          textInputType: TextInputType.visiblePassword,
          inputIcon: Icons.bubble_chart,
          labelText: "master password",
          hintText: "your master password",
          obscureText: !visible,
          actionButton: Provider<bool>.value(
            value: visible,
            child: const MasterVisibilityButton(),
          ),
        );
      },
    );
  }
}

class _DomainInputRow extends StatelessWidget {
  const _DomainInputRow({
    Key key,
  }) : super(key: key);

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
      child: const _DomainInputRowInner(),
    );
  }
}

class _DomainInputRowInner extends StatelessWidget {
  const _DomainInputRowInner({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    log.fine("_DomainInputRowInner.build");
    return _buildNotificationListener(context);
  }

  Widget _buildNotificationListener(BuildContext context) {
    return NotificationListener<HistoryNotification>(
      onNotification: (HistoryNotification notification) {
        _showHistoryPage(context);
        return true;
      },
      child: _buildInputRow(context),
    );
  }

  Widget _buildInputRow(BuildContext context) {
    return InputRow(
      textInputType: TextInputType.url,
      inputIcon: Icons.business,
      labelText: "domain / site",
      hintText: "example.com",
      actionButton: const HistoryButton(),
    );
  }

  void _showHistoryPage(BuildContext context) {
    final History history = context.read<History>();
    if (history == null) {
      log.warning("History is not provided");
      return;
    }

    final TextEditingController controller = context.read<TextEditingController>();
    if (controller == null) {
      log.warning("TextEditingController is not provided");
      return;
    }

    Navigator.of(context)?.push(
      MaterialPageRoute<String>(
        builder: (BuildContext context) {
          return HistoryPage(
            text: controller.text,
            history: history,
          );
        },
      ),
    )?.then((String domainText) {
      if (domainText != null && domainText.isNotEmpty) {
        controller.text = domainText;
        log.config("domain is ${domainText}");
      }
    });
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    Key key,
    this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    log.fine("_SectionTitle.build");
    final ThemeData themeData = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 16.0, 8.0, 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: themeData.textTheme.bodyText2.fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _GeneratorList extends StatelessWidget {
  const _GeneratorList({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    log.fine("_GeneratorList.build");
    return Selector<GenPassData, Generators>(
      selector: (BuildContext context, GenPassData value) {
        log.fine("_GeneratorList.selector");
        return value.generators;
      },
      builder: (BuildContext context, Generators value, Widget child) {
        log.fine("_GeneratorList.builder");
        return ChangeNotifierProvider<Generators>.value(
          value: value,
          child: child,
        );
      },
      child: Consumer<Generators>(
        builder: (BuildContext context, Generators value, Widget child) {
          log.fine("_GeneratorList.Consumer.builder");
          final int length = value?.items?.length ?? 0;
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (int i = 0; i < length; i++)
                ChangeNotifierProvider<Generator>.value(
                  value: value?.items[i],
                  child: Provider<int>.value(
                    value: i,
                    child: const GeneratorSection(),
                  ),
                ),
              Center(
                child: FlatButton.icon(
                  onPressed: () {
                    const GeneratorAddNotification notification = GeneratorAddNotification();
                    notification.dispatch(context);
                  },
                  icon: Icon(Icons.add_circle),
                  label: Text("Add Generator"),
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          );
        },
      ),
    );
  }
}
