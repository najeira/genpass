import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:genpass/gloabls.dart';

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

    final ResultRowController controller = context.watch<ResultRowController>();
    final VoidCallback onPressed = controller.enable
        ? () {
            CopyNotification(controller.text).dispatch(context);
          }
        : null;

    return IconButton(
      icon: Icon(Icons.content_copy),
      onPressed: onPressed,
    );
  }
}
