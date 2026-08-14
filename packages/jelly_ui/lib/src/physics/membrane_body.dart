import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'physics_config.dart';

double _clamp(double value, double minimum, double maximum) {
  return value.clamp(minimum, maximum).toDouble();
}

double _smoothstep(double edge0, double edge1, double value) {
  final double t = _clamp((value - edge0) / (edge1 - edge0), 0, 1);
  return t * t * (3 - 2 * t);
}

double _gaussian(double distance, double width) {
  return math.exp(-(distance * distance) / (2 * width * width));
}

int _wrap(int index, int length) => (index + length) % length;

int _ringDistance(int a, int b, int length) {
  final int distance = (a - b).abs();
  return math.min(distance, length - distance);
}

/// Allocation-conscious soft body in shape-centred logical coordinates.
///
/// Every hot-path channel is a preallocated [Float32List]. Geometry setup may
/// allocate temporary offsets, but [update] and [computeProjectedSurface] do not.
final class JellyMembraneBody {
  JellyMembraneBody({
    required double width,
    required double height,
    double? radius,
    JellyPhysicsConfig config = const JellyPhysicsConfig(),
  })  : _width = width,
        _height = height,
        _radius = radius ?? math.min(width, height) / 2,
        _config = config,
        restX = Float32List(config.samples),
        restY = Float32List(config.samples),
        normalX = Float32List(config.samples),
        normalY = Float32List(config.samples),
        displacement = Float32List(config.samples),
        velocity = Float32List(config.samples),
        depth = Float32List(config.samples),
        depthVelocity = Float32List(config.samples),
        surfaceX = Float32List(config.samples),
        surfaceY = Float32List(config.samples),
        surfaceZ = Float32List(config.samples),
        projectedX = Float32List(config.samples),
        projectedY = Float32List(config.samples),
        _totalDisplacement = Float32List(config.samples),
        _totalDepth = Float32List(config.samples),
        _membraneAcceleration = Float32List(config.samples),
        _depthAcceleration = Float32List(config.samples),
        _scratchX = Float32List(config.samples),
        _scratchY = Float32List(config.samples) {
    _validateSize(width, height);
    _rebuildGeometry();
  }

  final JellyPhysicsConfig _config;

  final Float32List restX;
  final Float32List restY;
  final Float32List normalX;
  final Float32List normalY;
  final Float32List displacement;
  final Float32List velocity;
  final Float32List depth;
  final Float32List depthVelocity;
  final Float32List surfaceX;
  final Float32List surfaceY;
  final Float32List surfaceZ;
  final Float32List projectedX;
  final Float32List projectedY;

  final Float32List _totalDisplacement;
  final Float32List _totalDepth;
  final Float32List _membraneAcceleration;
  final Float32List _depthAcceleration;
  final Float32List _scratchX;
  final Float32List _scratchY;

  double _width;
  double _height;
  double _radius;
  double _baseArea = 0;

  double lean = 0;
  double leanAmount = 0;

  double _clickDepth = 0;
  double _clickDepthVelocity = 0;
  double _targetClickDepth = 0;
  double _insidePress = 0;
  double _insidePressVelocity = 0;
  double _targetInsidePress = 0;
  double _press = 0;
  double _pressVelocity = 0;
  double _targetPress = 0;
  double _insideCurveHold = 0;
  double _insideCurveHoldVelocity = 0;
  double _targetInsideCurveHold = 0;
  double _rotation = 0;
  double _rotationVelocity = 0;
  double _tiltX = 0;
  double _tiltXVelocity = 0;
  double _tiltY = 0;
  double _tiltYVelocity = 0;
  double _targetTiltX = 0;
  double _targetTiltY = 0;
  bool _pointerActive = false;
  double _pointerInsideWeight = 0;
  double _pointerX = 0;
  double _pointerY = 0;

  int get pointCount => restX.length;
  double get width => _width;
  double get height => _height;
  double get radius => _radius;
  double get rotation => _rotation;
  double get tiltX => _tiltX;
  double get tiltY => _tiltY;
  double get press => _press;
  bool get pointerActive => _pointerActive;

  static void _validateSize(double width, double height) {
    if (!width.isFinite || !height.isFinite || width <= 0 || height <= 0) {
      throw ArgumentError('Jelly body size must be finite and positive.');
    }
  }

