import 'package:flutter/material.dart';

import '../../foundation/foundation.dart';
import '../../rendering/jelly_surface.dart';
import '../../theme/jelly_theme.dart';
import '../internal/pressable_surface.dart';

/// Compact selection/action surface using ordinary controlled Flutter state.
class JellyChip extends StatelessWidget {
  const JellyChip({
    required this.label,
    this.onPressed,
    this.selected = false,
    this.tone = JellySemanticTone.info,
    this.leading,
    super.key,
  });

  final Widget label;
  final VoidCallback? onPressed;
  final bool selected;
  final JellySemanticTone tone;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final theme = JellyTheme.of(context).resolveFor(context);
    final JellySemanticTone effectiveTone =
        selected ? tone : JellySemanticTone.neutral;
    final Color foreground = effectiveTone == JellySemanticTone.neutral
        ? theme.surfaces.quietAction
            .resolve(
              selected
                  ? const <WidgetState>{WidgetState.selected}
                  : const <WidgetState>{},
            )
            .foreground
        : theme.palette.foregroundFor(effectiveTone);
    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (leading != null) ...<Widget>[
          leading!,
          SizedBox(width: theme.geometry.spacing.sm),
        ],
        DefaultTextStyle.merge(
          style: theme.typography.label.copyWith(color: foreground),
          child: label,
        ),
      ],
    );
    final EdgeInsetsGeometry padding =
        EdgeInsets.symmetric(horizontal: theme.geometry.spacing.md);
    final Set<WidgetState> states = selected
        ? const <WidgetState>{WidgetState.selected}
        : const <WidgetState>{};
    if (onPressed == null) {
      return JellySurface(
        role: JellySurfaceRole.quietAction,
        tone: effectiveTone,
        states: states,
        minimumSize: Size(0, theme.geometry.compactControlHeight),
        padding: padding,
        child: content,
      );
    }
    return JellyPressableSurface(
      onPressed: onPressed,
      role: JellySurfaceRole.quietAction,
      tone: effectiveTone,
      selected: selected,
      semanticsSelected: selected,
      minimumSize: Size(0, theme.geometry.compactControlHeight),
      padding: padding,
      child: content,
    );
  }
}
