import 'dart:ui';

import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_ui/jelly_ui.dart';
import 'package:jelly_ui/src/motion/frame_scheduler.dart';

void main() {
  test('controller wakes once, advances, and leaves the scheduler at rest', () {
    FrameCallback? callback;
    final JellyFrameScheduler scheduler = JellyFrameScheduler(
      scheduleFrame: (FrameCallback value) => callback = value,
    );
    final JellySurfaceController controller =
        JellySurfaceController.withScheduler(scheduler)
          ..ensureGeometry(const Size(160, 56), 16)
          ..updatePolicy(
            mode: JellyMotionMode.adaptive,
            intensity: 1,
            quality: JellyMotionQuality.standard,
            enabled: true,
          )
          ..pressAt(const Offset(20, 0));

    expect(scheduler.activeCount, 1);
    controller.release();
    Duration elapsed = Duration.zero;
    for (int i = 0; i < 2000 && callback != null; i += 1) {
      final FrameCallback frame = callback!;
      callback = null;
      frame(elapsed);
      elapsed += const Duration(microseconds: 8333);
    }

    expect(controller.isResting, isTrue);
    expect(scheduler.activeCount, 0);
    controller.dispose();
  });

  test('reduced motion applies one bounded frame and no trailing scheduler',
      () {
    FrameCallback? callback;
    final JellyFrameScheduler scheduler = JellyFrameScheduler(
      scheduleFrame: (FrameCallback value) => callback = value,
    );
    final JellySurfaceController controller =
        JellySurfaceController.withScheduler(scheduler)
          ..ensureGeometry(const Size(120, 48), 16)
          ..updatePolicy(
            mode: JellyMotionMode.reduced,
            intensity: 1,
            quality: JellyMotionQuality.standard,
            enabled: true,
          )
          ..pressAt(Offset.zero);

    expect(callback, isNull);
    expect(controller.isResting, isFalse);
    controller.release();
    expect(controller.isResting, isTrue);
    controller.dispose();
  });
}
