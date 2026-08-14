import 'package:flutter/material.dart';

import '../../foundation/foundation.dart';
import '../../rendering/jelly_surface.dart';
import '../../theme/jelly_theme.dart';

/// Visual representation of a keyboard key; it is not interactive.
class JellyKbd extends StatelessWidget {
  const JellyKbd(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = JellyTheme.of(context).resolveFor(context);
    return JellySurface(
      role: JellySurfaceRole.quietAction,
      minimumSize: Size(
        theme.geometry.compactControlHeight,
        theme.geometry.compactControlHeight,
      ),
      padding: EdgeInsets.symmetric(horizontal: theme.geometry.spacing.sm),
      child: Center(child: Text(label, style: theme.typography.numeral)),
    );
  }
}
