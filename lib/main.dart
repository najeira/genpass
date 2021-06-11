import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/pages/app.dart';
import 'service/log.dart';

void main() {
  initLogging();
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}
