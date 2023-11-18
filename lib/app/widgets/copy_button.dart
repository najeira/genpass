import 'package:flutter/material.dart';

import 'package:genpass/app/gloabls.dart' show log;

class CopyButton extends StatelessWidget {
  const CopyButton({
    super.key,
    required this.enable,
    required this.onPressed,
  });

  final bool enable;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    log.fine("CopyButton.build");
    final themeData = Theme.of(context);
    return IconButton(
      icon: const Icon(Icons.content_copy),
      color: themeData.colorScheme.primary,
      onPressed: enable ? onPressed : null,
    );
  }
}
