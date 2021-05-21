import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import 'package:genpass/app/gloabls.dart';
import 'package:genpass/domain/error_message.dart';

class InputRow extends StatelessWidget {
  const InputRow({
    Key? key,
    required this.inputIcon,
    required this.textInputType,
    required this.labelText,
    required this.hintText,
    this.obscureText = false,
    required this.actionButton,
  }) : super(key: key);

  final IconData inputIcon;

  final TextInputType textInputType;
  final String labelText;
  final String hintText;
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
    log.fine("InputRow(${labelText})._buildTextField");
    final controller = Provider.of<TextEditingController>(context, listen: false);
    final errorMessage = context.watch<ErrorMessage?>();
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        icon: Icon(inputIcon, size: kInputIconSize),
        labelText: labelText,
        hintText: hintText,
        errorText: errorMessage?.value,
      ),
      keyboardType: textInputType,
      obscureText: obscureText,
    );
  }
}
