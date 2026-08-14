import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/jelly_theme.dart';
import 'loading_clock.dart';

/// Repaint-only loading placeholder sharing one parked package clock.
class JellySkeleton extends StatelessWidget {
  const JellySkeleton({
    this.width,
    this.height = 16,
    this.radius,
    this.animate = true,
    this.semanticLabel = 'Loading',
    super.key,
  }) : assert(height >= 0);

  final double? width;
  final double height;
  final double? radius;
  final bool animate;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final JellyThemeData data = JellyTheme.of(context);
    final theme = data.resolveFor(context);
    final bool shouldAnimate = animate && !data.reduceMotionFor(context);
    return Semantics(
      label: semanticLabel,
      child: CustomPaint(
        painter: _JellySkeletonPainter(
          base: theme.palette.surfaceInset,
          highlight: theme.palette.surfaceRaised,
          radius: radius ?? theme.geometry.radiusSmall,
          clock: shouldAnimate ? JellyLoadingClock.instance : null,
        ),
        child: SizedBox(width: width, height: height),
      ),
    );
  }
}

final class _JellySkeletonPainter extends CustomPainter {
  _JellySkeletonPainter({
    required this.base,
    required this.highlight,
    required this.radius,
    required this.clock,
  })  : _paint = Paint(),
        super(repaint: clock);

  final Color base;
  final Color highlight;
  final double radius;
  final JellyLoadingClock? clock;
  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    final double wave =
        clock == null ? 0 : (math.sin(clock!.phase * math.pi * 2) + 1) * 0.5;
    _paint.color = Color.lerp(base, highlight, 0.18 + wave * 0.38)!;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      _paint,
    );
  }

  @override
  bool shouldRepaint(covariant _JellySkeletonPainter oldDelegate) {
    return base != oldDelegate.base ||
        highlight != oldDelegate.highlight ||
        radius != oldDelegate.radius ||
        clock != oldDelegate.clock;
  }
}
