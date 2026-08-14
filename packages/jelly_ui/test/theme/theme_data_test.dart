import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_ui/jelly_ui.dart';

void main() {
  test('JellyTheme.material preserves existing extensions and installs Jelly',
      () {
    final ThemeData result = JellyTheme.material(base: ThemeData.light());

    expect(result.extension<JellyThemeData>(), isNotNull);
    expect(
      result.extension<JellyThemeData>()!.morphId,
      JellyMorphs.neutral.id,
    );
  });

  test('theme interpolation preserves exact endpoints', () {
    final JellyThemeData light = JellyThemeData.fromMorph(
      morph: JellyMorphs.neutral,
      brightness: Brightness.light,
    );
    final JellyThemeData dark = JellyThemeData.fromMorph(
      morph: JellyMorphs.neutral,
      brightness: Brightness.dark,
    );

    expect(light.lerp(dark, 0).standard.palette.canvas,
        light.standard.palette.canvas);
    expect(light.lerp(dark, 1).standard.palette.canvas,
        dark.standard.palette.canvas);
    expect(
      light.lerp(dark, 0.5).standard.palette.canvas,
      Color.lerp(
        light.standard.palette.canvas,
        dark.standard.palette.canvas,
        0.5,
      ),
    );
  });

  testWidgets('local JellyTheme takes precedence over Material theme', (
    WidgetTester tester,
  ) async {
    final JellyThemeData installed = JellyThemeData.fromMorph(
      morph: JellyMorphs.neutral,
      brightness: Brightness.light,
    );
    final JellyThemeData local = installed.copyWith(
      motion: const JellyMotionSettings.none(),
    );
    late JellyThemeData observed;

    await tester.pumpWidget(
      MaterialApp(
        theme: JellyTheme.material(base: ThemeData.light()),
        home: JellyTheme(
          data: local,
          child: Builder(
            builder: (BuildContext context) {
              observed = JellyTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    expect(observed.motion.mode, JellyMotionMode.none);
  });

  testWidgets('high contrast resolves the dedicated variant', (
    WidgetTester tester,
  ) async {
    late JellyMorphTheme observed;
    await tester.pumpWidget(
      MaterialApp(
        theme: JellyTheme.material(base: ThemeData.light()),
        home: MediaQuery(
          data: const MediaQueryData(highContrast: true),
          child: Builder(
            builder: (BuildContext context) {
              observed = JellyTheme.of(context).resolveFor(context);
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    expect(observed.geometry.focusWidth, 4);
  });
}
