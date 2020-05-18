import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:genpass/app/gloabls.dart' show log;
import 'package:genpass/app/notifications/visibility.dart';

class MasterVisibilityButton extends StatelessWidget {
  const MasterVisibilityButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    log.fine("MasterVisibilityButton.build");
    final ThemeData themeData = Theme.of(context);
    final bool visible = context.watch<bool>();
    final IconData icon = visible ? Icons.visibility : Icons.visibility_off;
    return IconButton(
      icon: Icon(icon),
      color: themeData.colorScheme.primary,
      onPressed: () => VisibilityNotification(!visible).dispatch(context),
    );
  }
}
