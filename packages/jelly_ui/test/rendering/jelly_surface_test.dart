import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_ui/jelly_ui.dart';

void main() {
  testWidgets('surface sizes its membrane from the painted control box', (
    WidgetTester tester,
  ) async {
    final JellySurfaceController controller = JellySurfaceController();
    await tester.pumpWidget(
      MaterialApp(
        theme: JellyTheme.material(base: ThemeData.light()),
        home: Center(
          child: SizedBox(
            width: 160,
            height: 56,
            child: JellySurface(
              controller: controller,
              role: JellySurfaceRole.action,
              child: const Text('Save'),
            ),
          ),
        ),
      ),
    );

    expect(controller.body.width, 160);
    expect(controller.body.height, 56);
    expect(find.text('Save'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(JellySurface),
        matching: find.byType(CustomPaint),
      ),
      findsOneWidget,
    );
    controller.dispose();
  });

  testWidgets('physics repaint does not rebuild the child subtree', (
    WidgetTester tester,
  ) async {
    final JellySurfaceController controller = JellySurfaceController();
    int childBuilds = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: JellyTheme.material(base: ThemeData.light()),
        home: SizedBox(
          width: 140,
          height: 52,
          child: JellySurface(
            controller: controller,
            child: Builder(
              builder: (BuildContext context) {
                childBuilds += 1;
                return const Text('Stable child');
              },
            ),
          ),
        ),
      ),
    );
    final int initialBuilds = childBuilds;

    controller.centerPop();
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 16));

    expect(childBuilds, initialBuilds);
    controller.dispose();
  });

  testWidgets('focus state keeps child semantics and paints an external ring', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: JellyTheme.material(base: ThemeData.light()),
        home: SizedBox(
          width: 120,
          height: 48,
          child: JellySurface(
            states: const <WidgetState>{WidgetState.focused},
            child: Semantics(button: true, label: 'Focused action'),
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Focused action'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
