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

class GenPassPage extends ConsumerStatefulWidget {
  const GenPassPage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() {
    return _GenPassPageState();
  }
}

class _GenPassPageState extends ConsumerState<GenPassPage>
    with WidgetsBindingObserver {
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
        title: Text(kAppName),
        actions: const <Widget>[
          _HelpButton(),
        ],
      ),
      body: const _GeneratorBody(),
    );
  }

  Future<bool> _addHistory() async {
    final domain = ref.read(domainTextEditingProvider);
    if (domain.text.isEmpty) {
      log.config("domain is empty");
      return false;
    }

    final history = ref.read(historyProvider);
    history.add(domain.text);
    await history.save();
    log.config("domain ${domain.text} is added to history");
    return true;
  }
}

class _HelpButton extends StatelessWidget {
  const _HelpButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.info),
      onPressed: () => HelpPage.push(context),
    );
  }
}

class _GeneratorBody extends StatelessWidget {
  const _GeneratorBody({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: const <Widget>[
        _SectionTitle(title: "Source"),
        SizedBox(height: 8.0),
        _MasterInputRow(),
        SizedBox(height: 12.0),
        _DomainInputRow(),
        SizedBox(height: 24.0),
        Divider(height: 1.0),
        _GeneratorList(),
        SizedBox(height: 100.0),
      ],
    );
  }
}

class _MasterInputRow extends ConsumerWidget {
  const _MasterInputRow({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log.fine("_MasterInputRow.build");
    final text = ref.watch(masterTextEditingProvider);
    final visible = ref.watch(masterVisibleProvider);
    final errorText = ref.watch(masterErrorTextProvider);
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
          final ctrl = ref.read(masterVisibleProvider.notifier);
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
  Widget build(BuildContext context, WidgetRef ref) {
    log.fine("_DomainInputRow.build");
    final text = ref.watch(domainTextEditingProvider);
    final errorText = ref.watch(domainErrorTextProvider);
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
          _showHistoryPage(context, ref);
        },
      ),
    );
  }

  void _showHistoryPage(BuildContext context, WidgetRef ref) {
    HistoryPage.push(context).then((String? domainText) {
      if (domainText != null && domainText.isNotEmpty) {
        final domain = ref.read(domainTextEditingProvider);
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
    return Text(
      title!,
      style: themeData.textTheme.titleSmall,
    );
  }
}

class _GeneratorList extends ConsumerWidget {
  const _GeneratorList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log.fine("_GeneratorList.build");
    final settings = ref.watch(settingListProvider);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int i = 0; i < settings.items.length; i++)
          GeneratorSection.withIndex(context, i),
        Center(
          child: TextButton.icon(
            onPressed: () {
              _onAddSetting(context, ref);
            },
            icon: const Icon(Icons.add_circle),
            label: const Text("Add Generator"),
          ),
        ),
      ],
    );
  }

  Future<void> _onAddSetting(BuildContext context, WidgetRef ref) {
    final ctrl = ref.read(settingListProvider.notifier);
    ctrl.add(const Setting());
    return ctrl.save();
  }
}
