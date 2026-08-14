import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_ui/src/motion/frame_scheduler.dart';

final class _FakeFrameSource {
  FrameCallback? callback;
  int requests = 0;

  void schedule(FrameCallback value) {
    requests += 1;
    callback = value;
  }

  void pump(Duration timestamp) {
    final FrameCallback? current = callback;
    callback = null;
    current!(timestamp);
  }
}

final class _Client implements JellyFrameClient {
  _Client({required this.frames, this.onAdvance});

  int frames;
  int advances = 0;
  final void Function()? onAdvance;

  @override
  bool advance(double elapsedSeconds) {
    advances += 1;
    onAdvance?.call();
    frames -= 1;
    return frames > 0;
  }
}

void main() {
  test('one frame request serves every active client and parks at rest', () {
    final _FakeFrameSource source = _FakeFrameSource();
    final JellyFrameScheduler scheduler = JellyFrameScheduler(
      scheduleFrame: source.schedule,
    );
    final _Client first = _Client(frames: 2);
    final _Client second = _Client(frames: 1);

    scheduler
      ..wake(first)
      ..wake(second);

    expect(source.requests, 1);
    expect(scheduler.activeCount, 2);
    source.pump(Duration.zero);
    expect(first.advances, 1);
    expect(second.advances, 1);
    expect(scheduler.activeCount, 1);
    expect(source.requests, 2);

    source.pump(const Duration(milliseconds: 16));
    expect(first.advances, 2);
    expect(scheduler.activeCount, 0);
    expect(scheduler.isScheduled, isFalse);
  });

  test('drop during iteration does not mutate the active set', () {
    final _FakeFrameSource source = _FakeFrameSource();
    final JellyFrameScheduler scheduler = JellyFrameScheduler(
      scheduleFrame: source.schedule,
    );
    late _Client second;
    final _Client first = _Client(
      frames: 1,
      onAdvance: () => scheduler.drop(second),
    );
    second = _Client(frames: 3);
    scheduler
      ..wake(first)
      ..wake(second);

    expect(() => source.pump(Duration.zero), returnsNormally);
    expect(scheduler.activeCount, 0);
  });
}
