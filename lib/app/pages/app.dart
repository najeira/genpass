import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:genpass/app/gloabls.dart';
import 'package:genpass/app/providers.dart';

import 'generator.dart';

// The root of the application, does not have a screen.
class MyApp extends ConsumerWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log.fine("MyApp.build");
    final themeMode = ref.watch(themeModeProvider);
    final textTheme = _textTheme(context);
    final lightTheme = ThemeData.from(
      colorScheme: const ColorScheme.light(),
      textTheme: textTheme,
    );
    final darkTheme = ThemeData.from(
      colorScheme: const ColorScheme.dark(),
      textTheme: textTheme,
    );
    return MaterialApp(
      title: kAppName,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      home: const LaunchPage(),
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
      appBar: AppBar(
        title: const Text(kAppName),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            const SizedBox(height: 32.0),
            Text(
              "IdemPass",
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
