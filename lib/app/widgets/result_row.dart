import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:genpass/app/gloabls.dart' show log;

import 'copy_button.dart';
import 'result_text.dart';
import 'visibility_button.dart';

class ResultRow extends StatelessWidget {
  const ResultRow({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.enable,
    required this.visible,
    required this.onVisiblityChanged,
  }) : super(key: key);

  final String title;
  final String value;
  final IconData icon;
  final bool enable;
  final bool visible;
  final ValueChanged<bool> onVisiblityChanged;

  @override
  Widget build(BuildContext context) {
    log.fine("ResultRow(${title}).build");
    final themeData = Theme.of(context);
    final textTheme = themeData.textTheme;
    return Row(
      children: <Widget>[
        Icon(
          icon,
          color: textTheme.caption!.color,
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: ResultText(
            title: title,
            value: value,
          ),
        ),
        VisibilityButton(
          enable: enable,
          visible: visible,
          onSelected: onVisiblityChanged,
        ),
        CopyButton(
          enable: true,
          onPressed: () {
            _copyTextToClipboard(context, title, value);
          },
        ),
      ],
    );
  }
}

Future<void> _copyTextToClipboard(
    BuildContext context, String title, String text) {
  assert(text.isNotEmpty);
  return Clipboard.setData(ClipboardData(text: text)).then((_) {
    log.config("clipboard: succeeded to copy");
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text("${title} copied to clipboard"),
      ),
    );
  }).catchError((Object error, StackTrace stackTrace) {
    log.warning("clipboard: failed to copy", error, stackTrace);
  });
}
