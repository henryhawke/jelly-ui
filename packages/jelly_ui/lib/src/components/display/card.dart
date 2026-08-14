import 'package:flutter/material.dart';

import '../../foundation/foundation.dart';
import '../../rendering/jelly_surface.dart';
import '../../theme/jelly_theme.dart';

/// A non-interactive Jelly content surface.
class JellyCard extends StatelessWidget {
  const JellyCard({
    required this.child,
    this.padding,
    this.tone = JellySemanticTone.neutral,
    this.semanticLabel,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final JellySemanticTone tone;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = JellyTheme.of(context).resolveFor(context);
    return Semantics(
      container: true,
      label: semanticLabel,
      child: JellySurface(
        tone: tone,
        padding: padding ?? EdgeInsets.all(theme.geometry.spacing.lg),
        child: child,
      ),
    );
  }
}
