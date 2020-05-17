import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../gloabls.dart';

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
    return Selector<ResultRowController, Tuple2<bool, bool>>(
      selector: (BuildContext context, ResultRowController value) {
        return Tuple2(value.visible, value.enable);
      },
      builder: (BuildContext context, Tuple2<bool, bool> tuple, Widget child) {
        log.fine("VisibilityButton.Selector.builder");
        final bool visible = tuple.item1;
        final bool enable = tuple.item2;
        final IconData icon = visible ? Icons.visibility : Icons.visibility_off;
        final VoidCallback onPressed = enable
            ? () {
                VisibilityNotification(!visible).dispatch(context);
              }
            : null;
        return IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
        );
      },
    );
  }
}
