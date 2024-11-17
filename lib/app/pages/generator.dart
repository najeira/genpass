import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:genpass/app/gloabls.dart';
import 'package:genpass/app/providers.dart';
import 'package:genpass/app/widgets/generator.dart';
import 'package:genpass/app/widgets/history_button.dart';
import 'package:genpass/app/widgets/input_row.dart';
import 'package:genpass/app/widgets/visibility_button.dart';
import 'package:genpass/domain/settings.dart';
import 'package:genpass/service/clipboard.dart';

import 'help.dart';
import 'history.dart';

class GenPassPage extends StatefulWidget {
  const GenPassPage({
    super.key,
  });

  @override
  State createState() => _GenPassPageState();
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
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _addHistory(context);
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
      body: const _NotificationHandler(),
    );
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

class _NotificationHandler extends StatelessWidget {
  const _NotificationHandler({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ClipboardNotification>(
      onNotification: (notification) {
        _addHistory(context);
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
            content: Text("${notification.name} copied to clipboard"),
          ),
        );
        return true;
      },
      child: const _GeneratorBody(),
    );
  }
}

class _GeneratorBody extends StatelessWidget {
  const _GeneratorBody({
    super.key,
  });

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
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log.fine("_MasterInputRow.build");
    final visible = ref.watch(masterVisibleProvider);
    final errorText = ref.watch(masterErrorTextProvider);
    final iconData = ref.watch(masterIconProvider);
    return InputRow(
      provider: masterInputTextProvider,
      textInputType: TextInputType.visiblePassword,
      inputIcon: Icons.bubble_chart,
      suffixIcon: iconData,
      labelText: "master password",
      hintText: "your master password",
      errorText: errorText,
      obscureText: !visible,
      actionButton: VisibilityButton(
        enable: true,
        visible: visible,
        onSelected: (value) => _onSelected(context, ref, value),
      ),
    );
  }

  void _onSelected(BuildContext context, WidgetRef ref, bool value) {
    ref.read(masterVisibleProvider.notifier).state = value;
  }
}

class _DomainInputRow extends ConsumerWidget {
  const _DomainInputRow({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log.fine("_DomainInputRow.build");
    final errorText = ref.watch(domainErrorTextProvider);
    return InputRow(
      provider: domainInputTextProvider,
      textInputType: TextInputType.url,
      inputIcon: Icons.business,
      labelText: "domain / site",
      hintText: "example.com",
      errorText: errorText,
      obscureText: false,
      actionButton: HistoryButton(
        onPressed: () => _showHistoryPage(context, ref),
      ),
    );
  }

  Future<void> _showHistoryPage(BuildContext context, WidgetRef ref) {
    return HistoryPage.push(context).then((String? domainText) {
      if (domainText != null && domainText.isNotEmpty) {
        ref.read(domainInputTextProvider.notifier).state = domainText;
        log.config("domain is ${domainText}");
      }
    });
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    log.fine("_SectionTitle.build");
    final themeData = Theme.of(context);
    return Text(
      title,
      style: themeData.textTheme.titleSmall,
    );
  }
}

class _GeneratorList extends ConsumerWidget {
  const _GeneratorList({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log.fine("_GeneratorList.build");
    final settings = ref.watch(settingListProvider);
    return settings.when(
      data: (settings) => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (int i = 0; i < settings.length; i++)
            GeneratorSection.withIndex(context, i),
          const _AddButton(),
        ],
      ),
      error: (_, __) => const SizedBox.shrink(),
      loading: () => const CircularProgressIndicator(),
    );
  }
}

class _AddButton extends ConsumerWidget {
  const _AddButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: TextButton.icon(
        onPressed: () => _onAddSetting(context, ref),
        icon: const Icon(Icons.add_circle),
        label: const Text("Add Generator"),
      ),
    );
  }

  Future<void> _onAddSetting(BuildContext context, WidgetRef ref) {
    return ref.read(settingListProvider.notifier).add(const Setting());
  }
}

Future<bool> _addHistory(BuildContext context) async {
  final ps = ProviderScope.containerOf(context, listen: false);
  final domain = ps.read(domainInputTextProvider);
  if (domain.isEmpty) {
    log.config("domain is empty");
    return false;
  }

  final history = ps.read(historyProvider.notifier);
  await history.add(domain);
  log.config("domain ${domain} is added to history");
  return true;
}
