import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_ui/src/physics/membrane_body.dart';
import 'package:jelly_ui/src/physics/physics_config.dart';

void main() {
  group('JellyMembraneBody geometry', () {
    test('uses preallocated typed channels at the configured quality', () {
      final JellyMembraneBody body = JellyMembraneBody(
        width: 160,
        height: 56,
        radius: 16,
        config: JellyPhysicsConfig.forSamples(96),
      );

      expect(body.pointCount, 96);
      expect(body.restX, isA<Float32List>());
      expect(body.displacement, isA<Float32List>());
      expect(body.projectedX, isA<Float32List>());
      expect(body.restX.length, body.projectedY.length);
    });

    test('samples a closed rounded rectangle at near-uniform spacing', () {
      final JellyMembraneBody body = JellyMembraneBody(
        width: 180,
        height: 72,
        radius: 20,
      );
      double shortest = double.infinity;
      double longest = 0;
      for (int i = 0; i < body.pointCount; i += 1) {
        final int next = (i + 1) % body.pointCount;
        final double dx = body.restX[next] - body.restX[i];
        final double dy = body.restY[next] - body.restY[i];
        final double distance = math.sqrt(dx * dx + dy * dy);
        shortest = math.min(shortest, distance);
        longest = math.max(longest, distance);
      }

      expect(longest / shortest, lessThan(1.12));
    });

    test('signed distance distinguishes inside, edge, and outside', () {
      final JellyMembraneBody body = JellyMembraneBody(
        width: 120,
        height: 60,
        radius: 16,
      );

      expect(body.signedDistance(0, 0), lessThan(0));
      expect(body.signedDistance(60, 0).abs(), lessThan(0.001));
      expect(body.signedDistance(80, 0), greaterThan(0));
    });

    test('resize clears motion and rebuilds finite geometry', () {
      final JellyMembraneBody body = JellyMembraneBody(
        width: 120,
        height: 60,
      )..centerPop();
      body.update(1 / 60);

      body.resize(220, 80, radius: 24);

      expect(body.width, 220);
      expect(body.height, 80);
      expect(body.radius, 24);
      expect(body.isResting, isTrue);
      expect(body.restX.every((double value) => value.isFinite), isTrue);
    });
  });
}
