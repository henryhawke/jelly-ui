import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_ui/jelly_ui.dart';
import 'package:jelly_ui/src/components/feedback/loading_clock.dart';
import 'package:jelly_ui/src/motion/frame_scheduler.dart';
import 'package:jelly_ui/src/physics/membrane_body.dart';

final class _FrameSource {
  FrameCallback? callback;
  int requests = 0;

  void schedule(FrameCallback value) {
    requests += 1;
    callback = value;
  }

  void pump(Duration timestamp) {
    final FrameCallback frame = callback!;
    callback = null;
    frame(timestamp);
  }
}

final class _OneFrameClient implements JellyFrameClient {
  int advances = 0;

  @override
  bool advance(double elapsedSeconds) {
    advances += 1;
    return false;
  }
}

void main() {
  test('one frame request serves 100 simultaneous wakes and then parks', () {
    final _FrameSource source = _FrameSource();
    final JellyFrameScheduler scheduler = JellyFrameScheduler(
      scheduleFrame: source.schedule,
    );
    final List<_OneFrameClient> clients = List<_OneFrameClient>.generate(
      100,
      (int _) => _OneFrameClient(),
    );

    for (final _OneFrameClient client in clients) {
      scheduler.wake(client);
    }
    expect(source.requests, 1);
    expect(scheduler.activeCount, 100);
    source.pump(Duration.zero);
    expect(clients.every((_OneFrameClient client) => client.advances == 1),
        isTrue);
    expect(scheduler.activeCount, 0);
    expect(scheduler.isScheduled, isFalse);
  });

  testWidgets('loading clock cancels the queued frame after final teardown', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: JellyTheme.material(base: ThemeData.light()),
        home: const Column(
          children: <Widget>[
            JellySkeleton(width: 100),
            JellySkeleton(width: 120),
          ],
        ),
      ),
    );
    expect(JellyLoadingClock.instance.debugListenerCount, 2);
    expect(JellyLoadingClock.instance.debugIsScheduled, isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(JellyLoadingClock.instance.debugListenerCount, 0);
    expect(JellyLoadingClock.instance.debugIsScheduled, isFalse);
  });

  testWidgets('240 physics notifications repaint without rebuilding child', (
    WidgetTester tester,
  ) async {
    final JellySurfaceController controller = JellySurfaceController();
    addTearDown(controller.dispose);
    int builds = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: JellyTheme.material(base: ThemeData.light()),
        home: JellySurface(
          controller: controller,
          child: Builder(
            builder: (BuildContext context) {
              builds += 1;
              return const SizedBox(width: 160, height: 54);
            },
          ),
        ),
      ),
    );
    final int initialBuilds = builds;

    for (int index = 0; index < 240; index += 1) {
      controller.advance(1 / 120);
    }
    await tester.pump();
    expect(builds, initialBuilds);
  });

  test('hot-path typed buffers retain identity across updates', () {
    final JellyMembraneBody body = JellyMembraneBody(width: 180, height: 56);
    final List<Float32List> channels = <Float32List>[
      body.restX,
      body.restY,
      body.normalX,
      body.normalY,
      body.displacement,
      body.velocity,
      body.depth,
      body.depthVelocity,
      body.surfaceX,
      body.surfaceY,
      body.surfaceZ,
      body.projectedX,
      body.projectedY,
    ];

    for (int index = 0; index < 1000; index += 1) {
      body
        ..update(1 / 120)
        ..computeProjectedSurface();
    }
    final List<Float32List> after = <Float32List>[
      body.restX,
      body.restY,
      body.normalX,
      body.normalY,
      body.displacement,
      body.velocity,
      body.depth,
      body.depthVelocity,
      body.surfaceX,
      body.surfaceY,
      body.surfaceZ,
      body.projectedX,
      body.projectedY,
    ];
    for (int index = 0; index < channels.length; index += 1) {
      expect(after[index], same(channels[index]));
    }
  });

  test('hot rendering sources ban expensive compositing primitives', () async {
    File sourceFile(String relative) {
      final List<File> candidates = <File>[
        File('packages/jelly_ui/lib/src/$relative'),
        File('lib/src/$relative'),
      ];
      return candidates.firstWhere((File file) => file.existsSync());
    }

    final String source =
        '${await sourceFile('rendering/jelly_surface_painter.dart').readAsString()}\n'
        '${await sourceFile('rendering/jelly_surface.dart').readAsString()}\n'
        '${await sourceFile('physics/membrane_body.dart').readAsString()}';
    for (final String prohibited in <String>[
      'saveLayer',
      'MaskFilter.blur',
      'ImageFilter.',
      'Timer.periodic',
      'AnimationController',
    ]) {
      expect(source, isNot(contains(prohibited)), reason: prohibited);
    }
  });

  test('strong impulse settles inside the simulated-frame budget', () {
    final JellyMembraneBody body = JellyMembraneBody(width: 180, height: 56)
      ..pulseAt(24, 0, strength: 1);
    int frames = 0;
    while (!body.isResting && frames < 1200) {
      body.update(1 / 120);
      frames += 1;
    }
    // ignore: avoid_print
    print('{"settle_frames_120hz":$frames}');
    expect(body.isResting, isTrue);
    expect(frames, lessThan(1200));
  });
}
