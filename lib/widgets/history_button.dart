import 'package:flutter/material.dart';

import '../gloabls.dart';

class HistoryNotification extends Notification {
  const HistoryNotification();
}

class HistoryButton extends StatelessWidget {
  const HistoryButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    log.fine("HistoryButton.build");
    return IconButton(
      icon: Icon(Icons.assignment),
      onPressed: () {
        HistoryNotification().dispatch(context);
      },
    );
  }
}