  void resize(double width, double height, {double? radius}) {
    _validateSize(width, height);
    _width = width;
    _height = height;
    _radius = radius ?? math.min(width, height) / 2;
    resetMotion();
    _rebuildGeometry();
  }

  void _rebuildGeometry() {
    final double halfWidth = _width / 2;
    final double halfHeight = _height / 2;
    final double safeRadius = _clamp(
      _radius,
      0,
      math.min(halfWidth, halfHeight),
    );
    _radius = safeRadius;

    final List<Offset> dense = <Offset>[];
    const int edgeSteps = 48;
    const int arcSteps = 48;

    void line(
      double ax,
      double ay,
      double bx,
      double by, {
      required bool includeStart,
    }) {
      for (int i = includeStart ? 0 : 1; i <= edgeSteps; i += 1) {
        final double t = i / edgeSteps;
        dense.add(Offset(ax + (bx - ax) * t, ay + (by - ay) * t));
      }
    }

    void arc(double cx, double cy, double start, double end) {
      for (int i = 1; i <= arcSteps; i += 1) {
        final double angle = start + (end - start) * (i / arcSteps);
        dense.add(
          Offset(
            cx + math.cos(angle) * safeRadius,
            cy + math.sin(angle) * safeRadius,
          ),
        );
      }
    }

    line(
      -halfWidth + safeRadius,
      -halfHeight,
      halfWidth - safeRadius,
      -halfHeight,
      includeStart: true,
    );
    arc(
      halfWidth - safeRadius,
      -halfHeight + safeRadius,
      -math.pi / 2,
      0,
    );
    line(
      halfWidth,
      -halfHeight + safeRadius,
      halfWidth,
      halfHeight - safeRadius,
      includeStart: false,
    );
    arc(
      halfWidth - safeRadius,
      halfHeight - safeRadius,
      0,
      math.pi / 2,
    );
    line(
      halfWidth - safeRadius,
      halfHeight,
      -halfWidth + safeRadius,
      halfHeight,
      includeStart: false,
    );
    arc(
      -halfWidth + safeRadius,
      halfHeight - safeRadius,
      math.pi / 2,
      math.pi,
    );
    line(
      -halfWidth,
      halfHeight - safeRadius,
      -halfWidth,
      -halfHeight + safeRadius,
      includeStart: false,
    );
    arc(
      -halfWidth + safeRadius,
      -halfHeight + safeRadius,
      math.pi,
      math.pi * 1.5,
    );

    final Float64List cumulative = Float64List(dense.length + 1);
    double perimeter = 0;
    for (int i = 0; i < dense.length; i += 1) {
      final Offset a = dense[i];
      final Offset b = dense[(i + 1) % dense.length];
      perimeter += (b - a).distance;
      cumulative[i + 1] = perimeter;
    }

    int segmentIndex = 0;
    for (int sample = 0; sample < pointCount; sample += 1) {
      final double target = sample / pointCount * perimeter;
      while (segmentIndex < dense.length - 1 &&
          cumulative[segmentIndex + 1] < target) {
        segmentIndex += 1;
      }
      final Offset a = dense[segmentIndex];
      final Offset b = dense[(segmentIndex + 1) % dense.length];
      final double start = cumulative[segmentIndex];
      final double length = math.max(
        cumulative[segmentIndex + 1] - start,
        0.0001,
      );
      final double t = (target - start) / length;
      restX[sample] = a.dx + (b.dx - a.dx) * t;
      restY[sample] = a.dy + (b.dy - a.dy) * t;
    }

    _buildNormals();
    computeProjectedSurface();
    _baseArea = _surfaceArea();
  }

