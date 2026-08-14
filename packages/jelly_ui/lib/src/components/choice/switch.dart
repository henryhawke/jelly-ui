import 'package:flutter/material.dart';

import '../../foundation/foundation.dart';
import '../../rendering/jelly_surface.dart';
import '../../theme/jelly_theme.dart';
import '../internal/pressable_surface.dart';

/// Controlled binary switch with a stable 48dp interaction target.
class JellySwitch extends StatelessWidget {
  const JellySwitch({
    required this.value,
    required this.onChanged,
    this.label,
    this.semanticLabel,
    this.autofocus = false,
    this.focusNode,
    super.key,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget? label;
  final String? semanticLabel;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final JellyThemeData data = JellyTheme.of(context);
    final theme = data.resolveFor(context);
    final Duration duration =
        data.reduceMotionFor(context) ? Duration.zero : theme.transitions.fast;
    final VoidCallback? activate =
        onChanged == null ? null : () => onChanged?.call(!value);
    final Widget control = JellyPressableSurface(
      onPressed: activate,
      role: JellySurfaceRole.selectionTrack,
      tone: value ? JellySemanticTone.success : JellySemanticTone.neutral,
      selected: value,
      minimumSize: Size(56, theme.geometry.minimumTouchTarget),
      semanticLabel: semanticLabel,
      semanticsButton: false,
      semanticsToggled: value,
      autofocus: autofocus,
      focusNode: focusNode,
      padding: const EdgeInsets.all(5),
      child: AnimatedAlign(
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        duration: duration,
        curve: theme.transitions.settleCurve,
        child: const JellySurface(
          role: JellySurfaceRole.movableThumb,
          radius: 999,
          minimumSize: Size.square(26),
          child: SizedBox.shrink(),
        ),
      ),
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
