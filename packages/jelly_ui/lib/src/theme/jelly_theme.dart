import 'package:flutter/material.dart';

import '../foundation/foundation.dart';
import 'morph.dart';
import 'tokens.dart';

/// The single theme extension consumed by every Jelly widget and morph.
@immutable
final class JellyThemeData extends ThemeExtension<JellyThemeData> {
  const JellyThemeData({
    required this.morphId,
    required this.standard,
    required this.highContrast,
    this.motion = const JellyMotionSettings.adaptive(),
    this.feedback = const JellyFeedbackSettings.platform(),
  });

  factory JellyThemeData.fromMorph({
    required JellyMorph morph,
    required Brightness brightness,
    JellyMotionSettings motion = const JellyMotionSettings.adaptive(),
    JellyFeedbackSettings feedback = const JellyFeedbackSettings.platform(),
  }) {
    morph.validate();
    return JellyThemeData(
      morphId: morph.id,
      standard: morph.themeFor(brightness),
      highContrast: morph.themeFor(brightness, highContrast: true),
      motion: motion,
      feedback: feedback,
    );
  }

  static final JellyThemeData fallback = JellyThemeData.fromMorph(
    morph: JellyMorphs.neutral,
    brightness: Brightness.light,
  );

  final String morphId;
  final JellyMorphTheme standard;
  final JellyMorphTheme highContrast;
  final JellyMotionSettings motion;
  final JellyFeedbackSettings feedback;

  JellyMorphTheme resolve({bool highContrast = false}) {
    return highContrast ? this.highContrast : standard;
  }

  JellyMorphTheme resolveFor(BuildContext context) {
    final MediaQueryData? media = MediaQuery.maybeOf(context);
    return resolve(highContrast: media?.highContrast ?? false);
  }

  bool reduceMotionFor(BuildContext context) {
    if (motion.mode == JellyMotionMode.none ||
        motion.mode == JellyMotionMode.reduced) {
      return true;
    }
    final MediaQueryData? media = MediaQuery.maybeOf(context);
    return (media?.disableAnimations ?? false) ||
        WidgetsBinding
            .instance.platformDispatcher.accessibilityFeatures.reduceMotion;
  }

  @override
  JellyThemeData copyWith({
    String? morphId,
    JellyMorphTheme? standard,
    JellyMorphTheme? highContrast,
    JellyMotionSettings? motion,
    JellyFeedbackSettings? feedback,
  }) {
    return JellyThemeData(
      morphId: morphId ?? this.morphId,
      standard: standard ?? this.standard,
      highContrast: highContrast ?? this.highContrast,
      motion: motion ?? this.motion,
      feedback: feedback ?? this.feedback,
    );
  }

  @override
  JellyThemeData lerp(covariant JellyThemeData? other, double t) {
    if (other == null) {
      return this;
    }
    return JellyThemeData(
      morphId: t < 0.5 ? morphId : other.morphId,
      standard: JellyMorphTheme.lerp(standard, other.standard, t),
      highContrast: JellyMorphTheme.lerp(
        highContrast,
        other.highContrast,
        t,
      ),
      motion: JellyMotionSettings.lerp(motion, other.motion, t),
      feedback: t < 0.5 ? feedback : other.feedback,
    );
  }
}

/// Installs Jelly into [ThemeData] and optionally scopes a local override.
class JellyTheme extends InheritedTheme {
  const JellyTheme({
    required this.data,
    required super.child,
    super.key,
  });

  final JellyThemeData data;

  static ThemeData material({
    required ThemeData base,
    JellyMorph? morph,
    JellyMotionSettings motion = const JellyMotionSettings.adaptive(),
    JellyFeedbackSettings feedback = const JellyFeedbackSettings.platform(),
  }) {
    final JellyThemeData data = JellyThemeData.fromMorph(
      morph: morph ?? JellyMorphs.neutral,
      brightness: base.brightness,
      motion: motion,
      feedback: feedback,
    );
    final Iterable<ThemeExtension<dynamic>> retained = base.extensions.values
        .where((ThemeExtension<dynamic> item) => item is! JellyThemeData);
    return base.copyWith(
      extensions: retained.followedBy(<JellyThemeData>[data]),
    );
  }

  static JellyThemeData of(BuildContext context) {
    final JellyTheme? scoped =
        context.dependOnInheritedWidgetOfExactType<JellyTheme>();
    return scoped?.data ??
        Theme.of(context).extension<JellyThemeData>() ??
        JellyThemeData.fallback;
  }

  static JellyThemeData? maybeOf(BuildContext context) {
    final JellyTheme? scoped =
        context.dependOnInheritedWidgetOfExactType<JellyTheme>();
    return scoped?.data ?? Theme.of(context).extension<JellyThemeData>();
  }

  @override
  bool updateShouldNotify(JellyTheme oldWidget) => data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return JellyTheme(data: data, child: child);
  }
}
