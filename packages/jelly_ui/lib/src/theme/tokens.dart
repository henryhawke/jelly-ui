import 'package:flutter/material.dart';

import '../foundation/foundation.dart';

double _lerpDouble(double a, double b, double t) => a + (b - a) * t;

/// Semantic colors used by Jelly widgets and morph recipes.
@immutable
final class JellyPalette {
  const JellyPalette({
    required this.canvas,
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceInset,
    required this.textStrong,
    required this.textMuted,
    required this.border,
    required this.focus,
    required this.focusOnDark,
    required this.shadow,
    required this.primary,
    required this.primaryForeground,
    required this.info,
    required this.infoForeground,
    required this.success,
    required this.successForeground,
    required this.warning,
    required this.warningForeground,
    required this.danger,
    required this.dangerForeground,
    required this.disabledSurface,
    required this.disabledForeground,
  });

  final Color canvas;
  final Color surface;
  final Color surfaceRaised;
  final Color surfaceInset;
  final Color textStrong;
  final Color textMuted;
  final Color border;
  final Color focus;
  final Color focusOnDark;
  final Color shadow;
  final Color primary;
  final Color primaryForeground;
  final Color info;
  final Color infoForeground;
  final Color success;
  final Color successForeground;
  final Color warning;
  final Color warningForeground;
  final Color danger;
  final Color dangerForeground;
  final Color disabledSurface;
  final Color disabledForeground;

  Color tone(JellySemanticTone tone) {
    return switch (tone) {
      JellySemanticTone.neutral => surface,
      JellySemanticTone.primary => primary,
      JellySemanticTone.info => info,
      JellySemanticTone.success => success,
      JellySemanticTone.warning => warning,
      JellySemanticTone.danger => danger,
    };
  }

  Color foregroundFor(JellySemanticTone tone) {
    return switch (tone) {
      JellySemanticTone.neutral => textStrong,
      JellySemanticTone.primary => primaryForeground,
      JellySemanticTone.info => infoForeground,
      JellySemanticTone.success => successForeground,
      JellySemanticTone.warning => warningForeground,
      JellySemanticTone.danger => dangerForeground,
    };
  }

  static JellyPalette lerp(JellyPalette a, JellyPalette b, double t) {
    return JellyPalette(
      canvas: Color.lerp(a.canvas, b.canvas, t)!,
      surface: Color.lerp(a.surface, b.surface, t)!,
      surfaceRaised: Color.lerp(a.surfaceRaised, b.surfaceRaised, t)!,
      surfaceInset: Color.lerp(a.surfaceInset, b.surfaceInset, t)!,
      textStrong: Color.lerp(a.textStrong, b.textStrong, t)!,
      textMuted: Color.lerp(a.textMuted, b.textMuted, t)!,
      border: Color.lerp(a.border, b.border, t)!,
      focus: Color.lerp(a.focus, b.focus, t)!,
      focusOnDark: Color.lerp(a.focusOnDark, b.focusOnDark, t)!,
      shadow: Color.lerp(a.shadow, b.shadow, t)!,
      primary: Color.lerp(a.primary, b.primary, t)!,
      primaryForeground:
          Color.lerp(a.primaryForeground, b.primaryForeground, t)!,
      info: Color.lerp(a.info, b.info, t)!,
      infoForeground: Color.lerp(a.infoForeground, b.infoForeground, t)!,
      success: Color.lerp(a.success, b.success, t)!,
      successForeground:
          Color.lerp(a.successForeground, b.successForeground, t)!,
      warning: Color.lerp(a.warning, b.warning, t)!,
      warningForeground:
          Color.lerp(a.warningForeground, b.warningForeground, t)!,
      danger: Color.lerp(a.danger, b.danger, t)!,
      dangerForeground: Color.lerp(a.dangerForeground, b.dangerForeground, t)!,
      disabledSurface: Color.lerp(
        a.disabledSurface,
        b.disabledSurface,
        t,
      )!,
      disabledForeground: Color.lerp(
        a.disabledForeground,
        b.disabledForeground,
        t,
      )!,
    );
  }
}

