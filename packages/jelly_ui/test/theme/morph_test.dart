import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_ui/jelly_ui.dart';

void main() {
  group('JellyMorph', () {
    test('neutral morph covers every stable surface role', () {
      final JellyMorph morph = JellyMorphs.neutral;

      expect(morph.id, isNotEmpty);
      expect(
        JellySurfaceRole.values.map(
          (JellySurfaceRole role) => morph.standard.surfaces[role],
        ),
        hasLength(JellySurfaceRole.values.length),
      );
      expect(morph.validate, returnsNormally);
    });

    test('falls back through optional environment variants', () {
      final JellyMorphTheme standard = JellyMorphs.neutral.standard;
      final JellyMorph morph = JellyMorph(id: 'test', standard: standard);

      expect(morph.themeFor(Brightness.dark), same(standard));
      expect(
        morph.themeFor(Brightness.dark, highContrast: true),
        same(standard),
      );
    });

    test('rejects invalid geometry before paint', () {
      final JellyMorphTheme source = JellyMorphs.neutral.standard;
      final JellyMorphTheme invalid = JellyMorphTheme(
        palette: source.palette,
        typography: source.typography,
        geometry: const JellyGeometry(
          spacing: JellySpacing(),
          borderStandard: -1,
        ),
        transitions: source.transitions,
        surfaces: source.surfaces,
      );

      expect(invalid.validate, throwsA(isA<JellyMorphError>()));
    });

    test('surface state precedence is deterministic', () {
      final JellySurfaceRecipe recipe =
          JellyMorphs.neutral.standard.surfaces.action;

      expect(recipe.resolve(<WidgetState>{}), same(recipe.normal));
      expect(
        recipe.resolve(<WidgetState>{
          WidgetState.hovered,
          WidgetState.pressed,
        }),
        same(recipe.pressed),
      );
      expect(
        recipe.resolve(<WidgetState>{
          WidgetState.disabled,
          WidgetState.pressed,
          WidgetState.error,
        }),
        same(recipe.disabled),
      );
    });
  });
}
