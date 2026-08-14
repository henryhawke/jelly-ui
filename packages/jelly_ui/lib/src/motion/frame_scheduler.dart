import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

abstract interface class JellyFrameClient {
  /// Advances one frame and returns whether another frame is required.
  bool advance(double elapsedSeconds);
}

typedef JellyScheduleFrame = void Function(FrameCallback callback);

/// One allocation-conscious frame loop shared by every active Jelly surface.
final class JellyFrameScheduler {
  JellyFrameScheduler({JellyScheduleFrame? scheduleFrame})
      : _scheduleFrame = scheduleFrame ?? _scheduleWithBinding;

  static final JellyFrameScheduler shared = JellyFrameScheduler();

  static void _scheduleWithBinding(FrameCallback callback) {
    SchedulerBinding.instance.scheduleFrameCallback(callback);
  }

  final JellyScheduleFrame _scheduleFrame;
  final LinkedHashSet<JellyFrameClient> _active =
      LinkedHashSet<JellyFrameClient>.identity();
  final LinkedHashSet<JellyFrameClient> _pendingAdd =
      LinkedHashSet<JellyFrameClient>.identity();
  final LinkedHashSet<JellyFrameClient> _pendingRemove =
      LinkedHashSet<JellyFrameClient>.identity();

  bool _scheduled = false;
  bool _ticking = false;
  Duration? _lastTimestamp;

  @visibleForTesting
  int get activeCount => _active.length + _pendingAdd.length;

  @visibleForTesting
  bool get isScheduled => _scheduled;

  void wake(JellyFrameClient client) {
    if (_ticking) {
      _pendingRemove.remove(client);
      _pendingAdd.add(client);
    } else {
      _active.add(client);
    }
    _requestFrame();
  }

  void drop(JellyFrameClient client) {
    if (_ticking) {
      _pendingAdd.remove(client);
      _pendingRemove.add(client);
    } else {
      _active.remove(client);
    }
    if (_active.isEmpty && _pendingAdd.isEmpty) {
      _lastTimestamp = null;
    }
  }

  void _requestFrame() {
    if (_scheduled || (_active.isEmpty && _pendingAdd.isEmpty)) {
      return;
    }
    _scheduled = true;
    _scheduleFrame(_onFrame);
  }

  void _onFrame(Duration timestamp) {
    _scheduled = false;
    if (_active.isEmpty && _pendingAdd.isEmpty) {
      _lastTimestamp = null;
      return;
    }

    if (_pendingAdd.isNotEmpty) {
      _active.addAll(_pendingAdd);
      _pendingAdd.clear();
    }
    final Duration? previous = _lastTimestamp;
    final double elapsedSeconds = previous == null
        ? 1 / 60
        : (timestamp - previous).inMicroseconds /
            Duration.microsecondsPerSecond;
    _lastTimestamp = timestamp;

    _ticking = true;
    for (final JellyFrameClient client in _active) {
      try {
        if (!client.advance(elapsedSeconds)) {
          _pendingRemove.add(client);
        }
      } catch (error, stackTrace) {
        _pendingRemove.add(client);
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
            library: 'jelly_ui',
            context: ErrorDescription('while advancing a Jelly surface'),
          ),
        );
      }
    }
    _ticking = false;

    if (_pendingRemove.isNotEmpty) {
      _active.removeAll(_pendingRemove);
      _pendingRemove.clear();
    }
    if (_pendingAdd.isNotEmpty) {
      _active.addAll(_pendingAdd);
      _pendingAdd.clear();
    }

    if (_active.isEmpty) {
      _lastTimestamp = null;
      return;
    }
    _requestFrame();
  }
}
