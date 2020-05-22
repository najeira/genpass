import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:genpass/app/gloabls.dart';
import 'package:genpass/domain/gen_pass_data.dart';
import 'package:genpass/domain/history.dart';
import 'package:genpass/domain/settings.dart';

import 'generator.dart';

class AppModel {
  AppModel(this.settings, this.history);

  Settings settings;
  History history;
}

Future<AppModel> _loadAppModel() async {
  assert(await () async {
    Future.delayed(const Duration(seconds: 3));
    return true;
  }());

  Future<History> history = History.load();
  Future<Settings> settings = Settings.load();
  return AppModel(
    await settings,
    await history,
  );
}

class ThemeModeNotification extends Notification {
  ThemeModeNotification(this.value);

  final ThemeMode value;
}

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = _textTheme(context);

    final ThemeData lightTheme = ThemeData.from(
      colorScheme: ColorScheme.light(),
      textTheme: textTheme,
    );

    final ThemeData darkTheme = ThemeData.from(
      colorScheme: ColorScheme.dark(),
      textTheme: textTheme,
    );

    return ChangeNotifierProvider<ValueNotifier<ThemeMode>>(
      create: (BuildContext context) {
        return ValueNotifier<ThemeMode>(ThemeMode.system);
      },
      child: Consumer<ValueNotifier<ThemeMode>>(
        builder: (BuildContext context, ValueNotifier<ThemeMode> value, Widget child) {
          return NotificationListener<ThemeModeNotification>(
            onNotification: (ThemeModeNotification notification) {
              value.value = notification.value;
              return true;
            },
            child: MaterialApp(
              title: kAppName,
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: value.value,
              home: child,
            ),
          );
        },
        child: const AppRoot(),
      ),
    );
  }

  TextTheme _textTheme(BuildContext context) {
    return TextTheme(
      bodyText2: TextStyle(
        fontSize: 18.0,
      ),
      subtitle1: TextStyle(
        fontSize: 18.0,
      ),
    );
  }
}

class AppRoot extends StatelessWidget {
  const AppRoot();

  @override
  Widget build(BuildContext context) {
    return Provider<Future<AppModel>>(
      create: (BuildContext context) {
        return _loadAppModel();
      },
      child: Consumer<Future<AppModel>>(
        builder: (BuildContext context, Future<AppModel> value, Widget child) {
          return FutureBuilder<AppModel>(
            future: value,
            builder: (BuildContext context, AsyncSnapshot<AppModel> snapshot) {
              if (!snapshot.hasData && !snapshot.hasError) {
                return const LaunchPage();
              }
              return _build(context, snapshot.data);
            },
          );
        },
      ),
    );
  }

  Widget _build(BuildContext context, AppModel appModel) {
    return MultiProvider(
      providers: [
        Provider<History>.value(
          value: appModel.history,
        ),
        Provider<GenPassData>(
          create: (BuildContext context) {
            final GenPassData data = GenPassData();
            data.settingsNotifier.value = appModel.settings;
            return data;
          },
        ),
      ],
      child: const GenPassPage(),
    );
  }
}

class LaunchPage extends StatelessWidget {
  const LaunchPage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final TextTheme textTheme = themeData.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(kAppName),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            const SizedBox(height: 32.0),
            Text(
              "Launching Generator...",
              style: textTheme.caption.copyWith(
                fontSize: 24.0,
              ),
            ),
            const SizedBox(height: 64.0),
            const SizedBox(
              width: 64.0,
              height: 64.0,
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}
