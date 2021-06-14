import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:genpass/app/providers.dart';
import 'package:genpass/app/widgets/setting_caption.dart';

class HelpPage extends StatelessWidget {
  const HelpPage._({
    Key? key,
  }) : super(key: key);

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
        children: const <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: _ThemeModeRow(),
          ),
          Divider(),
          _AboutRow(),
          Divider(),
        ],
      ),
    );
  }
}

class _ThemeModeRow extends ConsumerWidget {
  const _ThemeModeRow({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final themeMode = watch(themeModeProvider);
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
            _updateThemeMode(context, value);
          },
        ),
        RadioListTile<ThemeMode>(
          title: const Text("Light"),
          value: ThemeMode.light,
          groupValue: themeMode,
          onChanged: (ThemeMode? value) {
            _updateThemeMode(context, value);
          },
        ),
        RadioListTile<ThemeMode>(
          title: const Text("Dark"),
          value: ThemeMode.dark,
          groupValue: themeMode,
          onChanged: (ThemeMode? value) {
            _updateThemeMode(context, value);
          },
        ),
      ],
    );
  }

  void _updateThemeMode(BuildContext context, ThemeMode? value) {
    if (value == null) {
      return;
    }
    final ctrl = context.read(themeModeProvider.notifier);
    ctrl.state = value;
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _onPressed(context),
      child: const Padding(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
        child: SettingCaption(
          icon: Icons.info_outline,
          title: "About",
        ),
      ),
    );
  }

  void _onPressed(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                ListTile(
                  title: Text(
                    "GenPass app made by najeira",
                  ),
                ),
                // <div>Icons made by <a href="https://www.flaticon.com/authors/becris" title="Becris">Becris</a> from <a href="https://www.flaticon.com/" title="Flaticon">www.flaticon.com</a></div>
                ListTile(
                  title: Text(
                    "App icon made by Becris from www.flaticon.com",
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
