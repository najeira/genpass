import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ClipboardNotification extends Notification {
  const ClipboardNotification(this.name);

  final String name;
}

Future<void> setClipboard(
  BuildContext context,
  String title,
  String text,
) async {
  assert(text.isNotEmpty);
  await Clipboard.setData(ClipboardData(text: text));
  if (context.mounted) {
    final notification = ClipboardNotification(title);
    notification.dispatch(context);
  }
}
