import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:genpass/app/gloabls.dart';
import 'package:genpass/app/notifications/theme_mode.dart';
import 'package:genpass/domain/gen_pass_data.dart';
import 'package:genpass/domain/history.dart';
import 'package:genpass/domain/settings.dart';

import 'generator.dart';

class AppModel {
  const AppModel(this.settings, this.history);

  final Settings settings;
  final History history;
}

Future<AppModel> _loadAppModel() async {
  Future<History> history = History.load();
  Future<Settings> settings = Settings.load();
  return AppModel(
    await settings,
    await history,
  );
}

// The root of the application, does not have a screen.
class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

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
        builder: (BuildContext context, ValueNotifier<ThemeMode> value, Widget? child) {
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
        child: const LaunchPage(),
      ),
    );
  }

  TextTheme _textTheme(BuildContext context) {
    return const TextTheme(
      bodyText2: TextStyle(
        fontSize: 18.0,
      ),
      subtitle1: TextStyle(
        fontSize: 18.0,
      ),
    );
  }
}

// Loading at startup and switching to the application screen.
class LaunchPage extends StatelessWidget {
  const LaunchPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<Future<AppModel>>(
      create: (BuildContext context) {
        return _loadAppModel();
      },
      child: Consumer<Future<AppModel>>(
        builder: (BuildContext context, Future<AppModel> value, Widget? child) {
          return FutureBuilder<AppModel>(
            future: value,
            builder: (BuildContext context, AsyncSnapshot<AppModel> snapshot) {
              if (snapshot.hasError) {
                log.fine("LaunchPage error ${snapshot.error}");
                return const LoadingPage();
              } else if (!snapshot.hasData) {
                log.fine("LaunchPage loading");
                return const LoadingPage();
              }

              assert(snapshot.data?.history != null);
              assert(snapshot.data?.settings != null);
              return _build(context, snapshot.data!);
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
            final data = GenPassData();
            data.setSettings(appModel.settings);
            return data;
          },
        ),
      ],
      child: const GenPassPage(),
    );
  }
}

// Loading
class LoadingPage extends StatelessWidget {
  const LoadingPage({
    Key? key,
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
              style: textTheme.caption!.copyWith(
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
