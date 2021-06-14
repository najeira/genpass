import 'package:flutter/material.dart';

import 'package:genpass/app/gloabls.dart' show log;

class ResultText extends StatelessWidget {
  const ResultText({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    log.fine("ResultText(${title}).build");
    final themeData = Theme.of(context);
    final textTheme = themeData.textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: textTheme.caption,
        ),
        const SizedBox(height: 4.0),
        _PasswordText(value: value),
      ],
    );
  }
}

class _Segment {
  _Segment({
    required this.text,
    required this.alphabet,
  });

  final String text;
  final bool alphabet;
}

class _PasswordText extends StatelessWidget {
  _PasswordText({
    Key? key,
    required String value,
  }) : super(key: key) {
    segments = parseString(value);
  }

  late final List<_Segment> segments;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final numberColor = theme.colorScheme.secondary;
    final pin = segments.length == 1 && !segments.first.alphabet;
    return Text.rich(
      TextSpan(
        children: segments.map((e) {
          return TextSpan(
            text: e.text,
            style: TextStyle(
              color: (e.alphabet || pin) ? null : numberColor,
            ),
          );
        }).toList(),
      ),
      style: theme.textTheme.bodyText2!.copyWith(
        fontFamily: "SourceCodePro",
      ),
    );
  }

  List<_Segment> parseString(String value) {
    final segments = <_Segment>[];

    if (value == "-" || value.startsWith("*")) {
      segments.add(_Segment(
        text: value,
        alphabet: true,
      ));
      return segments;
    }

    var inAlphabets = true;
    var buf = StringBuffer();
    for (final rune in value.runes) {
      if (rune >= 48 && rune <= 57) {
        if (inAlphabets) {
          if (buf.isNotEmpty) {
            segments.add(_Segment(
              text: buf.toString(),
              alphabet: inAlphabets,
            ));
            buf = StringBuffer();
          }
        }
        inAlphabets = false;
      } else {
        if (!inAlphabets) {
          if (buf.isNotEmpty) {
            segments.add(_Segment(
              text: buf.toString(),
              alphabet: inAlphabets,
            ));
            buf = StringBuffer();
          }
        }
        inAlphabets = true;
      }
      buf.writeCharCode(rune);
    }
    if (buf.isNotEmpty) {
      segments.add(_Segment(
        text: buf.toString(),
        alphabet: inAlphabets,
      ));
    }
    return segments;
  }
}
