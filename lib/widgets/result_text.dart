import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:genpass/gloabls.dart';

class ResultText extends StatelessWidget {
  const ResultText({
    Key key,
    @required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    log.fine("ResultText.build");

    final ThemeData themeData = Theme.of(context);
    final TextTheme textTheme = themeData.textTheme;
    final String text = context.watch<String>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: textTheme.caption,
        ),
        const SizedBox(height: 4.0),
        Text(
          text ?? "",
          style: textTheme.bodyText2,
        ),
      ],
    );
  }
}
