import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_ui/jelly_ui.dart';
import 'package:jelly_ui/src/rendering/jelly_surface_painter.dart';

void main() {
  test('morph source remains free of behavior injection seams', () async {
    File sourceFile(String relative) {
      final List<File> candidates = <File>[
        File('packages/jelly_ui/lib/src/theme/$relative'),
        File('lib/src/theme/$relative'),
      ];
      return candidates.firstWhere((File file) => file.existsSync());
    }

    final String source = '${await sourceFile('morph.dart').readAsString()}\n'
        '${await sourceFile('tokens.dart').readAsString()}';

    for (final String prohibited in <String>[
      'BuildContext',
      'WidgetBuilder',
      'GestureDetector',
      'AnimationController',
      'VoidCallback',
      'Future<',
      'Stream<',
    ]) {
      expect(source, isNot(contains(prohibited)), reason: prohibited);
    }
  });

  test('every stable role resolves every state to finite paint data', () {
    final JellyMorph morph = JellyMorphs.neutral;
    morph.validate();
    final JellyMorphTheme theme = morph.standard;
    expect(theme.surfaces.values, hasLength(JellySurfaceRole.values.length));
    for (final JellySurfaceRole role in JellySurfaceRole.values) {
      final JellySurfaceRecipe recipe = theme.surfaces[role];
      expect(recipe.styles, hasLength(7));
      for (final JellySurfaceStyle style in recipe.styles) {
        expect(style.borderWidth.isFinite, isTrue);
        expect(style.radius.isFinite, isTrue);
        expect(style.shadowOffset.dx.isFinite, isTrue);
        expect(style.shadowOffset.dy.isFinite, isTrue);
      }
    }
  });

  test('state precedence is deterministic and safety-first', () {
    final JellySurfaceRecipe recipe =
        JellyMorphs.neutral.standard.surfaces.action;
    expect(
      recipe.resolve(<WidgetState>{WidgetState.disabled, WidgetState.pressed}),
      same(recipe.disabled),
    );
    expect(
      recipe.resolve(<WidgetState>{WidgetState.error, WidgetState.pressed}),
      same(recipe.error),
    );
    expect(
      recipe.resolve(<WidgetState>{WidgetState.pressed, WidgetState.selected}),
      same(recipe.pressed),
    );
    expect(
      recipe.resolve(<WidgetState>{WidgetState.selected, WidgetState.focused}),
      same(recipe.selected),
    );
  });

  test('motion and feedback can change without changing visual instructions',
      () {
    final JellyThemeData original = JellyThemeData.fromMorph(
      morph: JellyMorphs.neutral,
      brightness: Brightness.light,
    );
    final JellyThemeData changed = original.copyWith(
      motion: const JellyMotionSettings.none(),
      feedback: const JellyFeedbackSettings.off(),
    );

    expect(changed.morphId, original.morphId);
    expect(changed.standard, same(original.standard));
    expect(changed.highContrast, same(original.highContrast));
    expect(changed.motion.mode, JellyMotionMode.none);
    expect(changed.feedback.mode, JellyFeedbackMode.off);
  });

  testWidgets('controlled choice state does not mutate without a parent update',
      (
    WidgetTester tester,
  ) async {
    bool? requested;
    await tester.pumpWidget(
      MaterialApp(
        theme: JellyTheme.material(base: ThemeData.light()),
        home: JellyCheckbox(
          value: false,
          onChanged: (bool? value) => requested = value,
        ),
      ),
    );

    await tester.tap(find.byType(JellyCheckbox));
    await tester.pump();
    expect(requested, isTrue);
    expect(find.byIcon(Icons.check), findsNothing);
  });

  testWidgets('disabled state wins over a requested semantic tone', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: JellyTheme.material(base: ThemeData.light()),
        home: const JellySurface(
          role: JellySurfaceRole.action,
          tone: JellySemanticTone.danger,
          states: <WidgetState>{WidgetState.disabled},
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
    final JellyPalette palette = JellyMorphs.neutral.standard.palette;
    expect(painter.style.fill, palette.disabledSurface);
    expect(painter.style.foreground, palette.disabledForeground);
  });
}
