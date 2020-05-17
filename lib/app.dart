import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'generator.dart';
import 'gloabls.dart';
import 'model.dart';
import 'service.dart';

class AppModel {
  AppModel(this.settings, this.history);

  Settings settings;
  History history;
}

Future<AppModel> _loadAppModel() async {
  await Future.delayed(const Duration(seconds: 3));

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
              theme: ThemeData(
                brightness: Brightness.light,
                primarySwatch: Colors.blue,
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                primarySwatch: Colors.blue,
              ),
              themeMode: value.value,
              home: child,
            ),
          );
        },
        child: const AppRoot(),
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
    final ThemeData themeData = Theme.of(context);
    final TextTheme textTheme = themeData.textTheme;
    final IconThemeData iconThemeData = themeData.iconTheme;
    
    const double kFontSize = 18.0;

    return Theme(
      data: themeData.copyWith(
        textTheme: textTheme.copyWith(
          bodyText2: textTheme.bodyText2.copyWith(
            fontSize: kFontSize,
          ),
          subtitle1: textTheme.subtitle1.copyWith(
            fontSize: kFontSize,
          ),
        ),
      ),
      child: _buildGenPassPage(context, appModel),
    );
  }

  Widget _buildGenPassPage(BuildContext context, AppModel appModel) {
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
