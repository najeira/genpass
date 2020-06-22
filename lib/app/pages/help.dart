import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:genpass/app/widgets/setting_caption.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help"),
      ),
      body: ListView(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: _ThemeModeRow(),
          ),
          const Divider(),
          const _AboutRow(),
          const Divider(),
        ],
      ),
    );
  }
}

class _ThemeModeRow extends StatelessWidget {
  const _ThemeModeRow({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ValueNotifier<ThemeMode> notifier = context.watch<ValueNotifier<ThemeMode>>();
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
          groupValue: notifier.value,
          onChanged: (ThemeMode value) => notifier.value = value,
        ),
        RadioListTile<ThemeMode>(
          title: const Text("Light"),
          value: ThemeMode.light,
          groupValue: notifier.value,
          onChanged: (ThemeMode value) => notifier.value = value,
        ),
        RadioListTile<ThemeMode>(
          title: const Text("Dark"),
          value: ThemeMode.dark,
          groupValue: notifier.value,
          onChanged: (ThemeMode value) => notifier.value = value,
        ),
      ],
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({
    Key key,
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                ListTile(title: Text("GenPass app made by najeira")),
                // <div>Icons made by <a href="https://www.flaticon.com/authors/becris" title="Becris">Becris</a> from <a href="https://www.flaticon.com/" title="Flaticon">www.flaticon.com</a></div>
                ListTile(title: Text("App icon made by Becris from www.flaticon.com")),
              ],
            ),
          ],
        );
      },
    );
  }
}
