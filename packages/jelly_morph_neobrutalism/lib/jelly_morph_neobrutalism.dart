/// Printed-hardware neobrutalism for Jelly UI.
library;

import 'package:flutter/material.dart';
import 'package:jelly_ui/jelly_ui.dart';

/// The canonical nine opaque Instrument colors.
abstract final class JellyInstrumentPalette {
  static const Color ink = Color(0xFF14120F);
  static const Color sky = Color(0xFF00AEFF);
  static const Color paper = Color(0xFFFFFDF6);
  static const Color bone = Color(0xFFEDEAD8);
  static const Color lime = Color(0xFF00FF52);
  static const Color cyan = Color(0xFF00FFFF);
  static const Color jade = Color(0xFF00DE94);
  static const Color magenta = Color(0xFFFF2FD0);
  static const Color deepSky = Color(0xFF0090CC);

  static const List<Color> values = <Color>[
    ink,
    sky,
    paper,
    bone,
    lime,
    cyan,
    jade,
    magenta,
    deepSky,
  ];
}

/// Installs the exact FartUI Instrument visual instructions into Jelly.
abstract final class JellyNeobrutalism {
  static const String id = 'jelly.neobrutalism.instrument';
  static const String archivoFamily =
      'packages/jelly_morph_neobrutalism/JellyInstrumentArchivo';
  static const String publicSansFamily =
      'packages/jelly_morph_neobrutalism/JellyInstrumentPublicSans';
  static const FontVariation archivoWidth = FontVariation('wdth', 125);

  /// The morph deliberately uses the same printed palette in light and dark.
  static final JellyMorph morph = JellyMorph(
    id: id,
    standard: _theme,
    dark: _theme,
    highContrast: _theme,
    highContrastDark: _theme,
  );

  static final JellyMorphTheme _theme = _buildTheme();
}

