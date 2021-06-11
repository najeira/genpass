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
        Text(
          value,
          style: textTheme.bodyText2,
        ),
      ],
    );
  }
}
