import 'package:flutter/material.dart';

class SettingCaption extends StatelessWidget {
  const SettingCaption({
    super.key,
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            size: 20.0,
          ),
          const SizedBox(width: 8.0),
          Text(
            title,
            style: themeData.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
