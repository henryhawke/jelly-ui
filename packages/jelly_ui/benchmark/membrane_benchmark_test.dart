import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_ui/src/physics/membrane_body.dart';
import 'package:jelly_ui/src/physics/physics_config.dart';

const double _standardBudgetMicros = 1000;
const double _heroBudgetMicros = 1500;

double _meanFrameMicros({
  required int samples,
  required int iterations,
}) {
  final JellyMembraneBody body = JellyMembraneBody(
    width: 180,
    height: 56,
    radius: 16,
    config: JellyPhysicsConfig.forSamples(samples),
  );
  for (int index = 0; index < 200; index += 1) {
    if (index % 60 == 0) {
      body.pulseAt(24, 0, strength: 0.8);
    }
    body
      ..update(1 / 120)
      ..computeProjectedSurface();
  }

  final Stopwatch stopwatch = Stopwatch()..start();
  for (int index = 0; index < iterations; index += 1) {
    if (index % 120 == 0) {
      body.pulseAt(-20, 6, strength: 0.8);
    }
    body
      ..update(1 / 120)
      ..computeProjectedSurface();
  }
  stopwatch.stop();
  return stopwatch.elapsedMicroseconds / iterations;
}

void main() {
  test('standard 144-sample physics stays inside the lab CPU alarm', () {
    final double mean = _meanFrameMicros(samples: 144, iterations: 4000);
    // Printed output is the local lab receipt; the assertion is intentionally
    // generous because debug VM timing is not a device frame-time benchmark.
    // ignore: avoid_print
    print('{"tier":"standard","mean_cpu_us":${mean.toStringAsFixed(2)}}');
    expect(mean, lessThan(_standardBudgetMicros));
  });

  test('hero 216-sample physics stays inside the lab CPU alarm', () {
    final double mean = _meanFrameMicros(samples: 216, iterations: 4000);
    // ignore: avoid_print
    print('{"tier":"hero","mean_cpu_us":${mean.toStringAsFixed(2)}}');
    expect(mean, lessThan(_heroBudgetMicros));
  });
}
