import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:logging/logging.dart';

late final String kAppName = _getAppName();

//const double kFontSize = 18.0;
const double kInputIconSize = 24.0;
const double kActionIconSize = 28.0;

const String kTitlePassword = "Password";
const String kTitlePin = "PIN";
const IconData kIconPassword = Icons.vpn_key;
const IconData kIconPin = Icons.casino;
const IconData kIconAlgorithm = Icons.card_travel;

final Logger log = Logger(kAppName);

String _getAppName() {
  final p = defaultTargetPlatform;
  if (p == TargetPlatform.android) {
    return "GenPass";
  }
  return "IdemPass";
}
