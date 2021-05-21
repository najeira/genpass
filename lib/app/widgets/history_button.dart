import 'package:flutter/material.dart';

import 'package:genpass/app/gloabls.dart' show log;
import 'package:genpass/app/notifications/history.dart';

class HistoryButton extends StatelessWidget {
  const HistoryButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    log.fine("HistoryButton.build");
    final themeData = Theme.of(context);
    return IconButton(
      icon: const Icon(Icons.assignment),
      color: themeData.colorScheme.primary,
      onPressed: () {
        const HistoryNotification().dispatch(context);
      },
    );
  }
}
