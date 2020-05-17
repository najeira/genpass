import 'package:logging/logging.dart';

void initLogging() {
  Logger.root.level = Level.INFO;
  assert(() {
    Logger.root.level = Level.FINE;
    return true;
  }());
  Logger.root.onRecord.listen((LogRecord record) {
    print("${record.time}: [${record.level.name}] ${record.message}");
  });
}