/// Typography roles resolved once when a morph is installed.
@immutable
final class JellyTypography {
  const JellyTypography({
    required this.display,
    required this.title,
    required this.body,
    required this.label,
    required this.instrumentLabel,
    required this.numeral,
  });

  final TextStyle display;
  final TextStyle title;
  final TextStyle body;
  final TextStyle label;
  final TextStyle instrumentLabel;
  final TextStyle numeral;

  static JellyTypography lerp(
    JellyTypography a,
    JellyTypography b,
    double t,
  ) {
    return JellyTypography(
      display: TextStyle.lerp(a.display, b.display, t)!,
      title: TextStyle.lerp(a.title, b.title, t)!,
      body: TextStyle.lerp(a.body, b.body, t)!,
      label: TextStyle.lerp(a.label, b.label, t)!,
      instrumentLabel: TextStyle.lerp(
        a.instrumentLabel,
        b.instrumentLabel,
        t,
      )!,
      numeral: TextStyle.lerp(a.numeral, b.numeral, t)!,
    );
  }
}

/// Fixed spacing scale. Components consume roles rather than literal gaps.
@immutable
final class JellySpacing {
  const JellySpacing({
    this.xxs = 2,
    this.xs = 4,
    this.sm = 8,
    this.md = 12,
    this.lg = 16,
    this.xl = 24,
    this.xxl = 32,
  });

  final double xxs;
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;

  Iterable<double> get values => <double>[xxs, xs, sm, md, lg, xl, xxl];

  static JellySpacing lerp(JellySpacing a, JellySpacing b, double t) {
    return JellySpacing(
      xxs: _lerpDouble(a.xxs, b.xxs, t),
      xs: _lerpDouble(a.xs, b.xs, t),
      sm: _lerpDouble(a.sm, b.sm, t),
      md: _lerpDouble(a.md, b.md, t),
      lg: _lerpDouble(a.lg, b.lg, t),
      xl: _lerpDouble(a.xl, b.xl, t),
      xxl: _lerpDouble(a.xxl, b.xxl, t),
    );
  }
}

/// Geometry shared across a morph's controls.
@immutable
final class JellyGeometry {
  const JellyGeometry({
    required this.spacing,
    this.compactControlHeight = 40,
    this.controlHeight = 48,
    this.largeControlHeight = 56,
    this.minimumTouchTarget = 48,
    this.radiusSmall = 12,
    this.radiusMedium = 16,
    this.radiusLarge = 24,
    this.borderThin = 1.5,
    this.borderStandard = 2,
    this.focusWidth = 3,
    this.focusGap = 3,
  });

  final JellySpacing spacing;
  final double compactControlHeight;
  final double controlHeight;
  final double largeControlHeight;
  final double minimumTouchTarget;
  final double radiusSmall;
  final double radiusMedium;
  final double radiusLarge;
  final double borderThin;
  final double borderStandard;
  final double focusWidth;
  final double focusGap;

  Iterable<double> get scalarValues => <double>[
        compactControlHeight,
        controlHeight,
        largeControlHeight,
        minimumTouchTarget,
        radiusSmall,
        radiusMedium,
        radiusLarge,
        borderThin,
        borderStandard,
        focusWidth,
        focusGap,
        ...spacing.values,
      ];

  double heightFor(JellyControlSize size) {
    return switch (size) {
      JellyControlSize.compact => compactControlHeight,
      JellyControlSize.standard => controlHeight,
      JellyControlSize.large => largeControlHeight,
    };
  }

