import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:genpass/app/gloabls.dart';
import 'package:genpass/app/providers.dart';
import 'package:genpass/app/widgets/setting_caption.dart';

class HelpPage extends StatelessWidget {
  const HelpPage._({
    super.key,
  });

  static Future<void> push(BuildContext context) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return const HelpPage._();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const <Widget>[
          _ThemeModeRow(),
          Divider(height: 32.0),
          SizedBox(height: 8.0),
          _AboutRow(),
          Divider(height: 32.0),
          SizedBox(height: 100.0),
        ],
      ),
    );
  }
}

class _ThemeModeRow extends ConsumerWidget {
  const _ThemeModeRow({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SettingCaption(
          title: "Theme Mode",
          icon: Icons.palette,
        ),
        RadioListTile<ThemeMode>(
          title: const Text("System"),
          value: ThemeMode.system,
          groupValue: themeMode,
          onChanged: (ThemeMode? value) {
            _updateThemeMode(context, ref, value);
          },
        ),
        RadioListTile<ThemeMode>(
          title: const Text("Light"),
          value: ThemeMode.light,
          groupValue: themeMode,
          onChanged: (ThemeMode? value) {
            _updateThemeMode(context, ref, value);
          },
        ),
        RadioListTile<ThemeMode>(
          title: const Text("Dark"),
          value: ThemeMode.dark,
          groupValue: themeMode,
          onChanged: (ThemeMode? value) {
            _updateThemeMode(context, ref, value);
          },
        ),
      ],
    );
  }

  void _updateThemeMode(BuildContext context, WidgetRef ref, ThemeMode? value) {
    if (value == null) {
      return;
    }
    final ctrl = ref.read(themeModeProvider.notifier);
    ctrl.state = value;
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _onPressed(context),
      child: const SettingCaption(
        icon: Icons.copyright,
        title: "About",
      ),
    );
  }

  void _onPressed(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => const _Dialog(),
    );
  }
}

class _Dialog extends StatelessWidget {
  const _Dialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return AlertDialog(
      icon: const Icon(Icons.copyright),
      title: const Text("About"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "${kAppName} app made by najeira.",
          ),
          const SizedBox(height: 8.0),
          // <div>Icons made by <a href="https://www.flaticon.com/authors/becris" title="Becris">Becris</a> from <a href="https://www.flaticon.com/" title="Flaticon">www.flaticon.com</a></div>
          const Text(
            "App icon made by Becris from www.flaticon.com.",
          ),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: themeData.colorScheme.onPrimary,
            backgroundColor: themeData.colorScheme.primary,
          ),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: const Text("OK"),
        ),
      ],
    );
  }
}
