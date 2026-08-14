import 'package:flutter/foundation.dart';

/// Internal tuning for the membrane. Public callers choose a quality tier.
@immutable
final class JellyPhysicsConfig {
  const JellyPhysicsConfig({
    this.samples = 144,
    this.clickDepthSpring = 115,
    this.clickDepthDamping = 18,
    this.insidePressSpring = 92,
    this.insidePressDamping = 15,
    this.insideLocalBulgeImpulse = 390,
    this.insideLocalHoldBulgeForce = 48,
    this.pressSpring = 76,
    this.pressDamping = 13,
    this.holdPressAmount = 0,
    this.heldCurveSpring = 135,
    this.heldCurveDamping = 22,
    this.insideHeldBulgeAmount = 10.8,
    this.insideHeldHaloAmount = 2.65,
    this.insideHeldDepthAmount = 0,
    this.insidePointInfluenceWidth = 38,
    this.insidePointHaloWidth = 70,
    this.insidePointEdgeBoost = 0.44,
    this.normalBlendPasses = 3,
    this.curveTension = 0.68,
    this.axisDepth = 34,
    this.axisSpring = 48,
    this.axisDamping = 11,
    this.depthSpring = 76,
    this.depthDamping = 14,
    this.depthCoupling = 150,
    this.maximumDepthIn = -26,
    this.maximumDepthOut = 16,
    this.rotationSpring = 42,
    this.rotationDamping = 12,
    this.membraneSpring = 96,
    this.membraneDamping = 17,
    this.waveCoupling = 145,
    this.pressure = 620,
    this.volumeCorrection = 0.1,
    this.maximumDent = 8,
    this.maximumBulge = 24,
    this.perspective = 390,
    this.maximumStepSeconds = 1 / 58,
    this.maximumFrameSeconds = 1 / 30,
  }) : assert(samples >= 32);

  factory JellyPhysicsConfig.forSamples(int samples) {
    return JellyPhysicsConfig(samples: samples);
  }

  final int samples;
  final double clickDepthSpring;
  final double clickDepthDamping;
  final double insidePressSpring;
  final double insidePressDamping;
  final double insideLocalBulgeImpulse;
  final double insideLocalHoldBulgeForce;
  final double pressSpring;
  final double pressDamping;
  final double holdPressAmount;
  final double heldCurveSpring;
  final double heldCurveDamping;
  final double insideHeldBulgeAmount;
  final double insideHeldHaloAmount;
  final double insideHeldDepthAmount;
  final double insidePointInfluenceWidth;
  final double insidePointHaloWidth;
  final double insidePointEdgeBoost;
  final int normalBlendPasses;
  final double curveTension;
  final double axisDepth;
  final double axisSpring;
  final double axisDamping;
  final double depthSpring;
  final double depthDamping;
  final double depthCoupling;
  final double maximumDepthIn;
  final double maximumDepthOut;
  final double rotationSpring;
  final double rotationDamping;
  final double membraneSpring;
  final double membraneDamping;
  final double waveCoupling;
  final double pressure;
  final double volumeCorrection;
  final double maximumDent;
  final double maximumBulge;
  final double perspective;
  final double maximumStepSeconds;
  final double maximumFrameSeconds;
}
