import 'package:flutter/material.dart';

import '../../foundation/foundation.dart';
import '../../rendering/jelly_surface.dart';
import '../../theme/jelly_theme.dart';
import '../internal/pressable_surface.dart';

/// Supplies a controlled value and callback to descendant [JellyRadio] widgets.
class JellyRadioGroup<T> extends InheritedWidget {
  const JellyRadioGroup({
    required this.groupValue,
    required this.onChanged,
    required super.child,
    super.key,
  });

  final T? groupValue;
  final ValueChanged<T?>? onChanged;

  static JellyRadioGroup<T>? maybeOf<T>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<JellyRadioGroup<T>>();
  }

  @override
  bool updateShouldNotify(JellyRadioGroup<T> oldWidget) {
    return groupValue != oldWidget.groupValue ||
        onChanged != oldWidget.onChanged;
  }
}

/// Controlled mutually-exclusive choice, optionally wired by [JellyRadioGroup].
class JellyRadio<T> extends StatelessWidget {
  const JellyRadio({
    required this.value,
    this.groupValue,
    this.onChanged,
    this.label,
    this.semanticLabel,
    this.autofocus = false,
    this.focusNode,
    super.key,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final Widget? label;
  final String? semanticLabel;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final JellyRadioGroup<T>? group = JellyRadioGroup.maybeOf<T>(context);
    final T? effectiveGroupValue =
        group == null ? groupValue : group.groupValue;
    final ValueChanged<T?>? effectiveOnChanged =
        group == null ? onChanged : group.onChanged;
    final bool selected = value == effectiveGroupValue;
    final theme = JellyTheme.of(context).resolveFor(context);
    final VoidCallback? activate =
        effectiveOnChanged == null ? null : () => effectiveOnChanged(value);
    final Widget dot = selected
        ? const JellySurface(
            role: JellySurfaceRole.movableThumb,
            tone: JellySemanticTone.primary,
            radius: 999,
            minimumSize: Size.square(16),
            child: SizedBox.shrink(),
          )
        : const SizedBox.square(dimension: 16);
    final Widget control = JellyPressableSurface(
      onPressed: activate,
      role: JellySurfaceRole.choiceIndicator,
      tone: selected ? JellySemanticTone.info : JellySemanticTone.neutral,
      selected: selected,
      minimumSize: Size.square(theme.geometry.minimumTouchTarget),
      semanticLabel: semanticLabel,
      semanticsButton: false,
      semanticsChecked: selected,
      semanticsMutuallyExclusive: true,
      autofocus: autofocus,
      focusNode: focusNode,
      child: Center(child: dot),
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
