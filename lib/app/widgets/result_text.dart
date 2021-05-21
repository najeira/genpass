import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:genpass/app/gloabls.dart' show log;

class ResultText extends StatelessWidget {
  const ResultText({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    log.fine("ResultText(${title}).build");

    final themeData = Theme.of(context);
    final textTheme = themeData.textTheme;

    final text = context.watch<String>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: textTheme.caption,
        ),
        const SizedBox(height: 4.0),
        Text(
          text,
          style: textTheme.bodyText2,
        ),
      ],
    );
  }
}
