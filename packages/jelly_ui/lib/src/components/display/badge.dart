import 'package:flutter/material.dart';

import '../../foundation/foundation.dart';
import '../../rendering/jelly_surface.dart';
import '../../theme/jelly_theme.dart';

/// Small status text that never acts as the only cue for a state.
class JellyBadge extends StatelessWidget {
  const JellyBadge({
    required this.label,
    this.tone = JellySemanticTone.info,
    super.key,
  });

  final String label;
  final JellySemanticTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = JellyTheme.of(context).resolveFor(context);
    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: JellySurface(
          role: JellySurfaceRole.status,
          tone: tone,
          padding: EdgeInsets.symmetric(
            horizontal: theme.geometry.spacing.md,
            vertical: theme.geometry.spacing.xs,
          ),
          radius: 999,
          child: Text(label, style: theme.typography.instrumentLabel),
        ),
      ),
    );
  }
}
