import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'jelly_surface_controller.dart';

final class JellySurfacePainter extends CustomPainter {
  JellySurfacePainter({
    required this.controller,
    required this.style,
    required this.backgroundColor,
    required this.focused,
    required this.focusWidth,
    required this.focusGap,
    required this.curveTension,
  }) : super(repaint: controller);

  final JellySurfaceController controller;
  final JellySurfaceStyle style;
  final Color backgroundColor;
  final bool focused;
  final double focusWidth;
  final double focusGap;
  final double curveTension;

  final Path _path = Path();
  final Paint _fillPaint = Paint()..style = PaintingStyle.fill;
  final Paint _strokePaint = Paint()..style = PaintingStyle.stroke;

  void _tracePath() {
    final int length = controller.body.pointCount;
    final List<double> x = controller.body.projectedX;
    final List<double> y = controller.body.projectedY;
    _path.reset();
    _path.moveTo(x[0], y[0]);
    for (int i = 0; i < length; i += 1) {
      final int previous = (i - 1 + length) % length;
      final int next = (i + 1) % length;
      final int afterNext = (i + 2) % length;
      final double firstControlX =
          x[i] + (x[next] - x[previous]) * curveTension / 6;
      final double firstControlY =
          y[i] + (y[next] - y[previous]) * curveTension / 6;
      final double secondControlX =
          x[next] - (x[afterNext] - x[i]) * curveTension / 6;
      final double secondControlY =
          y[next] - (y[afterNext] - y[i]) * curveTension / 6;
      _path.cubicTo(
        firstControlX,
        firstControlY,
        secondControlX,
        secondControlY,
        x[next],
        y[next],
      );
    }
    _path.close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    controller.ensureGeometry(size, style.radius);
    controller.body.computeProjectedSurface();
    _tracePath();

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    if (style.shadowOffset != Offset.zero) {
      canvas.save();
      canvas.translate(style.shadowOffset.dx, style.shadowOffset.dy);
      _fillPaint.color = style.shadow;
      canvas.drawPath(_path, _fillPaint);
      canvas.restore();
    }

    if (focused && focusWidth > 0) {
      _strokePaint
        ..color = style.focus
        ..strokeWidth = style.borderWidth + 2 * (focusGap + focusWidth);
      canvas.drawPath(_path, _strokePaint);
      if (focusGap > 0) {
        _strokePaint
          ..color = backgroundColor
          ..strokeWidth = style.borderWidth + 2 * focusGap;
        canvas.drawPath(_path, _strokePaint);
      }
    }

    _fillPaint.color = style.fill;
    canvas.drawPath(_path, _fillPaint);
    if (style.borderWidth > 0) {
      _strokePaint
        ..color = style.border
        ..strokeWidth = style.borderWidth;
      canvas.drawPath(_path, _strokePaint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant JellySurfacePainter oldDelegate) {
    return controller != oldDelegate.controller ||
        style != oldDelegate.style ||
        backgroundColor != oldDelegate.backgroundColor ||
        focused != oldDelegate.focused ||
        focusWidth != oldDelegate.focusWidth ||
        focusGap != oldDelegate.focusGap ||
        curveTension != oldDelegate.curveTension;
  }
}
