import 'package:flutter/material.dart';

import '../../foundation/foundation.dart';
import '../../theme/jelly_theme.dart';
import '../internal/pressable_surface.dart';

/// Controlled checkbox with optional tristate cycling.
class JellyCheckbox extends StatelessWidget {
  const JellyCheckbox({
    required this.value,
    required this.onChanged,
    this.label,
    this.semanticLabel,
    this.tristate = false,
    this.autofocus = false,
    this.focusNode,
    super.key,
  }) : assert(tristate || value != null);

  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final Widget? label;
  final String? semanticLabel;
  final bool tristate;
  final bool autofocus;
  final FocusNode? focusNode;

  bool? _nextValue() {
    if (!tristate) {
      return !(value ?? false);
    }
    return switch (value) {
      false => true,
      true => null,
      null => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = JellyTheme.of(context).resolveFor(context);
    final bool selected = value != false;
    final Widget mark = switch (value) {
      true => const Icon(Icons.check, size: 22),
      null => const Icon(Icons.remove, size: 22),
      false => const SizedBox(width: 22, height: 22),
    };
    final VoidCallback? activate =
        onChanged == null ? null : () => onChanged?.call(_nextValue());
    final Widget control = JellyPressableSurface(
      onPressed: activate,
      role: JellySurfaceRole.choiceIndicator,
      tone: selected ? JellySemanticTone.primary : JellySemanticTone.neutral,
      selected: selected,
      minimumSize: Size.square(theme.geometry.minimumTouchTarget),
      semanticLabel: semanticLabel,
      semanticsButton: false,
      semanticsChecked: value,
      focusNode: focusNode,
      autofocus: autofocus,
      child: Center(child: mark),
    );
    if (label == null) {
      return control;
    }
    return MergeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          control,
          SizedBox(width: theme.geometry.spacing.sm),
          Flexible(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              excludeFromSemantics: true,
              onTap: activate,
              child: ExcludeSemantics(
                excluding: semanticLabel != null,
                child: DefaultTextStyle.merge(
                  style: theme.typography.body,
                  child: label!,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
