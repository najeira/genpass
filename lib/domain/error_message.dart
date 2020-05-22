import 'package:flutter/material.dart';

class ErrorMessage {
  const ErrorMessage(this.value);

  final String value;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ErrorMessage && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => '${runtimeType}("${value}")';
}

class ErrorMessageNotifier extends ValueNotifier<ErrorMessage> {
  ErrorMessageNotifier([ErrorMessage value]) : super(value);
}