  static JellyGeometry lerp(JellyGeometry a, JellyGeometry b, double t) {
    return JellyGeometry(
      spacing: JellySpacing.lerp(a.spacing, b.spacing, t),
      compactControlHeight: _lerpDouble(
        a.compactControlHeight,
        b.compactControlHeight,
        t,
      ),
      controlHeight: _lerpDouble(a.controlHeight, b.controlHeight, t),
      largeControlHeight: _lerpDouble(
        a.largeControlHeight,
        b.largeControlHeight,
        t,
      ),
      minimumTouchTarget: _lerpDouble(
        a.minimumTouchTarget,
        b.minimumTouchTarget,
        t,
      ),
      radiusSmall: _lerpDouble(a.radiusSmall, b.radiusSmall, t),
      radiusMedium: _lerpDouble(a.radiusMedium, b.radiusMedium, t),
      radiusLarge: _lerpDouble(a.radiusLarge, b.radiusLarge, t),
      borderThin: _lerpDouble(a.borderThin, b.borderThin, t),
      borderStandard: _lerpDouble(
        a.borderStandard,
        b.borderStandard,
        t,
      ),
      focusWidth: _lerpDouble(a.focusWidth, b.focusWidth, t),
      focusGap: _lerpDouble(a.focusGap, b.focusGap, t),
    );
  }
}

/// Non-physics transition durations and curves.
@immutable
final class JellyTransitionTokens {
  const JellyTransitionTokens({
    this.immediate = Duration.zero,
    this.fast = const Duration(milliseconds: 100),
    this.standard = const Duration(milliseconds: 180),
    this.slow = const Duration(milliseconds: 300),
    this.pressCurve = Curves.easeOut,
    this.settleCurve = Curves.easeOutCubic,
  });

  final Duration immediate;
  final Duration fast;
  final Duration standard;
  final Duration slow;
  final Curve pressCurve;
  final Curve settleCurve;

  static JellyTransitionTokens lerp(
    JellyTransitionTokens a,
    JellyTransitionTokens b,
    double t,
  ) {
    Duration duration(Duration x, Duration y) {
      return Duration(
        microseconds: _lerpDouble(
          x.inMicroseconds.toDouble(),
          y.inMicroseconds.toDouble(),
          t,
        ).round(),
      );
    }

    return JellyTransitionTokens(
      immediate: duration(a.immediate, b.immediate),
      fast: duration(a.fast, b.fast),
      standard: duration(a.standard, b.standard),
      slow: duration(a.slow, b.slow),
      pressCurve: t < 0.5 ? a.pressCurve : b.pressCurve,
      settleCurve: t < 0.5 ? a.settleCurve : b.settleCurve,
    );
  }
}

/// Paint-ready outcome for a single surface state.
@immutable
final class JellySurfaceStyle {
  const JellySurfaceStyle({
    required this.fill,
    required this.foreground,
    required this.border,
    required this.shadow,
    required this.focus,
    this.borderWidth = 2,
    this.radius = 16,
    this.shadowOffset = Offset.zero,
    this.contentOffset = Offset.zero,
  });

  final Color fill;
  final Color foreground;
  final Color border;
  final Color shadow;
  final Color focus;
  final double borderWidth;
  final double radius;
  final Offset shadowOffset;
  final Offset contentOffset;

  JellySurfaceStyle copyWith({
    Color? fill,
    Color? foreground,
    Color? border,
    Color? shadow,
    Color? focus,
    double? borderWidth,
    double? radius,
    Offset? shadowOffset,
    Offset? contentOffset,
  }) {
    return JellySurfaceStyle(
      fill: fill ?? this.fill,
      foreground: foreground ?? this.foreground,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
      focus: focus ?? this.focus,
      borderWidth: borderWidth ?? this.borderWidth,
      radius: radius ?? this.radius,
      shadowOffset: shadowOffset ?? this.shadowOffset,
      contentOffset: contentOffset ?? this.contentOffset,
    );
  }

