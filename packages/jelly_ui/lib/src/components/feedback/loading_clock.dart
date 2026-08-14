import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// One parked frame source shared by all painted loading placeholders.
final class JellyLoadingClock extends ChangeNotifier {
  JellyLoadingClock._();

  static final JellyLoadingClock instance = JellyLoadingClock._();

  final HashMap<VoidCallback, int> _registrations = HashMap.identity();
  bool _scheduled = false;
  int? _frameCallbackId;
  double _phase = 0;

  double get phase => _phase;

  @visibleForTesting
  bool get debugIsScheduled => _scheduled;

  @visibleForTesting
  int get debugListenerCount =>
      _registrations.values.fold(0, (int total, int count) => total + count);

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _registrations.update(listener, (int count) => count + 1,
        ifAbsent: () => 1);
    _ensureFrame();
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    final int? count = _registrations[listener];
    if (count == null) {
      return;
    }
    if (count == 1) {
      _registrations.remove(listener);
    } else {
      _registrations[listener] = count - 1;
    }
    if (_registrations.isEmpty && _frameCallbackId != null) {
      SchedulerBinding.instance.cancelFrameCallbackWithId(_frameCallbackId!);
      _frameCallbackId = null;
      _scheduled = false;
    }
  }

  void _ensureFrame() {
    if (_scheduled || _registrations.isEmpty) {
      return;
    }
    _scheduled = true;
    _frameCallbackId = SchedulerBinding.instance.scheduleFrameCallback(_tick);
  }

  void _tick(Duration elapsed) {
    _scheduled = false;
    _frameCallbackId = null;
    if (_registrations.isEmpty) {
      return;
    }
    _phase = (elapsed.inMicroseconds % 1600000) / 1600000;
    notifyListeners();
    _ensureFrame();
  }
}
