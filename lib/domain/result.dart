class Result {
  const Result({
    required this.password,
    required this.pin,
  });

  final String password;
  final String pin;
}

class ResultRow {
  const ResultRow({
    required this.text,
    required this.visible,
  });

  final String text;

  final bool visible;

  String get showText {
    if (text.isEmpty) {
      return "-";
    } else if (!visible) {
      return "".padRight(text.length, "*");
    }
    return text;
  }
}
