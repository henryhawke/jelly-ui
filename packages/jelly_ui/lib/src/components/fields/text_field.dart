import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/jelly_theme.dart';
import 'field_frame.dart';

/// Native Flutter text editing with Jelly presentation and focus treatment.
class JellyTextField extends StatefulWidget {
  const JellyTextField({
    this.controller,
    this.focusNode,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.onChanged,
    this.onSubmitted,
    this.onTapOutside,
    this.semanticLabel,
    super.key,
  })  : assert(maxLines == null || maxLines > 0),
        assert(minLines == null || minLines > 0),
        assert(
          maxLines == null || minLines == null || maxLines >= minLines,
        );

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Widget? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final bool enabled;
  final bool readOnly;
  final bool obscureText;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TapRegionCallback? onTapOutside;
  final String? semanticLabel;

  @override
  State<JellyTextField> createState() => _JellyTextFieldState();
}

class _JellyTextFieldState extends State<JellyTextField> {
  FocusNode? _ownedFocusNode;

  FocusNode get _focusNode {
    return widget.focusNode ?? (_ownedFocusNode ??= FocusNode());
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant JellyTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownedFocusNode)
          ?.removeListener(_handleFocusChange);
      if (widget.focusNode != null) {
        _ownedFocusNode?.dispose();
        _ownedFocusNode = null;
      }
      _focusNode.addListener(_handleFocusChange);
    }
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _ownedFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = JellyTheme.of(context).resolveFor(context);
    final Widget editor = Semantics(
      label: widget.semanticLabel,
      textField: true,
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        obscureText: widget.obscureText,
        autofocus: widget.autofocus,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        textCapitalization: widget.textCapitalization,
        autofillHints: widget.autofillHints,
        inputFormatters: widget.inputFormatters,
        maxLength: widget.maxLength,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        onTapOutside: widget.onTapOutside,
        style: theme.typography.body,
        cursorColor: theme.palette.primary,
        decoration: InputDecoration.collapsed(
          hintText: widget.hintText,
          hintStyle: theme.typography.body.copyWith(
            color: theme.palette.textMuted,
          ),
        ),
      ),
    );
    return JellyFieldFrame(
      enabled: widget.enabled,
      focused: _focusNode.hasFocus,
      label: widget.label,
      helperText: widget.helperText,
      errorText: widget.errorText,
      minimumHeight: widget.maxLines == 1 ? theme.geometry.controlHeight : null,
      child: editor,
    );
  }
}

/// Multiline convenience wrapper that retains [TextField]'s native behavior.
class JellyTextArea extends StatelessWidget {
  const JellyTextArea({
    this.controller,
    this.focusNode,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.minLines = 4,
    this.maxLines = 8,
    this.maxLength,
    this.onChanged,
    this.semanticLabel,
    super.key,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Widget? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int minLines;
  final int? maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return JellyTextField(
      controller: controller,
      focusNode: focusNode,
      label: label,
      hintText: hintText,
      helperText: helperText,
      errorText: errorText,
      enabled: enabled,
      readOnly: readOnly,
      autofocus: autofocus,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      onChanged: onChanged,
      semanticLabel: semanticLabel,
    );
  }
}
