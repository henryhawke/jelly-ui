import 'package:flutter/material.dart';

import '../../foundation/foundation.dart';
import '../../rendering/jelly_surface.dart';
import '../../theme/jelly_theme.dart';

/// Scaffold-compatible drawer using a Jelly overlay surface.
class JellyDrawer extends StatelessWidget {
  const JellyDrawer({
    required this.child,
    this.width = 320,
    this.semanticLabel = 'Navigation menu',
    super.key,
  });

  final Widget child;
  final double width;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = JellyTheme.of(context).resolveFor(context);
    return Drawer(
      width: width,
      elevation: 0,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Semantics(
          container: true,
          label: semanticLabel,
          child: JellySurface(
            role: JellySurfaceRole.overlay,
            radius: 0,
            padding: EdgeInsets.all(theme.geometry.spacing.lg),
            child: child,
          ),
        ),
      ),
    );
  }
}
