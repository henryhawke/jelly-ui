import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/jelly_theme.dart';
import 'loading_clock.dart';

/// Repaint-only loading placeholder sharing one parked package clock.
class JellySkeleton extends StatefulWidget {
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
  State<JellySkeleton> createState() => _JellySkeletonState();
}

class _JellySkeletonState extends State<JellySkeleton> {
  final _SkeletonRepaint _repaint = _SkeletonRepaint();
  late final VoidCallback _pulseListener = _repaint.pulse;
  bool _listening = false;
  bool _reduceMotion = false;

  void _setListening(bool value) {
    if (_listening == value) {
      return;
    }
    _listening = value;
    if (value) {
      JellyLoadingClock.instance.addListener(_pulseListener);
    } else {
      JellyLoadingClock.instance.removeListener(_pulseListener);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final JellyThemeData data = JellyTheme.of(context);
    _reduceMotion = data.reduceMotionFor(context);
    _setListening(widget.animate && !_reduceMotion);
  }

  @override
  void didUpdateWidget(covariant JellySkeleton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _setListening(widget.animate && !_reduceMotion);
  }

  @override
  void dispose() {
    _setListening(false);
    _repaint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final JellyThemeData data = JellyTheme.of(context);
    final theme = data.resolveFor(context);
    return Semantics(
      label: widget.semanticLabel,
      child: CustomPaint(
        painter: _JellySkeletonPainter(
          base: theme.palette.surfaceInset,
          highlight: theme.palette.surfaceRaised,
          radius: widget.radius ?? theme.geometry.radiusSmall,
          clock: _listening ? JellyLoadingClock.instance : null,
          repaint: _repaint,
        ),
        child: SizedBox(width: widget.width, height: widget.height),
      ),
    );
  }
}

final class _SkeletonRepaint extends ChangeNotifier {
  void pulse() => notifyListeners();
}

final class _JellySkeletonPainter extends CustomPainter {
  _JellySkeletonPainter({
    required this.base,
    required this.highlight,
    required this.radius,
    required this.clock,
    required Listenable repaint,
  })  : _paint = Paint(),
        super(repaint: repaint);

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
