import 'package:flutter/material.dart';

import 'package:genpass/app/gloabls.dart' show log;
import 'package:genpass/domain/result.dart';
import 'package:genpass/service/clipboard.dart';

import 'copy_button.dart';
import 'result_text.dart';
import 'visibility_button.dart';

class ResultRow extends StatelessWidget {
  const ResultRow({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.onVisiblityChanged,
  });

  final String title;
  final Value value;
  final IconData icon;
  final ValueChanged<bool> onVisiblityChanged;

  @override
  Widget build(BuildContext context) {
    log.fine("ResultRow(${title}).build");
    final themeData = Theme.of(context);
    return Row(
      children: <Widget>[
        Icon(
          icon,
          color: themeData.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: ResultText(
            title: title,
            value: value.showText,
          ),
        ),
        VisibilityButton(
          enable: value.enable,
          visible: value.visible,
          onSelected: onVisiblityChanged,
        ),
        CopyButton(
          enable: true,
          onPressed: () => setClipboard(context, title, value.rawText),
        ),
      ],
    );
  }
}