  static JellySurfaceStyle lerp(
    JellySurfaceStyle a,
    JellySurfaceStyle b,
    double t,
  ) {
    return JellySurfaceStyle(
      fill: Color.lerp(a.fill, b.fill, t)!,
      foreground: Color.lerp(a.foreground, b.foreground, t)!,
      border: Color.lerp(a.border, b.border, t)!,
      shadow: Color.lerp(a.shadow, b.shadow, t)!,
      focus: Color.lerp(a.focus, b.focus, t)!,
      borderWidth: _lerpDouble(a.borderWidth, b.borderWidth, t),
      radius: _lerpDouble(a.radius, b.radius, t),
      shadowOffset: Offset.lerp(a.shadowOffset, b.shadowOffset, t)!,
      contentOffset: Offset.lerp(a.contentOffset, b.contentOffset, t)!,
    );
  }
}

/// Complete visual state table for one semantic surface role.
@immutable
final class JellySurfaceRecipe {
  const JellySurfaceRecipe({
    required this.normal,
    required this.hovered,
    required this.pressed,
    required this.focused,
    required this.selected,
    required this.disabled,
    required this.error,
  });

  final JellySurfaceStyle normal;
  final JellySurfaceStyle hovered;
  final JellySurfaceStyle pressed;
  final JellySurfaceStyle focused;
  final JellySurfaceStyle selected;
  final JellySurfaceStyle disabled;
  final JellySurfaceStyle error;

  JellySurfaceStyle resolve(Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return disabled;
    }
    if (states.contains(WidgetState.error)) {
      return error;
    }
    if (states.contains(WidgetState.pressed)) {
      return pressed;
    }
    if (states.contains(WidgetState.selected)) {
      return selected;
    }
    if (states.contains(WidgetState.focused)) {
      return focused;
    }
    if (states.contains(WidgetState.hovered)) {
      return hovered;
    }
    return normal;
  }

  Iterable<JellySurfaceStyle> get styles => <JellySurfaceStyle>[
        normal,
        hovered,
        pressed,
        focused,
        selected,
        disabled,
        error,
      ];

  static JellySurfaceRecipe lerp(
    JellySurfaceRecipe a,
    JellySurfaceRecipe b,
    double t,
  ) {
    return JellySurfaceRecipe(
      normal: JellySurfaceStyle.lerp(a.normal, b.normal, t),
      hovered: JellySurfaceStyle.lerp(a.hovered, b.hovered, t),
      pressed: JellySurfaceStyle.lerp(a.pressed, b.pressed, t),
      focused: JellySurfaceStyle.lerp(a.focused, b.focused, t),
      selected: JellySurfaceStyle.lerp(a.selected, b.selected, t),
      disabled: JellySurfaceStyle.lerp(a.disabled, b.disabled, t),
      error: JellySurfaceStyle.lerp(a.error, b.error, t),
    );
  }
}

/// Exhaustive, immutable recipes for every public surface role.
@immutable
final class JellySurfaceRecipes {
  const JellySurfaceRecipes({
    required this.action,
    required this.quietAction,
    required this.container,
    required this.field,
    required this.choiceIndicator,
    required this.movableThumb,
    required this.selectionTrack,
    required this.overlay,
    required this.status,
    required this.progress,
  });

  final JellySurfaceRecipe action;
  final JellySurfaceRecipe quietAction;
  final JellySurfaceRecipe container;
  final JellySurfaceRecipe field;
  final JellySurfaceRecipe choiceIndicator;
  final JellySurfaceRecipe movableThumb;
  final JellySurfaceRecipe selectionTrack;
  final JellySurfaceRecipe overlay;
  final JellySurfaceRecipe status;
  final JellySurfaceRecipe progress;

