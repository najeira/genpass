import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:genpass/app/gloabls.dart';
import 'package:genpass/app/providers.dart';

import 'generator.dart';

// The root of the application, does not have a screen.
class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    log.fine("MyApp.build");
    final textTheme = _textTheme(context);
    final lightTheme = ThemeData.from(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff6200ee),
        brightness: Brightness.light,
      ),
      textTheme: textTheme,
    );
    final darkTheme = ThemeData.from(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xffbb86fc),
        brightness: Brightness.dark,
      ),
      textTheme: textTheme,
    );
    return _MyApp(
      lightTheme: lightTheme,
      darkTheme: darkTheme,
    );
  }

  TextTheme _textTheme(BuildContext context) {
    return const TextTheme(
      bodySmall: TextStyle(
        fontSize: 18.0,
      ),
      titleSmall: TextStyle(
        fontSize: 18.0,
      ),
    );
  }
}

class _MyApp extends ConsumerWidget {
  const _MyApp({
    required this.lightTheme,
    required this.darkTheme,
    Key? key,
  }) : super(key: key);

  final ThemeData lightTheme;

  final ThemeData darkTheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log.fine("_MyApp.build");
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: kAppName,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      home: const LaunchPage(),
    );
  }
}

// Loading at startup and switching to the application screen.
class LaunchPage extends ConsumerWidget {
  const LaunchPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log.fine("LaunchPage.build");
    final isLoading = ref.watch(isLaunchingProvider);
    if (isLoading) {
      return const LoadingPage();
    }
    return const GenPassPage();
  }
}

// Loading
class LoadingPage extends StatelessWidget {
  const LoadingPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    log.fine("LoadingPage.build");
    final themeData = Theme.of(context);
    final textTheme = themeData.textTheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              kAppName,
              style: textTheme.headlineLarge,
            ),
            Image.asset(
              "assets/appicon.png",
              width: 96.0,
              height: 96.0,
            ),
            const SizedBox(
              width: 96.0,
              child: LinearProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}
