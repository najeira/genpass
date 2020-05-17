import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:genpass/gloabls.dart';

import 'result_row.dart';

class VisibilityNotification extends Notification {
  const VisibilityNotification(this.visible);

  final bool visible;
}

class VisibilityButton extends StatelessWidget {
  const VisibilityButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    log.fine("VisibilityButton.build");

    final ResultRowController controller = context.watch<ResultRowController>();
    final IconData icon = controller.visible ? Icons.visibility : Icons.visibility_off;
    final VoidCallback onPressed = controller.enable
        ? () {
            VisibilityNotification(!controller.visible).dispatch(context);
          }
        : null;

    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
    );
  }
}
