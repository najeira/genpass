import 'package:flutter/material.dart';

import 'package:genpass/app/gloabls.dart' show log;

class HistoryButton extends StatelessWidget {
  const HistoryButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    log.fine("HistoryButton.build");
    final themeData = Theme.of(context);
    return IconButton(
      icon: const Icon(Icons.list_alt),
      color: themeData.colorScheme.primary,
      onPressed: onPressed,
    );
  }
}
