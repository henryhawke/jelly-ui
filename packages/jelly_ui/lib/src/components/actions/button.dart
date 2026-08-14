import 'package:flutter/material.dart';

import '../../foundation/foundation.dart';
import '../../theme/jelly_theme.dart';
import '../internal/pressable_surface.dart';

enum JellyButtonVariant { solid, quiet }

/// A keyboard-, pointer-, touch-, and semantics-complete Jelly action.
class JellyButton extends StatelessWidget {
  const JellyButton({
    required this.onPressed,
    required this.child,
    this.tone = JellySemanticTone.primary,
    this.variant = JellyButtonVariant.solid,
    this.size = JellyControlSize.standard,
    this.loading = false,
    this.loadingLabel = 'Loading',
    this.semanticLabel,
    this.tooltip,
    this.focusNode,
    this.autofocus = false,
    this.expanded = false,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final JellySemanticTone tone;
  final JellyButtonVariant variant;
  final JellyControlSize size;
  final bool loading;
  final String loadingLabel;
  final String? semanticLabel;
  final String? tooltip;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final theme = JellyTheme.of(context).resolveFor(context);
    final double height = theme.geometry.heightFor(size);
    final Widget label = DefaultTextStyle.merge(
      style: theme.typography.label,
      child: loading
          ? Text(
              loadingLabel.toUpperCase(),
              style: theme.typography.instrumentLabel,
            )
          : child,
    );
    final Widget button = JellyPressableSurface(
      onPressed: loading ? null : onPressed,
      role: variant == JellyButtonVariant.solid
          ? JellySurfaceRole.action
          : JellySurfaceRole.quietAction,
      tone: tone,
      minimumSize: Size(0, height),
      padding: EdgeInsets.symmetric(horizontal: theme.geometry.spacing.lg),
      semanticLabel: semanticLabel,
      tooltip: tooltip,
      focusNode: focusNode,
      autofocus: autofocus,
      child: Center(widthFactor: expanded ? null : 1, child: label),
    );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
