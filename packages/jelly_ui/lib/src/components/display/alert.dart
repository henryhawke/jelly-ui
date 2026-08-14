import 'package:flutter/material.dart';

import '../../foundation/foundation.dart';
import '../../rendering/jelly_surface.dart';
import '../../theme/jelly_theme.dart';
import '../actions/icon_button.dart';

/// Structured status message with optional explicit dismissal.
class JellyAlert extends StatelessWidget {
  const JellyAlert({
    required this.title,
    required this.child,
    this.tone = JellySemanticTone.info,
    this.onDismiss,
    super.key,
  });

  final String title;
  final Widget child;
  final JellySemanticTone tone;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = JellyTheme.of(context).resolveFor(context);
    return Semantics(
      container: true,
      liveRegion: tone == JellySemanticTone.danger,
      child: JellySurface(
        role: JellySurfaceRole.status,
        tone: tone,
        padding: EdgeInsets.all(theme.geometry.spacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: theme.typography.title.copyWith(
                      color: theme.palette.foregroundFor(tone),
                    ),
                  ),
                  SizedBox(height: theme.geometry.spacing.sm),
                  child,
                ],
              ),
            ),
            if (onDismiss != null) ...<Widget>[
              SizedBox(width: theme.geometry.spacing.md),
              JellyIconButton(
                onPressed: onDismiss,
                icon: const Icon(Icons.close),
                tooltip: 'Dismiss $title',
                size: JellyControlSize.compact,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
