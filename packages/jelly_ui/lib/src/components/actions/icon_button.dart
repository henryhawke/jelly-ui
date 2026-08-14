import 'package:flutter/material.dart';

import '../../foundation/foundation.dart';
import '../../theme/jelly_theme.dart';
import '../internal/pressable_surface.dart';

/// Compact icon action with a full accessible target and required tooltip.
class JellyIconButton extends StatelessWidget {
  const JellyIconButton({
    required this.onPressed,
    required this.icon,
    required this.tooltip,
    this.tone = JellySemanticTone.neutral,
    this.size = JellyControlSize.standard,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget icon;
  final String tooltip;
  final JellySemanticTone tone;
  final JellyControlSize size;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = JellyTheme.of(context).resolveFor(context);
    final double paintedSize = theme.geometry.heightFor(size);
    final double target = _max(
      paintedSize,
      theme.geometry.minimumTouchTarget,
    );
    return JellyPressableSurface(
      onPressed: onPressed,
      role: JellySurfaceRole.quietAction,
      tone: tone,
      minimumSize: Size.square(target),
      semanticLabel: tooltip,
      tooltip: tooltip,
      focusNode: focusNode,
      autofocus: autofocus,
      child: Center(child: icon),
    );
  }
}

double _max(double a, double b) => a > b ? a : b;