JellyMorphTheme _buildTheme() {
  const JellyPalette palette = JellyPalette(
    canvas: JellyInstrumentPalette.sky,
    surface: JellyInstrumentPalette.paper,
    surfaceRaised: JellyInstrumentPalette.paper,
    surfaceInset: JellyInstrumentPalette.bone,
    textStrong: JellyInstrumentPalette.ink,
    textMuted: JellyInstrumentPalette.ink,
    border: JellyInstrumentPalette.ink,
    focus: JellyInstrumentPalette.ink,
    focusOnDark: JellyInstrumentPalette.paper,
    shadow: JellyInstrumentPalette.ink,
    primary: JellyInstrumentPalette.lime,
    primaryForeground: JellyInstrumentPalette.ink,
    info: JellyInstrumentPalette.cyan,
    infoForeground: JellyInstrumentPalette.ink,
    success: JellyInstrumentPalette.jade,
    successForeground: JellyInstrumentPalette.ink,
    warning: JellyInstrumentPalette.bone,
    warningForeground: JellyInstrumentPalette.ink,
    danger: JellyInstrumentPalette.magenta,
    dangerForeground: JellyInstrumentPalette.ink,
    disabledSurface: JellyInstrumentPalette.bone,
    disabledForeground: JellyInstrumentPalette.ink,
  );
  const JellyGeometry geometry = JellyGeometry(
    spacing: JellySpacing(
      xxs: 2,
      xs: 4,
      sm: 8,
      md: 12,
      lg: 16,
      xl: 24,
      xxl: 32,
    ),
    compactControlHeight: 44,
    controlHeight: 54,
    largeControlHeight: 64,
    minimumTouchTarget: 48,
    radiusSmall: 12,
    radiusMedium: 16,
    radiusLarge: 24,
    borderThin: 1.5,
    borderStandard: 3,
    focusWidth: 3,
    focusGap: 3,
  );
  const List<FontVariation> expanded = <FontVariation>[
    JellyNeobrutalism.archivoWidth,
  ];
  const List<FontFeature> tabular = <FontFeature>[
    FontFeature.tabularFigures(),
  ];
  const JellyTypography typography = JellyTypography(
    display: TextStyle(
      fontFamily: 'JellyInstrumentArchivo',
      package: 'jelly_morph_neobrutalism',
      fontSize: 33,
      fontWeight: FontWeight.w900,
      height: 0.96,
      letterSpacing: -0.66,
      color: JellyInstrumentPalette.ink,
      fontVariations: expanded,
    ),
    title: TextStyle(
      fontFamily: 'JellyInstrumentArchivo',
      package: 'jelly_morph_neobrutalism',
      fontSize: 24,
      fontWeight: FontWeight.w800,
      height: 1,
      letterSpacing: -0.24,
      color: JellyInstrumentPalette.ink,
      fontVariations: expanded,
    ),
    body: TextStyle(
      fontFamily: 'JellyInstrumentPublicSans',
      package: 'jelly_morph_neobrutalism',
      fontSize: 14.5,
      fontWeight: FontWeight.w600,
      height: 1.35,
      color: JellyInstrumentPalette.ink,
    ),
    label: TextStyle(
      fontFamily: 'JellyInstrumentPublicSans',
      package: 'jelly_morph_neobrutalism',
      fontSize: 15,
      fontWeight: FontWeight.w800,
      height: 1,
      color: JellyInstrumentPalette.ink,
    ),
    instrumentLabel: TextStyle(
      fontFamily: 'JellyInstrumentPublicSans',
      package: 'jelly_morph_neobrutalism',
      fontSize: 9,
      fontWeight: FontWeight.w800,
      height: 1,
      letterSpacing: 1.8,
      color: JellyInstrumentPalette.ink,
    ),
    numeral: TextStyle(
      fontFamily: 'JellyInstrumentArchivo',
      package: 'jelly_morph_neobrutalism',
      fontSize: 19,
      fontWeight: FontWeight.w800,
      height: 1,
      color: JellyInstrumentPalette.ink,
      fontVariations: expanded,
      fontFeatures: tabular,
    ),
  );

  JellySurfaceRecipe elevated({
    required Color fill,
    required Offset shadow,
    double radius = 16,
    double borderWidth = 3,
  }) {
    final JellySurfaceStyle normal = JellySurfaceStyle(
      fill: fill,
      foreground: JellyInstrumentPalette.ink,
      border: JellyInstrumentPalette.ink,
      shadow: JellyInstrumentPalette.ink,
      focus: _focusFor(fill),
      borderWidth: borderWidth,
      radius: radius,
      shadowOffset: shadow,
    );
    return JellySurfaceRecipe(
      normal: normal,
      hovered: normal,
      pressed: normal.copyWith(
        shadowOffset: Offset(
          shadow.dx == 0 ? 0 : shadow.dx - shadow.dx.sign,
          shadow.dy == 0 ? 0 : shadow.dy - shadow.dy.sign,
        ),
        contentOffset: const Offset(1, 1),
      ),
      focused: normal,
      selected: normal.copyWith(fill: JellyInstrumentPalette.cyan),
      disabled: normal.copyWith(
        fill: JellyInstrumentPalette.bone,
        foreground: JellyInstrumentPalette.ink,
        shadowOffset: Offset.zero,
      ),
      error: normal,
    );
  }

  JellySurfaceRecipe flat({
    required Color fill,
    double radius = 16,
    double borderWidth = 3,
  }) {
    final JellySurfaceStyle normal = JellySurfaceStyle(
      fill: fill,
      foreground: JellyInstrumentPalette.ink,
      border: JellyInstrumentPalette.ink,
      shadow: JellyInstrumentPalette.ink,
      focus: _focusFor(fill),
      borderWidth: borderWidth,
      radius: radius,
    );
    return JellySurfaceRecipe(
      normal: normal,
      hovered: normal.copyWith(fill: JellyInstrumentPalette.cyan),
      pressed: normal.copyWith(fill: JellyInstrumentPalette.cyan),
      focused: normal,
      selected: normal.copyWith(fill: JellyInstrumentPalette.cyan),
      disabled: normal.copyWith(
        fill: JellyInstrumentPalette.bone,
        foreground: JellyInstrumentPalette.ink,
      ),
      error: normal,
    );
  }

  return JellyMorphTheme(
    palette: palette,
    typography: typography,
    geometry: geometry,
    transitions: const JellyTransitionTokens(
      fast: Duration(milliseconds: 120),
      standard: Duration(milliseconds: 180),
      slow: Duration(milliseconds: 300),
      pressCurve: Cubic(0.3, 0.8, 0.2, 1),
      settleCurve: Cubic(0.2, 0.9, 0.25, 1),
    ),
    surfaces: JellySurfaceRecipes(
      action: elevated(
        fill: JellyInstrumentPalette.lime,
        shadow: const Offset(4, 4),
      ),
      quietAction: flat(fill: JellyInstrumentPalette.paper),
      container: elevated(
        fill: JellyInstrumentPalette.paper,
        shadow: const Offset(5, 5),
      ),
      field: elevated(
        fill: JellyInstrumentPalette.paper,
        shadow: const Offset(4, 4),
      ),
      choiceIndicator: elevated(
        fill: JellyInstrumentPalette.paper,
        shadow: const Offset(2, 2),
        radius: 12,
        borderWidth: 2,
      ),
      movableThumb: elevated(
        fill: JellyInstrumentPalette.cyan,
        shadow: const Offset(2, 2),
        radius: 999,
        borderWidth: 2,
      ),
      selectionTrack: flat(
        fill: JellyInstrumentPalette.bone,
        radius: 999,
      ),
      overlay: elevated(
        fill: JellyInstrumentPalette.paper,
        shadow: const Offset(6, 6),
        radius: 24,
      ),
      status: flat(
        fill: JellyInstrumentPalette.cyan,
        radius: 999,
        borderWidth: 2,
      ),
      progress: flat(
        fill: JellyInstrumentPalette.bone,
        radius: 999,
        borderWidth: 1.5,
      ),
    ),
  );
}

Color _focusFor(Color fill) {
  return fill.computeLuminance() < 0.35
      ? JellyInstrumentPalette.paper
      : JellyInstrumentPalette.ink;
}
