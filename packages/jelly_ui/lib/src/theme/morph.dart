import 'package:flutter/material.dart';

import 'tokens.dart';

/// Immutable visual instructions supplied by a first- or third-party package.
@immutable
final class JellyMorph {
  const JellyMorph({
    required this.id,
    required this.standard,
    this.dark,
    this.highContrast,
    this.highContrastDark,
  });

  final String id;
  final JellyMorphTheme standard;
  final JellyMorphTheme? dark;
  final JellyMorphTheme? highContrast;
  final JellyMorphTheme? highContrastDark;

  JellyMorphTheme themeFor(
    Brightness brightness, {
    bool highContrast = false,
  }) {
    if (brightness == Brightness.dark) {
      if (highContrast) {
        return highContrastDark ?? dark ?? this.highContrast ?? standard;
      }
      return dark ?? standard;
    }
    if (highContrast) {
      return this.highContrast ?? standard;
    }
    return standard;
  }

  void validate() {
    if (id.trim().isEmpty) {
      throw const JellyMorphError('A morph id must not be empty.');
    }
    standard.validate();
    dark?.validate();
    highContrast?.validate();
    highContrastDark?.validate();
  }
}

/// Built-in morphs keep Jelly widgets useful before an app installs a theme.
abstract final class JellyMorphs {
  static final JellyMorph neutral = JellyMorph(
    id: 'jelly.neutral',
    standard: _neutralTheme(Brightness.light),
    dark: _neutralTheme(Brightness.dark),
    highContrast: _neutralTheme(Brightness.light, highContrast: true),
    highContrastDark: _neutralTheme(Brightness.dark, highContrast: true),
  );
}

JellyMorphTheme _neutralTheme(
  Brightness brightness, {
  bool highContrast = false,
}) {
  final bool dark = brightness == Brightness.dark;
  final JellyPalette palette = JellyPalette(
    canvas: dark ? const Color(0xFF10131A) : const Color(0xFFF5F7FB),
    surface: dark ? const Color(0xFF1A1F2B) : const Color(0xFFFFFFFF),
    surfaceRaised: dark ? const Color(0xFF222938) : const Color(0xFFFFFFFF),
    surfaceInset: dark ? const Color(0xFF121722) : const Color(0xFFE8ECF3),
    textStrong: dark ? const Color(0xFFF7F9FC) : const Color(0xFF172033),
    textMuted: dark ? const Color(0xFFB6C0D2) : const Color(0xFF5C667A),
    textOnAction: const Color(0xFFFFFFFF),
    border: dark ? const Color(0xFF8793A8) : const Color(0xFF34405A),
    focus: const Color(0xFF00A3FF),
    shadow: dark ? const Color(0xFF000000) : const Color(0x6634405A),
    primary: const Color(0xFF6558E8),
    info: const Color(0xFF1688E5),
    success: const Color(0xFF138A57),
    warning: const Color(0xFFF2B705),
    danger: const Color(0xFFD33F5A),
    disabledSurface: dark ? const Color(0xFF252B36) : const Color(0xFFE4E7ED),
    disabledForeground:
        dark ? const Color(0xFF8993A5) : const Color(0xFF727B8B),
  );
  final JellyGeometry geometry = JellyGeometry(
    spacing: const JellySpacing(),
    borderStandard: highContrast ? 3 : 2,
    focusWidth: highContrast ? 4 : 3,
  );
  final TextStyle baseText = TextStyle(
    color: palette.textStrong,
    fontFamily: 'sans-serif',
  );

  JellySurfaceRecipe recipe({
    required Color fill,
    required Color foreground,
    Offset shadowOffset = const Offset(0, 2),
    double? radius,
  }) {
    final JellySurfaceStyle normal = JellySurfaceStyle(
      fill: fill,
      foreground: foreground,
      border: palette.border,
      shadow: palette.shadow,
      focus: palette.focus,
      borderWidth: geometry.borderStandard,
      radius: radius ?? geometry.radiusMedium,
      shadowOffset: shadowOffset,
    );
    return JellySurfaceRecipe(
      normal: normal,
      hovered: normal.copyWith(
        fill: Color.alphaBlend(
          (dark ? Colors.white : Colors.black).withValues(alpha: 0.06),
          fill,
        ),
      ),
      pressed: normal.copyWith(
        shadowOffset: shadowOffset * 0.5,
        contentOffset: const Offset(0, 1),
      ),
      focused: normal,
      selected: normal.copyWith(
        fill: palette.primary,
        foreground: palette.textOnAction,
      ),
      disabled: normal.copyWith(
        fill: palette.disabledSurface,
        foreground: palette.disabledForeground,
        shadowOffset: Offset.zero,
      ),
      error: normal.copyWith(border: palette.danger),
    );
  }

  final JellySurfaceRecipe action = recipe(
    fill: palette.primary,
    foreground: palette.textOnAction,
    shadowOffset: const Offset(0, 3),
  );
  final JellySurfaceRecipe quietAction = recipe(
    fill: palette.surface,
    foreground: palette.textStrong,
    shadowOffset: Offset.zero,
  );
  final JellySurfaceRecipe container = recipe(
    fill: palette.surfaceRaised,
    foreground: palette.textStrong,
  );
  final JellySurfaceRecipe field = recipe(
    fill: palette.surface,
    foreground: palette.textStrong,
    shadowOffset: Offset.zero,
  );
  final JellySurfaceRecipe choice = recipe(
    fill: palette.surface,
    foreground: palette.textStrong,
    shadowOffset: Offset.zero,
    radius: geometry.radiusSmall,
  );
  final JellySurfaceRecipe thumb = recipe(
    fill: palette.primary,
    foreground: palette.textOnAction,
    shadowOffset: const Offset(0, 1),
    radius: 999,
  );
  final JellySurfaceRecipe track = recipe(
    fill: palette.surfaceInset,
    foreground: palette.textStrong,
    shadowOffset: Offset.zero,
    radius: 999,
  );
  final JellySurfaceRecipe status = recipe(
    fill: palette.info,
    foreground: palette.textOnAction,
    shadowOffset: Offset.zero,
    radius: 999,
  );

  return JellyMorphTheme(
    palette: palette,
    typography: JellyTypography(
      display: baseText.copyWith(fontSize: 40, fontWeight: FontWeight.w800),
      title: baseText.copyWith(fontSize: 24, fontWeight: FontWeight.w700),
      body: baseText.copyWith(fontSize: 15, height: 1.4),
      label: baseText.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
      instrumentLabel: baseText.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
      ),
      numeral: baseText.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
    ),
    geometry: geometry,
    transitions: const JellyTransitionTokens(),
    surfaces: JellySurfaceRecipes(
      action: action,
      quietAction: quietAction,
      container: container,
      field: field,
      choiceIndicator: choice,
      movableThumb: thumb,
      selectionTrack: track,
      overlay: container,
      status: status,
      progress: track,
    ),
  );
}
