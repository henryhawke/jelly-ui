import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'text_field.dart';

/// Digit-oriented one-time-code field built on Flutter's native editor.
class JellyOtpField extends StatelessWidget {
  const JellyOtpField({
    required this.length,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onCompleted,
    this.enabled = true,
    this.autofocus = false,
    this.semanticLabel = 'One-time code',
    super.key,
  }) : assert(length > 0);

  final int length;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool enabled;
  final bool autofocus;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return JellyTextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      autofocus: autofocus,
      semanticLabel: semanticLabel,
      hintText: List<String>.filled(length, '•').join(),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      autofillHints: const <String>[AutofillHints.oneTimeCode],
      maxLength: length,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(length),
      ],
      onChanged: (String value) {
        onChanged?.call(value);
        if (value.length == length) {
          onCompleted?.call(value);
        }
      },
    );
  }
}
