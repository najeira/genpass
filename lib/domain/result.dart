class Result {
  const Result({
    required this.password,
    required this.pin,
  });

  final String password;
  final String pin;
}

class Value {
  const Value({
    required this.rawText,
    required this.visible,
  });

  final String rawText;

  final bool visible;

  bool get enable => rawText.isNotEmpty;

  String get showText {
    if (rawText.isEmpty) {
      return "-";
    } else if (!visible) {
      return "".padRight(rawText.length, "*");
    }
    return rawText;
  }
}
