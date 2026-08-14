import 'package:flutter/material.dart';

import '../../foundation/foundation.dart';
import '../../rendering/jelly_surface.dart';
import '../../theme/jelly_theme.dart';

class JellyFieldFrame extends StatelessWidget {
  const JellyFieldFrame({
    required this.child,
    required this.enabled,
    required this.focused,
    this.label,
    this.helperText,
    this.errorText,
    this.minimumHeight,
    this.padding,
    super.key,
  });

  final Widget child;
  final bool enabled;
  final bool focused;
  final Widget? label;
  final String? helperText;
  final String? errorText;
  final double? minimumHeight;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = JellyTheme.of(context).resolveFor(context);
    final Set<WidgetState> states = <WidgetState>{
      if (!enabled) WidgetState.disabled,
      if (focused) WidgetState.focused,
      if (errorText != null) WidgetState.error,
    };
    final Widget field = JellySurface(
      role: JellySurfaceRole.field,
      states: states,
      minimumSize: Size(0, minimumHeight ?? theme.geometry.controlHeight),
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: theme.geometry.spacing.md,
            vertical: theme.geometry.spacing.sm,
          ),
      child: child,
    );
    if (label == null && helperText == null && errorText == null) {
      return field;
    }
    final String? support = errorText ?? helperText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (label != null) ...<Widget>[
          DefaultTextStyle.merge(
            style: theme.typography.label,
            child: label!,
          ),
          SizedBox(height: theme.geometry.spacing.xs),
        ],
        field,
        if (support != null) ...<Widget>[
          SizedBox(height: theme.geometry.spacing.xs),
          Semantics(
            liveRegion: errorText != null,
            child: Text(
              support,
              style: theme.typography.body.copyWith(
                color: errorText == null
                    ? theme.palette.textMuted
                    : theme.palette.danger,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
