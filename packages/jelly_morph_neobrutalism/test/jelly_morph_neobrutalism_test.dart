import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_morph_neobrutalism/jelly_morph_neobrutalism.dart';
import 'package:jelly_ui/jelly_ui.dart';
import 'package:jelly_ui/src/rendering/jelly_surface_painter.dart';

void main() {
  test('exports the exact nine-token opaque palette', () {
    expect(JellyInstrumentPalette.values, const <Color>[
      Color(0xFF14120F),
      Color(0xFF00AEFF),
      Color(0xFFFFFDF6),
      Color(0xFFEDEAD8),
      Color(0xFF00FF52),
      Color(0xFF00FFFF),
      Color(0xFF00DE94),
      Color(0xFFFF2FD0),
      Color(0xFF0090CC),
    ]);
    expect(
      JellyInstrumentPalette.values.every((Color color) => color.a == 1),
      isTrue,
    );
  });

  test('uses one exact printed theme in every brightness and contrast mode',
      () {
    final JellyMorph morph = JellyNeobrutalism.morph;
    morph.validate();
    expect(morph.id, JellyNeobrutalism.id);
    expect(morph.themeFor(Brightness.light), same(morph.standard));
    expect(morph.themeFor(Brightness.dark), same(morph.standard));
    expect(
      morph.themeFor(Brightness.light, highContrast: true),
      same(morph.standard),
    );
    expect(
      morph.themeFor(Brightness.dark, highContrast: true),
      same(morph.standard),
    );
  });

  test('matches Instrument geometry and hard-shadow press law', () {
    final JellyMorphTheme theme = JellyNeobrutalism.morph.standard;
    expect(theme.geometry.controlHeight, 54);
    expect(theme.geometry.minimumTouchTarget, 48);
    expect(theme.geometry.borderStandard, 3);
    expect(theme.geometry.radiusSmall, 12);
    expect(theme.geometry.radiusMedium, 16);
    expect(theme.geometry.radiusLarge, 24);

    final JellySurfaceRecipe action = theme.surfaces.action;
    expect(action.normal.fill, JellyInstrumentPalette.lime);
    expect(action.normal.border, JellyInstrumentPalette.ink);
    expect(action.normal.borderWidth, 3);
    expect(action.normal.shadow, JellyInstrumentPalette.ink);
    expect(action.normal.shadowOffset, const Offset(4, 4));
    expect(action.pressed.shadowOffset, const Offset(3, 3));
    expect(action.pressed.contentOffset, const Offset(1, 1));
    expect(action.disabled.fill, JellyInstrumentPalette.bone);
    expect(action.disabled.shadowOffset, Offset.zero);
  });

  test('shadowless recipes change ink instead of translating', () {
    final JellySurfaceRecipe quiet =
        JellyNeobrutalism.morph.standard.surfaces.quietAction;
    expect(quiet.normal.shadowOffset, Offset.zero);
    expect(quiet.pressed.shadowOffset, Offset.zero);
    expect(quiet.pressed.contentOffset, Offset.zero);
    expect(quiet.pressed.fill, JellyInstrumentPalette.cyan);
  });

  test('ships expanded Archivo and Public Sans type roles', () {
    final JellyTypography type = JellyNeobrutalism.morph.standard.typography;
    expect(type.display.fontFamily, JellyNeobrutalism.archivoFamily);
    expect(type.title.fontFamily, JellyNeobrutalism.archivoFamily);
    expect(type.numeral.fontFamily, JellyNeobrutalism.archivoFamily);
    expect(type.body.fontFamily, JellyNeobrutalism.publicSansFamily);
    expect(type.label.fontFamily, JellyNeobrutalism.publicSansFamily);
    expect(type.instrumentLabel.fontFamily, JellyNeobrutalism.publicSansFamily);
    for (final TextStyle style in <TextStyle>[
      type.display,
      type.title,
      type.numeral,
    ]) {
      expect(style.fontVariations, contains(JellyNeobrutalism.archivoWidth));
    }
    expect(type.numeral.fontFeatures,
        contains(const FontFeature.tabularFigures()));
    expect(type.instrumentLabel.fontSize, 9);
    expect(type.instrumentLabel.letterSpacing, 1.8);
  });

  testWidgets('focus switches to paper on a dark semantic fill', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: JellyTheme.material(
          base: ThemeData.light(),
          morph: JellyNeobrutalism.morph,
        ),
        home: const JellySurface(
          role: JellySurfaceRole.action,
          tone: JellySemanticTone.danger,
          states: <WidgetState>{WidgetState.focused},
          child: SizedBox(width: 100, height: 48),
        ),
      ),
    );

    final CustomPaint paint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(JellySurface),
        matching: find.byType(CustomPaint),
      ),
    );
    final JellySurfacePainter painter = paint.painter! as JellySurfacePainter;
    expect(painter.style.fill, JellyInstrumentPalette.magenta);
    expect(painter.style.focus, JellyInstrumentPalette.paper);
  });
}
