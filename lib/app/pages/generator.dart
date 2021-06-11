import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:genpass/app/gloabls.dart';
import 'package:genpass/app/providers.dart';
import 'package:genpass/app/widgets/generator.dart';
import 'package:genpass/app/widgets/history_button.dart';
import 'package:genpass/app/widgets/input_row.dart';
import 'package:genpass/app/widgets/visibility_button.dart';
import 'package:genpass/domain/settings.dart';

import 'help.dart';
import 'history.dart';

class GenPassPage extends StatefulWidget {
  const GenPassPage({
    Key? key,
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
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _addHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    log.fine("GenPassPage.build");
    return Scaffold(
      appBar: AppBar(
        title: const Text(kAppName),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () => HelpPage.push(context),
          ),
        ],
      ),
      body: const _GeneratorBody(),
    );
  }

  Future<bool> _addHistory() async {
    final domain = context.read(domainTextEditingProvider);
    if (domain.text.isEmpty) {
      log.config("domain is empty");
      return false;
    }

    final history = context.read(historyProvider);
    history.add(domain.text);
    await history.save();
    log.config("domain ${domain.text} is added to history");
    return true;
  }
}

class _GeneratorBody extends StatelessWidget {
  const _GeneratorBody({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          _SectionTitle(title: "Form"),
          Padding(
            padding: EdgeInsets.fromLTRB(12.0, 0.0, 8.0, 0.0),
            child: _MasterInputRow(),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(12.0, 8.0, 8.0, 24.0),
            child: _DomainInputRow(),
          ),
          Divider(),
          _GeneratorList(),
        ],
      ),
    );
  }
}

class _MasterInputRow extends ConsumerWidget {
  const _MasterInputRow({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    log.fine("_MasterInputRow.build");
    final text = watch(masterTextEditingProvider);
    final visible = watch(masterVisibleProvider);
    final errorText = watch(masterErrorTextProvider);
    return InputRow(
      controller: text,
      textInputType: TextInputType.visiblePassword,
      inputIcon: Icons.bubble_chart,
      labelText: "master password",
      hintText: "your master password",
      errorText: errorText,
      obscureText: !visible,
      actionButton: VisibilityButton(
        enable: true,
        visible: visible,
        onSelected: (value) {
          final ctrl = context.read(masterVisibleProvider.notifier);
          ctrl.state = value;
        },
      ),
    );
  }
}

class _DomainInputRow extends ConsumerWidget {
  const _DomainInputRow({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    log.fine("_DomainInputRow.build");
    final text = watch(domainTextEditingProvider);
    final errorText = watch(domainErrorTextProvider);
    return InputRow(
      controller: text,
      textInputType: TextInputType.url,
      inputIcon: Icons.business,
      labelText: "domain / site",
      hintText: "example.com",
      errorText: errorText,
      obscureText: false,
      actionButton: HistoryButton(
        onPressed: () {
          _showHistoryPage(context);
        },
      ),
    );
  }

  void _showHistoryPage(BuildContext context) {
    HistoryPage.push(context).then((String? domainText) {
      if (domainText != null && domainText.isNotEmpty) {
        final domain = context.read(domainTextEditingProvider);
        domain.text = domainText;
        log.config("domain is ${domainText}");
      }
    });
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    Key? key,
    this.title,
  }) : super(key: key);

  final String? title;

  @override
  Widget build(BuildContext context) {
    log.fine("_SectionTitle.build");
    final themeData = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 16.0, 8.0, 8.0),
      child: Text(
        title!,
        style: TextStyle(
          fontSize: themeData.textTheme.bodyText2!.fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _GeneratorList extends ConsumerWidget {
  const _GeneratorList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    log.fine("_GeneratorList.build");
    final settings = watch(settingListProvider);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int i = 0; i < settings.items.length; i++)
          GeneratorSection.withIndex(context, i),
        Center(
          child: TextButton.icon(
            onPressed: () {
              _onAddSetting(context);
            },
            icon: const Icon(Icons.add_circle),
            label: const Text("Add Generator"),
          ),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Future<void> _onAddSetting(BuildContext context) {
    final ctrl = context.read(settingListProvider.notifier);
    ctrl.add(const Setting());
    return ctrl.save();
  }
}