  void _buildNormals() {
    for (int i = 0; i < pointCount; i += 1) {
      final int previous = _wrap(i - 1, pointCount);
      final int next = _wrap(i + 1, pointCount);
      final double tangentX = restX[next] - restX[previous];
      final double tangentY = restY[next] - restY[previous];
      final double length = math.sqrt(
        tangentY * tangentY + tangentX * tangentX,
      );
      final double denominator = length == 0 ? 1 : length;
      normalX[i] = tangentY / denominator;
      normalY[i] = -tangentX / denominator;
    }

    for (int pass = 0; pass < _config.normalBlendPasses; pass += 1) {
      for (int i = 0; i < pointCount; i += 1) {
        final int previous = _wrap(i - 1, pointCount);
        final int next = _wrap(i + 1, pointCount);
        final double x =
            normalX[previous] * 0.22 + normalX[i] * 0.56 + normalX[next] * 0.22;
        final double y =
            normalY[previous] * 0.22 + normalY[i] * 0.56 + normalY[next] * 0.22;
        final double length = math.sqrt(x * x + y * y);
        final double denominator = length == 0 ? 1 : length;
        _scratchX[i] = x / denominator;
        _scratchY[i] = y / denominator;
      }
      normalX.setAll(0, _scratchX);
      normalY.setAll(0, _scratchY);
    }
  }

  double signedDistance(double x, double y) {
    final double halfWidth = _width / 2;
    final double halfHeight = _height / 2;
    final double safeRadius =
        math.min(_radius, math.min(halfWidth, halfHeight));
    final double qx = x.abs() - (halfWidth - safeRadius);
    final double qy = y.abs() - (halfHeight - safeRadius);
    final double outsideX = math.max(qx, 0);
    final double outsideY = math.max(qy, 0);
    final double outside = math.sqrt(
      outsideX * outsideX + outsideY * outsideY,
    );
    final double inside = math.min(math.max(qx, qy), 0);
    return outside + inside - safeRadius;
  }

