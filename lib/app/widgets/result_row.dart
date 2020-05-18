import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:genpass/app/gloabls.dart' show log;
import 'package:genpass/app/notifications/copy.dart';
import 'package:genpass/app/notifications/visibility.dart';

import 'copy_button.dart';
import 'visibility_button.dart';
import 'result_text.dart';

class ResultRowController extends ChangeNotifier {
  static SingleChildWidget provider({
    Widget child,
  }) {
    return ChangeNotifierProxyProvider<String, ResultRowController>(
      create: (BuildContext context) {
        return ResultRowController();
      },
      update: (BuildContext context, String value, ResultRowController previous) {
        return previous..update(value);
      },
      child: child,
    );
  }

  String _text;

  String get text => _text;

  String get showText {
    if (!enable) {
      return "-";
    } else if (!visible) {
      return "".padRight(_text.length, "*");
    }
    return _text;
  }

  bool get enable => _text != null && _text.isNotEmpty;

  bool _visible = false;

  bool get visible => _visible;

  set visible(bool newValue) {
    if (_visible != newValue) {
      _visible = newValue;
      notifyListeners();
    }
  }

  void update(String newText) {
    if (_text != newText) {
      _text = newText;
      notifyListeners();
    }
  }
}

class ResultRow extends StatelessWidget {
  ResultRow({
    Key key,
    @required this.title,
    @required this.icon,
  }) : super(key: key);

  final String title;

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    log.fine("ResultRow(${title}).build");

    Widget child = _buildRow(context);

    child = _wrapVisibilityNotificationListener(
      context,
      child,
    );

    child = _wrapCopyNotificationListener(
      context,
      child,
    );

    return child;
  }

  Widget _wrapVisibilityNotificationListener(BuildContext context, Widget child) {
    return NotificationListener<VisibilityNotification>(
      onNotification: (VisibilityNotification notification) {
        final ResultRowController controller = context.read<ResultRowController>();
        controller.visible = notification.visible;
        return true;
      },
      child: child,
    );
  }

  Widget _wrapCopyNotificationListener(BuildContext context, Widget child) {
    return NotificationListener<CopyNotification>(
      onNotification: (CopyNotification notification) {
        if (notification.text != null && notification.text.isNotEmpty) {
          _copyTextToClipboard(context, title, notification.text);
        }
        return false; // dispatch to page
      },
      child: child,
    );
  }

  Widget _buildRow(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final TextTheme textTheme = themeData.textTheme;
    return Row(
      children: <Widget>[
        Icon(
          icon,
          color: textTheme.caption.color,
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: _buildText(context),
        ),
        const VisibilityButton(),
        const CopyButton(),
      ],
    );
  }

  Widget _buildText(BuildContext context) {
    return ProxyProvider<ResultRowController, String>(
      update: (BuildContext context, ResultRowController value, String previous) {
        return value.showText;
      },
      child: ResultText(
        title: title,
      ),
    );
  }
}

Future<void> _copyTextToClipboard(BuildContext context, String title, String text) {
  assert(text != null && text.isNotEmpty);
  return Clipboard.setData(ClipboardData(text: text)).then((_) {
    log.config("clipboard: succeeded to copy");
    Scaffold.of(context, nullOk: true)?.showSnackBar(
      SnackBar(
        content: Text("${title} copied to clipboard"),
      ),
    );
  }).catchError((Object error, StackTrace stackTrace) {
    log.warning("clipboard: failed to copy", error, stackTrace);
  });
}
