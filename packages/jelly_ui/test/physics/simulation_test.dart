import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_ui/src/physics/membrane_body.dart';

double _maximumDisplacement(JellyMembraneBody body) {
  double result = 0;
  for (final double value in body.displacement) {
    result = math.max(result, value.abs());
  }
  return result;
}

JellyMembraneBody _runTrajectory(int refreshRate) {
  final JellyMembraneBody body = JellyMembraneBody(
    width: 100,
    height: 100,
    radius: 50,
  )..pressAt(0, 0);
  final double step = 1 / refreshRate;
  for (int frame = 0; frame < refreshRate; frame += 1) {
    if (frame == (refreshRate * 0.1).round()) {
      body.release();
    }
    body.update(step);
  }
  return body;
}

void main() {
  group('JellyMembraneBody simulation', () {
    test('center activation stays radially balanced', () {
      final JellyMembraneBody body = JellyMembraneBody(
        width: 100,
        height: 100,
        radius: 50,
      )..centerPop();

      for (int i = 0; i < 8; i += 1) {
        body.update(1 / 120);
      }

      for (int i = 0; i < body.pointCount ~/ 2; i += 1) {
        final int opposite = i + body.pointCount ~/ 2;
        expect(
          body.displacement[i],
          closeTo(body.displacement[opposite], 0.02),
        );
      }
    });

    test('released bodies settle and become eligible for scheduler parking',
        () {
      final JellyMembraneBody body = JellyMembraneBody(
        width: 160,
        height: 56,
        radius: 16,
      )..pressAt(35, 0);
      for (int i = 0; i < 8; i += 1) {
        body.update(1 / 60);
      }
      expect(body.isResting, isFalse);

      body.release();
      for (int i = 0; i < 1200 && !body.isResting; i += 1) {
        body.update(1 / 120);
      }

      expect(body.isResting, isTrue);
    });

    test('60, 90, and 120 Hz trajectories remain within one envelope', () {
      final JellyMembraneBody at60 = _runTrajectory(60);
      final JellyMembraneBody at90 = _runTrajectory(90);
      final JellyMembraneBody at120 = _runTrajectory(120);
      final double reference = _maximumDisplacement(at120);

      expect(_maximumDisplacement(at60), closeTo(reference, 0.08));
      expect(_maximumDisplacement(at90), closeTo(reference, 0.08));
    });

    test('extreme and invalid deltas never leave non-finite channels', () {
      final JellyMembraneBody body = JellyMembraneBody(
        width: 80,
        height: 40,
        radius: 20,
      )
        ..pressAt(39, 0, strength: 50)
        ..update(8)
        ..update(double.nan)
        ..release();

      for (int i = 0; i < 300; i += 1) {
        body.update(1 / 60);
      }

      expect(body.displacement.every((double value) => value.isFinite), isTrue);
      expect(body.velocity.every((double value) => value.isFinite), isTrue);
      expect(body.depth.every((double value) => value.isFinite), isTrue);
      expect(body.projectedX.every((double value) => value.isFinite), isTrue);
    });

    test('directional stretch has opposite leading and trailing signs', () {
      final JellyMembraneBody body = JellyMembraneBody(
        width: 120,
        height: 52,
        radius: 18,
      )..stretchAlong(1, 0);
      final int right = body.nearestIndex(60, 0);
      final int left = body.nearestIndex(-60, 0);

      expect(body.velocity[right], greaterThan(0));
      expect(body.velocity[left], lessThan(0));
    });
  });
}