  int nearestIndex(double x, double y) {
    int nearest = 0;
    double nearestDistance = double.infinity;
    for (int i = 0; i < pointCount; i += 1) {
      final double dx = x - restX[i];
      final double dy = y - restY[i];
      final double distance = dx * dx + dy * dy;
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearest = i;
      }
    }
    return nearest;
  }

  void _addMembraneImpulse(int index, double amount, double width) {
    for (int i = 0; i < pointCount; i += 1) {
      final int distance = _ringDistance(i, index, pointCount);
      velocity[i] += amount * _gaussian(distance.toDouble(), width);
    }
  }

  void _addInsideImpulse(double amount) {
    final double edgeBoost = _insideEdgeBoost();
    for (int i = 0; i < pointCount; i += 1) {
      final double dx = restX[i] - _pointerX;
      final double dy = restY[i] - _pointerY;
      final double distance = math.sqrt(dx * dx + dy * dy);
      final double local =
          _gaussian(distance, _config.insidePointInfluenceWidth) * edgeBoost;
      final double haloBase = _gaussian(
        distance,
        _config.insidePointHaloWidth,
      );
      final double halo = math.max(haloBase - local * 0.34, 0);
      velocity[i] += amount * (local - halo * 0.18);
    }
  }

  double _insideEdgeBoost() {
    final double halfWidth = math.max(_width / 2, 0.0001);
    final double halfHeight = math.max(_height / 2, 0.0001);
    final double pointerRadius = _clamp(
      math.sqrt(
        (_pointerX / halfWidth) * (_pointerX / halfWidth) +
            (_pointerY / halfHeight) * (_pointerY / halfHeight),
      ),
      0,
      1,
    );
    return 1 +
        _smoothstep(0.12, 0.82, pointerRadius) * _config.insidePointEdgeBoost;
  }

  double _smooth(Float32List values, int index) {
    return values[_wrap(index - 2, pointCount)] * 0.06 +
        values[_wrap(index - 1, pointCount)] * 0.2 +
        values[index] * 0.48 +
        values[_wrap(index + 1, pointCount)] * 0.2 +
        values[_wrap(index + 2, pointCount)] * 0.06;
  }

  /// Fills [projectedX]/[projectedY] and the pre-projection surface buffers.
  void computeProjectedSurface({double outwardOffset = 0}) {
    final double edgeBoost = _insideEdgeBoost();
    for (int i = 0; i < pointCount; i += 1) {
      final double dx = restX[i] - _pointerX;
      final double dy = restY[i] - _pointerY;
      final double distance = math.sqrt(dx * dx + dy * dy);
      final double local =
          _gaussian(distance, _config.insidePointInfluenceWidth) * edgeBoost;
      final double haloBase = _gaussian(
        distance,
        _config.insidePointHaloWidth,
      );
      final double halo = math.max(haloBase - local * 0.34, 0);
      _totalDisplacement[i] = _smooth(displacement, i) +
          _insideCurveHold *
              (_config.insideHeldBulgeAmount * local -
                  _config.insideHeldHaloAmount * halo);
      _totalDepth[i] = _smooth(depth, i) -
          _insideCurveHold * _config.insideHeldDepthAmount * local;
    }

    final double halfWidth = math.max(_width / 2, 0.0001);
    final double halfHeight = math.max(_height / 2, 0.0001);
    for (int i = 0; i < pointCount; i += 1) {
      final double smoothedDisplacement = _smooth(_totalDisplacement, i);
      final double smoothedDepth = _smooth(_totalDepth, i);
      final double previous = _smooth(
        _totalDisplacement,
        _wrap(i - 1, pointCount),
      );
      final double next = _smooth(
        _totalDisplacement,
        _wrap(i + 1, pointCount),
      );
      final double tangentSlide = (next - previous) * 0.05;
      final double tangentX = -normalY[i];
      final double tangentY = normalX[i];
      final double leanBias = leanAmount == 0
          ? 0
          : lean * _clamp(restX[i] / halfWidth, -1, 1) * leanAmount;
      final double radial = smoothedDisplacement + outwardOffset + leanBias;
      final double x = restX[i] + normalX[i] * radial + tangentX * tangentSlide;
      final double y = restY[i] + normalY[i] * radial + tangentY * tangentSlide;
      final double xNorm = _clamp(x / halfWidth, -1, 1);
      final double yNorm = _clamp(y / halfHeight, -1, 1);
      final double planeDepth =
          -(xNorm * _tiltY + yNorm * _tiltX) * _config.axisDepth;
      final double z = planeDepth + smoothedDepth;
      final double denominator = _config.perspective - z;
      final double perspective =
          denominator.abs() < 0.001 ? 1 : _config.perspective / denominator;

      surfaceX[i] = x;
      surfaceY[i] = y;
      surfaceZ[i] = z;
      projectedX[i] = x * perspective;
      projectedY[i] = y * perspective;
    }
  }

  double _surfaceArea() {
    double area = 0;
    for (int i = 0; i < pointCount; i += 1) {
      final int next = _wrap(i + 1, pointCount);
      area += surfaceX[i] * surfaceY[next] - surfaceX[next] * surfaceY[i];
    }
    return area.abs() * 0.5;
  }

  double _updateTargets(double x, double y, double influence) {
    _pointerX = x;
    _pointerY = y;
    final double insideWeight =
        (1 - _smoothstep(-2, 5, signedDistance(x, y))) * influence;
    _pointerInsideWeight = insideWeight;
    _targetClickDepth = insideWeight;
    _targetInsidePress = insideWeight;
    _targetPress = insideWeight * _config.holdPressAmount;
    _targetInsideCurveHold = insideWeight;
    return insideWeight;
  }

  void pressAt(double x, double y,
      {double strength = 1, double influence = 1}) {
    _pointerActive = true;
    final double insideWeight = _updateTargets(x, y, influence);
    final double force = strength * 1.15 * influence;
    if (insideWeight > 0.01) {
      _addInsideImpulse(
        _config.insideLocalBulgeImpulse * insideWeight * force,
      );
      _pressVelocity += 1.9 * insideWeight * force;
    }
  }

  void moveTo(double x, double y, {double influence = 1}) {
    _updateTargets(x, y, influence);
  }

  void centerPulse({double strength = 1}) {
    pressAt(0, 0, strength: strength);
  }

  void centerPop({double strength = 1}) {
    _pointerX = 0;
    _pointerY = 0;
    _addInsideImpulse(
      _config.insideLocalBulgeImpulse * 0.5 * strength,
    );
    _pressVelocity += 0.9 * strength;
  }

  void pulseAt(double x, double y, {double strength = 1}) {
    _pointerX = x;
    _pointerY = y;
    _addMembraneImpulse(
      nearestIndex(x, y),
      _config.insideLocalBulgeImpulse * 0.5 * strength,
      12.8,
    );
  }

  void stretchAlong(double x, double y, {double strength = 1}) {
    final double length = math.sqrt(x * x + y * y);
    final double denominator = length == 0 ? 1 : length;
    final double directionX = x / denominator;
    final double directionY = y / denominator;
    final double amount = _config.insideLocalBulgeImpulse * 0.42 * strength;
    for (int i = 0; i < pointCount; i += 1) {
      final double alignment =
          normalX[i] * directionX + normalY[i] * directionY;
      velocity[i] += amount * alignment;
    }
  }

  void release() {
    _pointerActive = false;
    _targetClickDepth = 0;
    _targetInsidePress = 0;
    _targetPress = 0;
    _targetInsideCurveHold = 0;
    _targetTiltX = 0;
    _targetTiltY = 0;
    _pointerInsideWeight = 0;
    _pressVelocity -= 0.55;
  }

  void update(double elapsedSeconds) {
    if (!elapsedSeconds.isFinite || elapsedSeconds <= 0) {
      return;
    }
    final double delta = math.min(
      elapsedSeconds,
      _config.maximumFrameSeconds,
    );
    final int steps = math.max(
      1,
      (delta / _config.maximumStepSeconds).ceil(),
    );
    final double step = delta / steps;
    for (int i = 0; i < steps; i += 1) {
      _updateGlobal(step);
      _updateMembrane(step);
    }
    _recoverIfUnstable();
  }

  void _springClickDepth(
      double target, double stiffness, double damping, double dt) {
    final double acceleration =
        (target - _clickDepth) * stiffness - _clickDepthVelocity * damping;
    _clickDepthVelocity += acceleration * dt;
    _clickDepth += _clickDepthVelocity * dt;
  }

  void _updateGlobal(double dt) {
    _springClickDepth(
      _targetClickDepth,
      _config.clickDepthSpring,
      _config.clickDepthDamping,
      dt,
    );

    double acceleration =
        (_targetInsidePress - _insidePress) * _config.insidePressSpring -
            _insidePressVelocity * _config.insidePressDamping;
    _insidePressVelocity += acceleration * dt;
    _insidePress += _insidePressVelocity * dt;

    acceleration = (_targetPress - _press) * _config.pressSpring -
        _pressVelocity * _config.pressDamping;
    _pressVelocity += acceleration * dt;
    _press += _pressVelocity * dt;

    acceleration =
        (_targetInsideCurveHold - _insideCurveHold) * _config.heldCurveSpring -
            _insideCurveHoldVelocity * _config.heldCurveDamping;
    _insideCurveHoldVelocity += acceleration * dt;
    _insideCurveHold += _insideCurveHoldVelocity * dt;

    acceleration = -_rotation * _config.rotationSpring -
        _rotationVelocity * _config.rotationDamping;
    _rotationVelocity += acceleration * dt;
    _rotation += _rotationVelocity * dt;

    acceleration = (_targetTiltX - _tiltX) * _config.axisSpring -
        _tiltXVelocity * _config.axisDamping;
    _tiltXVelocity += acceleration * dt;
    _tiltX += _tiltXVelocity * dt;

    acceleration = (_targetTiltY - _tiltY) * _config.axisSpring -
        _tiltYVelocity * _config.axisDamping;
    _tiltYVelocity += acceleration * dt;
    _tiltY += _tiltYVelocity * dt;

    _clickDepth = _clamp(_clickDepth, 0, 1);
    _insidePress = _clamp(_insidePress, 0, 1);
    _press = _clamp(_press, -0.025, 0.085);
    _insideCurveHold = _clamp(_insideCurveHold, 0, 1);
    _rotation = _clamp(_rotation, -0.018, 0.018);
    _tiltX = _clamp(_tiltX, -1, 1);
    _tiltY = _clamp(_tiltY, -1, 1);
  }

  void _updateMembrane(double dt) {
    computeProjectedSurface();
    final double area = _surfaceArea();
    final double areaError = _baseArea == 0
        ? 0
        : _clamp((_baseArea - area) / _baseArea, -0.08, 0.08);

    for (int i = 0; i < pointCount; i += 1) {
      final int previous = _wrap(i - 1, pointCount);
      final int next = _wrap(i + 1, pointCount);
      final double membraneLap =
          displacement[previous] + displacement[next] - 2 * displacement[i];
      final double depthLap = depth[previous] + depth[next] - 2 * depth[i];
      _membraneAcceleration[i] = -displacement[i] * _config.membraneSpring +
          membraneLap * _config.waveCoupling -
          velocity[i] * _config.membraneDamping +
          areaError * _config.pressure;
      _depthAcceleration[i] = -depth[i] * _config.depthSpring +
          depthLap * _config.depthCoupling -
          depthVelocity[i] * _config.depthDamping;
    }

    if (_pointerActive && _pointerInsideWeight > 0.02) {
      final double edgeBoost = _insideEdgeBoost();
      for (int i = 0; i < pointCount; i += 1) {
        final double dx = restX[i] - _pointerX;
        final double dy = restY[i] - _pointerY;
        final double distance = math.sqrt(dx * dx + dy * dy);
        final double local =
            _gaussian(distance, _config.insidePointInfluenceWidth) * edgeBoost;
        final double haloBase = _gaussian(
          distance,
          _config.insidePointHaloWidth,
        );
        final double halo = math.max(haloBase - local * 0.34, 0);
        _membraneAcceleration[i] += _config.insideLocalHoldBulgeForce *
            (local - halo * 0.18) *
            _pointerInsideWeight;
      }
    }

    double average = 0;
    for (int i = 0; i < pointCount; i += 1) {
      velocity[i] += _membraneAcceleration[i] * dt;
      displacement[i] += velocity[i] * dt;
      depthVelocity[i] += _depthAcceleration[i] * dt;
      depth[i] += depthVelocity[i] * dt;
      displacement[i] = _clamp(
        displacement[i],
        -_config.maximumDent,
        _config.maximumBulge,
      );
      velocity[i] = _clamp(velocity[i], -410, 410);
      depth[i] = _clamp(
        depth[i],
        _config.maximumDepthIn,
        _config.maximumDepthOut,
      );
      depthVelocity[i] = _clamp(depthVelocity[i], -600, 600);
      average += displacement[i];
    }
    average /= pointCount;
    for (int i = 0; i < pointCount; i += 1) {
      displacement[i] -= average * _config.volumeCorrection;
    }
  }

  void _recoverIfUnstable() {
    bool healthy = _press.isFinite &&
        _clickDepth.isFinite &&
        _rotation.isFinite &&
        _insideCurveHold.isFinite;
    if (healthy) {
      for (int i = 0; i < pointCount; i += 1) {
        if (!displacement[i].isFinite ||
            !velocity[i].isFinite ||
            !depth[i].isFinite ||
            !depthVelocity[i].isFinite) {
          healthy = false;
          break;
        }
      }
    }
    if (!healthy) {
      resetMotion();
    }
  }

  bool get isResting {
    if (_pointerActive) {
      return false;
    }
    if (_clickDepth.abs() > 1e-3 ||
        _insidePress.abs() > 1e-3 ||
        _insideCurveHold.abs() > 1e-3 ||
        _rotation.abs() > 1e-4 ||
        _tiltX.abs() > 1e-3 ||
        _tiltY.abs() > 1e-3) {
      return false;
    }
    for (int i = 0; i < pointCount; i += 1) {
      if (displacement[i].abs() > 0.03 ||
          velocity[i].abs() > 0.05 ||
          depth[i].abs() > 0.03 ||
          depthVelocity[i].abs() > 0.05) {
        return false;
      }
    }
    return true;
  }

  void resetMotion() {
    displacement.fillRange(0, pointCount, 0);
    velocity.fillRange(0, pointCount, 0);
    depth.fillRange(0, pointCount, 0);
    depthVelocity.fillRange(0, pointCount, 0);
    _clickDepth = 0;
    _clickDepthVelocity = 0;
    _targetClickDepth = 0;
    _insidePress = 0;
    _insidePressVelocity = 0;
    _targetInsidePress = 0;
    _press = 0;
    _pressVelocity = 0;
    _targetPress = 0;
    _insideCurveHold = 0;
    _insideCurveHoldVelocity = 0;
    _targetInsideCurveHold = 0;
    _rotation = 0;
    _rotationVelocity = 0;
    _tiltX = 0;
    _tiltXVelocity = 0;
    _tiltY = 0;
    _tiltYVelocity = 0;
    _targetTiltX = 0;
    _targetTiltY = 0;
    _pointerActive = false;
    _pointerInsideWeight = 0;
  }
}
