import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_ui/jelly_ui.dart';

Widget _app(Widget child) {
  return MaterialApp(
    theme: JellyTheme.material(base: ThemeData.light()),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('button activates by pointer and exposes button semantics', (
    WidgetTester tester,
  ) async {
    int presses = 0;
    await tester.pumpWidget(
      _app(
        JellyButton(
          onPressed: () => presses += 1,
          semanticLabel: 'Submit form',
          child: const Text('Submit'),
        ),
      ),
    );

    await tester.tap(find.byType(JellyButton));
    expect(presses, 1);
    final SemanticsNode node = tester.getSemantics(
      find.bySemanticsLabel('Submit form'),
    );
    expect(node.getSemanticsData().flagsCollection.isButton, isTrue);
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
  });

  testWidgets('pressed state lands before release and drives one surface', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(JellyButton(onPressed: () {}, child: const Text('Hold'))),
    );
    final Offset center = tester.getCenter(find.byType(JellyButton));
    final TestGesture gesture = await tester.startGesture(center);
    await tester.pump();

    final Finder surface = find.descendant(
      of: find.byType(JellyButton),
      matching: find.byType(JellySurface),
    );
    expect(
      tester.widget<JellySurface>(surface).states,
      contains(WidgetState.pressed),
    );

    await gesture.up();
    await tester.pump();
    expect(
      tester.widget<JellySurface>(surface).states,
      isNot(contains(WidgetState.pressed)),
    );
  });

  testWidgets('button activates with keyboard and loading rejects input', (
    WidgetTester tester,
  ) async {
    int presses = 0;
    final FocusNode focusNode = FocusNode();
    await tester.pumpWidget(
      _app(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            JellyButton(
              focusNode: focusNode,
              autofocus: true,
              onPressed: () => presses += 1,
              child: const Text('Keyboard'),
            ),
            JellyButton(
              loading: true,
              onPressed: () => presses += 100,
              child: const Text('Hidden'),
            ),
          ],
        ),
      ),
    );
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(presses, 1);
    await tester.tap(find.text('LOADING'));
    expect(presses, 1);
    focusNode.dispose();
  });

  testWidgets('icon button keeps a 48 logical pixel target and tooltip', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(
        JellyIconButton(
          onPressed: () {},
          icon: const Icon(Icons.close),
          tooltip: 'Close panel',
          size: JellyControlSize.compact,
        ),
      ),
    );

    final Size size = tester.getSize(find.byType(JellyIconButton));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
    expect(find.byType(Tooltip), findsOneWidget);
    expect(find.bySemanticsLabel('Close panel'), findsOneWidget);
  });

  testWidgets('display primitives render their intentional content', (
    WidgetTester tester,
  ) async {
    int dismissals = 0;
    await tester.pumpWidget(
      _app(
        SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const JellyCard(child: Text('Card content')),
              const JellyBadge(label: 'Ready'),
              const JellyChip(label: Text('Filter'), selected: true),
              const SizedBox(width: 200, child: JellyDivider()),
              const JellyLabel(text: 'Email', required: true),
              const JellyKbd('⌘K'),
              JellyAlert(
                title: 'Network unavailable',
                onDismiss: () => dismissals += 1,
                child: const Text('Try again when you are online.'),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Card content'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('Filter'), findsOneWidget);
    expect(find.textContaining('required'), findsOneWidget);
    expect(find.text('⌘K'), findsOneWidget);
    await tester.tap(find.byTooltip('Dismiss Network unavailable'));
    expect(dismissals, 1);
  });

  testWidgets('disabled button rejects pointer input', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(const JellyButton(onPressed: null, child: Text('Disabled'))),
    );

    final SemanticsNode node = tester.getSemantics(find.text('Disabled'));
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
    await tester.tap(find.text('Disabled'));
    expect(tester.takeException(), isNull);
  });
}
