import 'package:flutter/foundation.dart';

/// Semantic emphasis shared by Jelly controls.
enum JellySemanticTone { neutral, primary, info, success, warning, danger }

/// Consistent component sizing without exposing arbitrary per-widget geometry.
enum JellyControlSize { compact, standard, large }

/// Stable surface roles that a morph must style.
enum JellySurfaceRole {
  action,
  quietAction,
  container,
  field,
  choiceIndicator,
  movableThumb,
  selectionTrack,
  overlay,
  status,
  progress,
}

/// Platform motion preference handling.
enum JellyMotionMode { adaptive, reduced, none }

/// Internal simulation detail exposed only as meaningful quality tiers.
enum JellyMotionQuality { compact, standard, hero }

/// Whether Jelly emits optional platform feedback.
enum JellyFeedbackMode { platform, off }

/// Motion policy is deliberately separate from a visual morph.
@immutable
final class JellyMotionSettings {
  const JellyMotionSettings({
    this.mode = JellyMotionMode.adaptive,
    this.intensity = 1,
    this.quality = JellyMotionQuality.standard,
  }) : assert(intensity >= 0 && intensity <= 1);

  const JellyMotionSettings.adaptive({
    this.intensity = 1,
    this.quality = JellyMotionQuality.standard,
  })  : mode = JellyMotionMode.adaptive,
        assert(intensity >= 0 && intensity <= 1);

  const JellyMotionSettings.reduced({
    this.intensity = 1,
    this.quality = JellyMotionQuality.standard,
  })  : mode = JellyMotionMode.reduced,
        assert(intensity >= 0 && intensity <= 1);

  const JellyMotionSettings.none()
      : mode = JellyMotionMode.none,
        intensity = 0,
        quality = JellyMotionQuality.compact;

  final JellyMotionMode mode;
  final double intensity;
  final JellyMotionQuality quality;

  JellyMotionSettings copyWith({
    JellyMotionMode? mode,
    double? intensity,
    JellyMotionQuality? quality,
  }) {
    return JellyMotionSettings(
      mode: mode ?? this.mode,
      intensity: intensity ?? this.intensity,
      quality: quality ?? this.quality,
    );
  }

  static JellyMotionSettings lerp(
    JellyMotionSettings a,
    JellyMotionSettings b,
    double t,
  ) {
    return JellyMotionSettings(
      mode: t < 0.5 ? a.mode : b.mode,
      intensity: a.intensity + (b.intensity - a.intensity) * t,
      quality: t < 0.5 ? a.quality : b.quality,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is JellyMotionSettings &&
        other.mode == mode &&
        other.intensity == intensity &&
        other.quality == quality;
  }

  @override
  int get hashCode => Object.hash(mode, intensity, quality);
}

/// Optional haptic and sound policy. Visual state never depends on feedback.
@immutable
final class JellyFeedbackSettings {
  const JellyFeedbackSettings({this.mode = JellyFeedbackMode.platform});

  const JellyFeedbackSettings.off() : mode = JellyFeedbackMode.off;

  const JellyFeedbackSettings.platform() : mode = JellyFeedbackMode.platform;

  final JellyFeedbackMode mode;

  @override
  bool operator ==(Object other) {
    return other is JellyFeedbackSettings && other.mode == mode;
  }

  @override
  int get hashCode => mode.hashCode;
}
