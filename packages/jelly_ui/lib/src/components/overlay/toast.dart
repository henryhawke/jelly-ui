import 'package:flutter/material.dart';

import '../../foundation/foundation.dart';
import '../../rendering/jelly_surface.dart';
import '../../theme/jelly_theme.dart';

abstract final class JellyToast {
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
    BuildContext context, {
    required Widget message,
    String? semanticLabel,
    JellySemanticTone tone = JellySemanticTone.neutral,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    final theme = JellyTheme.of(context).resolveFor(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    return messenger.showSnackBar(
      SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        content: Semantics(
          liveRegion: true,
          label: semanticLabel,
          child: JellySurface(
            role: JellySurfaceRole.overlay,
            tone: tone,
            padding: EdgeInsets.symmetric(
              horizontal: theme.geometry.spacing.lg,
              vertical: theme.geometry.spacing.md,
            ),
            child: DefaultTextStyle.merge(
              style: theme.typography.body,
              child: message,
            ),
          ),
        ),
        action: action,
      ),
    );
  }
}
