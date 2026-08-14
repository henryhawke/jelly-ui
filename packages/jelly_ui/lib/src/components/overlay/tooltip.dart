import 'package:flutter/material.dart';

import '../../theme/jelly_theme.dart';

/// Token-styled native tooltip.
class JellyTooltip extends StatelessWidget {
  const JellyTooltip({
    required this.message,
    required this.child,
    this.waitDuration,
    this.showDuration,
    this.preferBelow,
    this.triggerMode,
    super.key,
  });

  final String message;
  final Widget child;
  final Duration? waitDuration;
  final Duration? showDuration;
  final bool? preferBelow;
  final TooltipTriggerMode? triggerMode;

  @override
  Widget build(BuildContext context) {
    final theme = JellyTheme.of(context).resolveFor(context);
    return Tooltip(
      message: message,
      waitDuration: waitDuration,
      showDuration: showDuration,
      preferBelow: preferBelow,
      triggerMode: triggerMode,
      textStyle: theme.typography.label.copyWith(
        color: theme.palette.focusOnDark,
      ),
      decoration: BoxDecoration(
        color: theme.palette.textStrong,
        border: Border.all(
          color: theme.palette.border,
          width: theme.geometry.borderThin,
        ),
        borderRadius: BorderRadius.circular(theme.geometry.radiusSmall),
      ),
      child: child,
    );
  }
}