  JellySurfaceRecipe operator [](JellySurfaceRole role) {
    return switch (role) {
      JellySurfaceRole.action => action,
      JellySurfaceRole.quietAction => quietAction,
      JellySurfaceRole.container => container,
      JellySurfaceRole.field => field,
      JellySurfaceRole.choiceIndicator => choiceIndicator,
      JellySurfaceRole.movableThumb => movableThumb,
      JellySurfaceRole.selectionTrack => selectionTrack,
      JellySurfaceRole.overlay => overlay,
      JellySurfaceRole.status => status,
      JellySurfaceRole.progress => progress,
    };
  }

  Iterable<JellySurfaceRecipe> get values => <JellySurfaceRecipe>[
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
      ];

  static JellySurfaceRecipes lerp(
    JellySurfaceRecipes a,
    JellySurfaceRecipes b,
    double t,
  ) {
    return JellySurfaceRecipes(
      action: JellySurfaceRecipe.lerp(a.action, b.action, t),
      quietAction: JellySurfaceRecipe.lerp(a.quietAction, b.quietAction, t),
      container: JellySurfaceRecipe.lerp(a.container, b.container, t),
      field: JellySurfaceRecipe.lerp(a.field, b.field, t),
      choiceIndicator: JellySurfaceRecipe.lerp(
        a.choiceIndicator,
        b.choiceIndicator,
        t,
      ),
      movableThumb: JellySurfaceRecipe.lerp(
        a.movableThumb,
        b.movableThumb,
        t,
      ),
      selectionTrack: JellySurfaceRecipe.lerp(
        a.selectionTrack,
        b.selectionTrack,
        t,
      ),
      overlay: JellySurfaceRecipe.lerp(a.overlay, b.overlay, t),
      status: JellySurfaceRecipe.lerp(a.status, b.status, t),
      progress: JellySurfaceRecipe.lerp(a.progress, b.progress, t),
    );
  }
}

/// Complete visual instruction set for one brightness/contrast environment.
@immutable
final class JellyMorphTheme {
  const JellyMorphTheme({
    required this.palette,
    required this.typography,
    required this.geometry,
    required this.transitions,
    required this.surfaces,
  });

  final JellyPalette palette;
  final JellyTypography typography;
  final JellyGeometry geometry;
  final JellyTransitionTokens transitions;
  final JellySurfaceRecipes surfaces;

  void validate() {
    final Iterable<double> geometryValues = geometry.scalarValues;
    if (geometryValues.any((double value) => !value.isFinite || value < 0)) {
      throw const JellyMorphError(
        'Geometry values must be finite and non-negative.',
      );
    }
    for (final JellySurfaceRecipe recipe in surfaces.values) {
      for (final JellySurfaceStyle style in recipe.styles) {
        final Iterable<double> values = <double>[
          style.borderWidth,
          style.radius,
          style.shadowOffset.dx,
          style.shadowOffset.dy,
          style.contentOffset.dx,
          style.contentOffset.dy,
        ];
        if (values.any((double value) => !value.isFinite)) {
          throw const JellyMorphError(
            'Surface values must be finite.',
          );
        }
        if (style.borderWidth < 0 || style.radius < 0) {
          throw const JellyMorphError(
            'Surface border width and radius must be non-negative.',
          );
        }
      }
    }
  }

  static JellyMorphTheme lerp(
    JellyMorphTheme a,
    JellyMorphTheme b,
    double t,
  ) {
    return JellyMorphTheme(
      palette: JellyPalette.lerp(a.palette, b.palette, t),
      typography: JellyTypography.lerp(a.typography, b.typography, t),
      geometry: JellyGeometry.lerp(a.geometry, b.geometry, t),
      transitions: JellyTransitionTokens.lerp(
        a.transitions,
        b.transitions,
        t,
      ),
      surfaces: JellySurfaceRecipes.lerp(a.surfaces, b.surfaces, t),
    );
  }
}

/// Structured failure emitted before a morph reaches a painter.
final class JellyMorphError implements Exception {
  const JellyMorphError(this.message);

  final String message;

  @override
  String toString() => 'JellyMorphError: $message';
}
