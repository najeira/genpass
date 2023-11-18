import 'package:flutter/material.dart';

import 'package:genpass/app/gloabls.dart';

class InputRow extends StatelessWidget {
  const InputRow({
    super.key,
    required this.controller,
    required this.inputIcon,
    required this.textInputType,
    required this.labelText,
    required this.hintText,
    this.errorText,
    this.obscureText = false,
    required this.actionButton,
  });

  final TextEditingController controller;
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
          child: _buildTextField(context),
        ),
        actionButton,
      ],
    );
  }

  Widget _buildTextField(BuildContext context) {
    return TextField(
      controller: controller,
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
    );
  }
}
