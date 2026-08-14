import 'package:flutter/material.dart';

import '../../theme/jelly_theme.dart';

/// Compact progress indicator that becomes static under reduced motion.
class JellySpinner extends StatelessWidget {
  const JellySpinner({
    this.size = 24,
    this.strokeWidth = 3,
    this.semanticLabel = 'Loading',
    super.key,
  })  : assert(size > 0),
        assert(strokeWidth > 0);

  final double size;
  final double strokeWidth;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final JellyThemeData data = JellyTheme.of(context);
    final theme = data.resolveFor(context);
    final bool reduced = data.reduceMotionFor(context);
    return SizedBox.square(
      dimension: size,
      child: CircularProgressIndicator(
        value: reduced ? 0.72 : null,
        strokeWidth: strokeWidth,
        strokeCap: StrokeCap.round,
        color: theme.palette.primary,
        backgroundColor: theme.palette.surfaceInset,
        semanticsLabel: semanticLabel,
      ),
    );
  }
}
