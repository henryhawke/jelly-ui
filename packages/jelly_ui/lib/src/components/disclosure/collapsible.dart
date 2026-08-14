import 'package:flutter/material.dart';

import '../../foundation/foundation.dart';
import '../../theme/jelly_theme.dart';
import '../internal/pressable_surface.dart';

/// Controlled disclosure with keyboard activation and motion preferences.
class JellyCollapsible extends StatelessWidget {
  const JellyCollapsible({
    required this.expanded,
    required this.onChanged,
    required this.header,
    required this.child,
    this.semanticLabel,
    this.enabled = true,
    this.maintainState = true,
    super.key,
  });

  final bool expanded;
  final ValueChanged<bool>? onChanged;
  final Widget header;
  final Widget child;
  final String? semanticLabel;
  final bool enabled;
  final bool maintainState;

  @override
  Widget build(BuildContext context) {
    final JellyThemeData data = JellyTheme.of(context);
    final theme = data.resolveFor(context);
    final Duration duration = data.reduceMotionFor(context)
        ? Duration.zero
        : theme.transitions.standard;
    final VoidCallback? activate =
        !enabled || onChanged == null ? null : () => onChanged?.call(!expanded);
    final Widget content = ClipRect(
      child: AnimatedSize(
        duration: duration,
        curve: theme.transitions.settleCurve,
        alignment: Alignment.topCenter,
        child: Visibility(
          visible: expanded,
          maintainState: maintainState,
          maintainAnimation: maintainState,
          child: Padding(
            padding: EdgeInsets.only(top: theme.geometry.spacing.sm),
            child: child,
          ),
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        JellyPressableSurface(
          onPressed: activate,
          role: JellySurfaceRole.quietAction,
          tone: JellySemanticTone.neutral,
          minimumSize: Size(0, theme.geometry.minimumTouchTarget),
          padding: EdgeInsets.symmetric(
            horizontal: theme.geometry.spacing.md,
            vertical: theme.geometry.spacing.sm,
          ),
          semanticLabel: semanticLabel,
          semanticsExpanded: expanded,
          child: Row(
            children: <Widget>[
              Expanded(
                child: DefaultTextStyle.merge(
                  style: theme.typography.label,
                  child: header,
                ),
              ),
              AnimatedRotation(
                duration: duration,
                turns: expanded ? 0.5 : 0,
                child: const Icon(Icons.keyboard_arrow_down),
              ),
            ],
          ),
        ),
        content,
      ],
    );
  }
}
