import 'package:flutter/material.dart';

class SettingCaption extends StatelessWidget {
  const SettingCaption({
    Key? key,
    required this.icon,
    required this.title,
  }) : super(key: key);

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final textTheme = themeData.textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            size: textTheme.titleMedium!.fontSize,
          ),
          const SizedBox(width: 8.0),
          Text(
            title,
            style: TextStyle(
              fontSize: textTheme.titleMedium!.fontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
