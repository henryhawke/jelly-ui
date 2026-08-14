import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_ui/jelly_ui.dart';
import 'package:jelly_ui/src/components/feedback/loading_clock.dart';
import 'package:jelly_ui/src/rendering/jelly_surface_painter.dart';

Widget _app(
  Widget child, {
  MediaQueryData media = const MediaQueryData(),
  TextDirection direction = TextDirection.ltr,
}) {
  return MaterialApp(
    theme: JellyTheme.material(base: ThemeData.light()),
    home: MediaQuery(
      data: media,
      child: Directionality(
        textDirection: direction,
        child: Scaffold(body: child),
      ),
    ),
  );
}

double _contrast(Color first, Color second) {
  final double a = first.computeLuminance();
  final double b = second.computeLuminance();
  final double lighter = a > b ? a : b;
  final double darker = a > b ? b : a;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  test('neutral semantic text colors clear WCAG normal-text contrast', () {
    final JellyPalette palette = JellyMorphs.neutral.standard.palette;
    for (final JellySemanticTone tone in JellySemanticTone.values.skip(1)) {
      final Color background = palette.tone(tone);
      expect(
        _contrast(palette.foregroundFor(tone), background),
        greaterThanOrEqualTo(4.5),
        reason: 'semantic foreground must clear $background',
      );
    }
    expect(
      _contrast(palette.textStrong, palette.surface),
      greaterThanOrEqualTo(4.5),
    );
  });

  testWidgets('320dp and 200% text scale do not overflow core controls', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      _app(
        ListView(
          padding: const EdgeInsets.all(12),
          children: <Widget>[
            JellyButton(
              onPressed: () {},
              expanded: true,
              child: const Text('A long but meaningful primary action'),
            ),
            const SizedBox(height: 12),
            const JellyTextField(
              label: Text('A descriptive text field label'),
              helperText: 'Instructions remain visible at large text sizes.',
            ),
            const SizedBox(height: 12),
            const JellyAlert(
              title: 'Status explained in words',
              child: Text('Color is never the only indication of this state.'),
            ),
            const SizedBox(height: 12),
            JellyPagination(page: 3, pageCount: 8, onChanged: (_) {}),
          ],
        ),
        media: const MediaQueryData(textScaler: TextScaler.linear(2)),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion removes decorative continuous animation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const Column(
          children: <Widget>[
            JellySkeleton(width: 120),
            JellySpinner(),
            JellySwitch(value: true, onChanged: null),
            JellyCollapsible(
              expanded: true,
              onChanged: null,
              header: Text('Header'),
              child: Text('Body'),
            ),
          ],
        ),
        media: const MediaQueryData(disableAnimations: true),
      ),
    );

    expect(JellyLoadingClock.instance.debugListenerCount, 0);
    expect(
      tester
          .widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator),
          )
          .value,
      isNotNull,
    );
    expect(
      tester.widget<AnimatedAlign>(find.byType(AnimatedAlign)).duration,
      Duration.zero,
    );
    expect(
      tester.widget<AnimatedSize>(find.byType(AnimatedSize)).duration,
      Duration.zero,
    );
  });

  testWidgets('high contrast selects the authored high-contrast recipe', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const JellySurface(
          role: JellySurfaceRole.action,
          child: SizedBox(width: 100, height: 48),
        ),
        media: const MediaQueryData(highContrast: true),
      ),
    );

    final CustomPaint paint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(JellySurface),
        matching: find.byType(CustomPaint),
      ),
    );
    final JellySurfacePainter painter = paint.painter! as JellySurfacePainter;
    expect(painter.style.borderWidth, 3);
    expect(painter.focusWidth, 4);
  });

  testWidgets('directional progress fills from the logical start in RTL', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const Center(
          child: SizedBox(width: 240, child: JellyProgress(value: 0.5)),
        ),
        direction: TextDirection.rtl,
      ),
    );

    final Finder surfaces = find.byType(JellySurface);
    expect(surfaces, findsNWidgets(2));
    final Rect outer = tester.getRect(surfaces.at(0));
    final Rect inner = tester.getRect(surfaces.at(1));
    expect(inner.width, closeTo(outer.width * 0.5, 1));
    expect(inner.right, closeTo(outer.right, 1));
  });

  testWidgets('button has a stable name, role, target, and keyboard action', (
    WidgetTester tester,
  ) async {
    int activations = 0;
    final FocusNode node = FocusNode();
    addTearDown(node.dispose);
    await tester.pumpWidget(
      _app(
        Center(
          child: JellyButton(
            onPressed: () => activations += 1,
            semanticLabel: 'Save changes',
            focusNode: node,
            child: const Text('Save'),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(JellyButton)).height,
        greaterThanOrEqualTo(48));
    expect(
      tester.getSemantics(find.bySemanticsLabel('Save changes')),
      matchesSemantics(
        label: 'Save changes',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
    node.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(activations, 1);
  });
}
