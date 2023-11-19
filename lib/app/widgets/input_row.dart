import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:genpass/app/gloabls.dart';

class InputRow extends ConsumerStatefulWidget {
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
  ConsumerState<InputRow> createState() => _InputRowState();
}

class _InputRowState extends ConsumerState<InputRow> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log.fine("InputRow(${widget.labelText}).build");
    ref.listen(widget.provider, _onProviderChanged);
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              prefixIcon: Icon(widget.inputIcon),
              labelText: widget.labelText,
              hintText: widget.hintText,
              errorText: widget.errorText,
              filled: true,
            ),
            keyboardType: widget.textInputType,
            obscureText: widget.obscureText,
            autofocus: false,
            autocorrect: false,
            enableSuggestions: false,
            onChanged: (value) => _onChanged(context, value),
            onSubmitted: (value) => _onChanged(context, value),
          ),
        ),
        widget.actionButton,
      ],
    );
  }

  void _onChanged(BuildContext context, String value) {
    ProviderScope.containerOf(context, listen: false)
        .read(widget.provider.notifier)
        .state = value;
  }

  void _onProviderChanged(String? previous, String next) {
    if (_controller.text != next) {
      log.fine("InputRow(${widget.labelText})._onProviderChanged");
      _controller.text = next;
    }
  }
}
