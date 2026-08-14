import 'package:flutter/material.dart';

import '../../foundation/foundation.dart';
import '../../rendering/jelly_surface.dart';

/// Determinate progress with repaint-isolated Jelly surfaces.
class JellyProgress extends StatelessWidget {
  const JellyProgress({
    required this.value,
    this.height = 14,
    this.tone = JellySemanticTone.primary,
    this.semanticLabel = 'Progress',
    this.semanticValue,
    super.key,
  })  : assert(value >= 0 && value <= 1),
        assert(height > 0);

  final double value;
  final double height;
  final JellySemanticTone tone;
  final String semanticLabel;
  final String? semanticValue;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      value: semanticValue ?? '${(value * 100).round()}%',
      child: JellySurface(
        role: JellySurfaceRole.progress,
        minimumSize: Size(0, height),
        radius: 999,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              widthFactor: value,
              child: JellySurface(
                role: JellySurfaceRole.status,
                tone: tone,
                radius: 999,
                minimumSize: Size(0, height),
                child: SizedBox(height: height),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
