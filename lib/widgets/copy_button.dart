import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../gloabls.dart' show log;

import 'result_row.dart';

class CopyNotification extends Notification {
  const CopyNotification(this.text);

  final String text;
}

class CopyButton extends StatelessWidget {
  const CopyButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    log.fine("CopyButton.build");
    return Selector<ResultRowController, Tuple2<String, bool>>(
      selector: (BuildContext context, ResultRowController value) {
        return Tuple2(value.text, value.enable);
      },
      builder: (BuildContext context, Tuple2<String, bool> tuple, Widget child) {
        log.fine("CopyButton.Selector.builder");
        final ThemeData themeData = Theme.of(context);
        final String text = tuple.item1;
        final bool enable = tuple.item2;
        final VoidCallback onPressed = enable
            ? () {
                CopyNotification(text).dispatch(context);
              }
            : null;
        return IconButton(
          icon: Icon(Icons.content_copy),
          color: themeData.colorScheme.primary,
          onPressed: onPressed,
        );
      },
    );
  }
}
