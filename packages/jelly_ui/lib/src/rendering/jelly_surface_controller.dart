import 'package:flutter/widgets.dart';

import '../foundation/foundation.dart';
import '../motion/frame_scheduler.dart';
import '../physics/membrane_body.dart';
import '../physics/physics_config.dart';

/// Drives one surface while sharing the package-wide parked frame scheduler.
final class JellySurfaceController extends ChangeNotifier
    implements JellyFrameClient {
  JellySurfaceController()
      : _scheduler = JellyFrameScheduler.shared,
        _body = JellyMembraneBody(width: 1, height: 1);

  @visibleForTesting
  JellySurfaceController.withScheduler(JellyFrameScheduler scheduler)
      : _scheduler = scheduler,
        _body = JellyMembraneBody(width: 1, height: 1);

  final JellyFrameScheduler _scheduler;
  JellyMembraneBody _body;
  Size _size = const Size(1, 1);
  double _radius = 0.5;
  JellyMotionQuality _quality = JellyMotionQuality.standard;
  JellyMotionMode _mode = JellyMotionMode.adaptive;
  double _intensity = 1;
  bool _enabled = true;
  bool _disposed = false;
  bool _pressed = false;

  JellyMembraneBody get body => _body;
  bool get isPressed => _pressed;
  bool get isResting => _body.isResting;

  static int _samplesFor(JellyMotionQuality quality) {
    return switch (quality) {
      JellyMotionQuality.compact => 72,
      JellyMotionQuality.standard => 144,
      JellyMotionQuality.hero => 216,
    };
  }

  /// Called by the painter when layout changes; it never notifies during paint.
  void ensureGeometry(Size size, double radius) {
    if (size.isEmpty || !size.width.isFinite || !size.height.isFinite) {
      return;
    }
    if (_size == size && _radius == radius) {
      return;
    }
    _size = size;
    _radius = radius;
    _body.resize(size.width, size.height, radius: radius);
  }

  void updatePolicy({
    required JellyMotionMode mode,
    required double intensity,
    required JellyMotionQuality quality,
    required bool enabled,
  }) {
    final bool qualityChanged = quality != _quality;
    _mode = mode;
    _intensity = intensity.clamp(0, 1).toDouble();
    _enabled = enabled;
    if (qualityChanged) {
      _quality = quality;
      _body = JellyMembraneBody(
        width: _size.width,
        height: _size.height,
        radius: _radius,
        config: JellyPhysicsConfig.forSamples(_samplesFor(quality)),
      );
      notifyListeners();
    }
    if (!enabled || mode != JellyMotionMode.adaptive) {
      _scheduler.drop(this);
    } else if (!_body.isResting) {
      _scheduler.wake(this);
    }
  }

  /// [localPosition] uses surface-centred coordinates.
  void pressAt(Offset localPosition, {double strength = 1}) {
    _pressed = true;
    if (_mode == JellyMotionMode.none || _intensity == 0) {
      notifyListeners();
      return;
    }
    _body.pressAt(
      localPosition.dx,
      localPosition.dy,
      strength: strength * _intensity,
    );
    if (_mode == JellyMotionMode.reduced || !_enabled) {
      _body.update(1 / 120);
      notifyListeners();
      return;
    }
    notifyListeners();
    _scheduler.wake(this);
  }

  void moveTo(Offset localPosition) {
    if (!_pressed || _mode == JellyMotionMode.none) {
      return;
    }
    _body.moveTo(localPosition.dx, localPosition.dy);
    if (_mode == JellyMotionMode.reduced || !_enabled) {
      _body.update(1 / 120);
      notifyListeners();
      return;
    }
    _scheduler.wake(this);
  }

  void release() {
    _pressed = false;
    if (_mode == JellyMotionMode.none) {
      notifyListeners();
      return;
    }
    if (_mode == JellyMotionMode.reduced || !_enabled) {
      _body.resetMotion();
      notifyListeners();
      return;
    }
    _body.release();
    notifyListeners();
    _scheduler.wake(this);
  }

  void centerPop({double strength = 1}) {
    if (_mode != JellyMotionMode.adaptive || !_enabled || _intensity == 0) {
      return;
    }
    _body.centerPop(strength: strength * _intensity);
    notifyListeners();
    _scheduler.wake(this);
  }

  void pulseAt(Offset localPosition, {double strength = 1}) {
    if (_mode != JellyMotionMode.adaptive || !_enabled || _intensity == 0) {
      return;
    }
    _body.pulseAt(
      localPosition.dx,
      localPosition.dy,
      strength: strength * _intensity,
    );
    notifyListeners();
    _scheduler.wake(this);
  }

  void stretchAlong(Offset direction, {double strength = 1}) {
    if (_mode != JellyMotionMode.adaptive || !_enabled || _intensity == 0) {
      return;
    }
    _body.stretchAlong(
      direction.dx,
      direction.dy,
      strength: strength * _intensity,
    );
    notifyListeners();
    _scheduler.wake(this);
  }

  @override
  bool advance(double elapsedSeconds) {
    if (_disposed || !_enabled || _mode != JellyMotionMode.adaptive) {
      return false;
    }
    _body.update(elapsedSeconds);
    notifyListeners();
    return !_body.isResting;
  }

  @override
  void dispose() {
    _disposed = true;
    _scheduler.drop(this);
    super.dispose();
  }
}
