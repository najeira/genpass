import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:genpass/app/gloabls.dart';

class InputRow extends StatelessWidget {
  const InputRow({
    super.key,
    required this.provider,
    required this.inputIcon,
    required this.textInputType,
    required this.labelText,
    required this.hintText,
    this.errorText,
    this.obscureText = false,
    required this.actionButton,
  });

  final StateProvider<String> provider;
  final IconData inputIcon;
  final TextInputType textInputType;
  final String labelText;
  final String hintText;
  final String? errorText;
  final bool obscureText;
  final Widget actionButton;

  @override
  Widget build(BuildContext context) {
    log.fine("InputRow(${labelText}).build");
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(inputIcon),
              labelText: labelText,
              hintText: hintText,
              errorText: errorText,
              filled: true,
            ),
            keyboardType: textInputType,
            obscureText: obscureText,
            autofocus: false,
            autocorrect: false,
            enableSuggestions: false,
            onChanged: (value) => _onChanged(context, value),
            onSubmitted: (value) => _onChanged(context, value),
          ),
        ),
        actionButton,
      ],
    );
  }

  void _onChanged(BuildContext context, String value) {
    ProviderScope.containerOf(context, listen: false)
        .read(provider.notifier)
        .state = value;
  }
}
