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
    final ThemeData themeData = Theme.of(context);
    return IconButton(
      icon: Icon(Icons.assignment),
      color: themeData.colorScheme.primary,
      onPressed: () {
        HistoryNotification().dispatch(context);
      },
    );
  }
}
