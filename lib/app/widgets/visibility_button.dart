import 'package:flutter/material.dart';

import 'package:genpass/app/gloabls.dart' show log;

class VisibilityButton extends StatelessWidget {
  const VisibilityButton({
    super.key,
    required this.enable,
    required this.visible,
    required this.onSelected,
  });

  final bool enable;

  final bool visible;

  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    log.fine("VisibilityButton.build");
    final themeData = Theme.of(context);
    final icon = visible ? Icons.visibility : Icons.visibility_off;
    final onPressed = enable
        ? () {
            onSelected(!visible);
          }
        : null;
    return IconButton(
      icon: Icon(icon),
      color: themeData.colorScheme.primary,
      onPressed: onPressed,
    );
  }
}
