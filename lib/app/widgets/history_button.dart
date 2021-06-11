import 'package:flutter/material.dart';

import 'package:genpass/app/gloabls.dart' show log;

class HistoryButton extends StatelessWidget {
  const HistoryButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    log.fine("HistoryButton.build");
    final themeData = Theme.of(context);
    return IconButton(
      icon: const Icon(Icons.assignment),
      color: themeData.colorScheme.primary,
      onPressed: onPressed,
    );
  }
}
