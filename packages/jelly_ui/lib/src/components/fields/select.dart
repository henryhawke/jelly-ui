import 'package:flutter/material.dart';

import '../../theme/jelly_theme.dart';
import 'field_frame.dart';

@immutable
final class JellyOption<T> {
  const JellyOption({
    required this.value,
    required this.label,
    this.enabled = true,
  });

  final T value;
  final Widget label;
  final bool enabled;
}

/// Controlled typed select that delegates menu navigation to Flutter.
class JellySelect<T> extends StatefulWidget {
  const JellySelect({
    required this.options,
    required this.value,
    required this.onChanged,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    super.key,
  });

  final List<JellyOption<T>> options;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final Widget? label;
  final Widget? hint;
  final String? helperText;
  final String? errorText;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? semanticLabel;

  @override
  State<JellySelect<T>> createState() => _JellySelectState<T>();
}

class _JellySelectState<T> extends State<JellySelect<T>> {
  FocusNode? _ownedFocusNode;

  FocusNode get _focusNode {
    return widget.focusNode ?? (_ownedFocusNode ??= FocusNode());
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_changed);
  }

  @override
  void didUpdateWidget(covariant JellySelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownedFocusNode)?.removeListener(_changed);
      if (widget.focusNode != null) {
        _ownedFocusNode?.dispose();
        _ownedFocusNode = null;
      }
      _focusNode.addListener(_changed);
    }
  }

  void _changed() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_changed);
    _ownedFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = JellyTheme.of(context).resolveFor(context);
    return JellyFieldFrame(
      enabled: widget.onChanged != null,
      focused: _focusNode.hasFocus,
      label: widget.label,
      helperText: widget.helperText,
      errorText: widget.errorText,
      padding: EdgeInsets.symmetric(horizontal: theme.geometry.spacing.md),
      child: Semantics(
        label: widget.semanticLabel,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: widget.value,
            items: widget.options
                .map(
                  (JellyOption<T> option) => DropdownMenuItem<T>(
                    value: option.value,
                    enabled: option.enabled,
                    child: option.label,
                  ),
                )
                .toList(growable: false),
            onChanged: widget.onChanged,
            focusNode: _focusNode,
            autofocus: widget.autofocus,
            hint: widget.hint,
            isExpanded: true,
            borderRadius: BorderRadius.circular(theme.geometry.radiusMedium),
            dropdownColor: theme.palette.surfaceRaised,
            focusColor: Colors.transparent,
            style: theme.typography.body,
            iconEnabledColor: theme.palette.textStrong,
            iconDisabledColor: theme.palette.disabledForeground,
          ),
        ),
      ),
    );
  }
}
