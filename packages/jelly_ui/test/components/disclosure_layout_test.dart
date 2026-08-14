import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_ui/jelly_ui.dart';

Widget _app(Widget child, {bool reduceMotion = false}) {
  return MaterialApp(
    theme: JellyTheme.material(base: ThemeData.light()),
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  testWidgets('collapsible is controlled and exposes expanded semantics', (
    WidgetTester tester,
  ) async {
    bool expanded = false;
    await tester.pumpWidget(
      _app(
        SizedBox(
          width: 320,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return JellyCollapsible(
                expanded: expanded,
                onChanged: (bool value) => setState(() => expanded = value),
                semanticLabel: 'Details',
                header: const Text('Show details'),
                child: const Text('Hidden content'),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Hidden content'), findsNothing);
    expect(find.text('Hidden content', skipOffstage: false), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Details')),
      matchesSemantics(
        label: 'Details',
        hasTapAction: true,
        hasEnabledState: true,
        isEnabled: true,
        hasExpandedState: true,
        isExpanded: false,
        isButton: true,
      ),
    );
    await tester.tap(find.text('Show details'));
    await tester.pumpAndSettle();
    expect(expanded, isTrue);
    expect(tester.getSize(find.text('Hidden content')).height, greaterThan(0));
  });

  testWidgets('reduced motion removes disclosure and tab durations', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const JellyCollapsible(
              expanded: true,
              onChanged: null,
              header: Text('Header'),
              child: Text('Content'),
            ),
            JellyTabs<int>(
              value: 1,
              onChanged: null,
              tabs: const <JellyTab<int>>[
                JellyTab<int>(value: 1, label: Text('One'), child: Text('A')),
                JellyTab<int>(value: 2, label: Text('Two'), child: Text('B')),
              ],
            ),
          ],
        ),
        reduceMotion: true,
      ),
    );

    expect(tester.widget<AnimatedSize>(find.byType(AnimatedSize)).duration,
        Duration.zero);
    expect(
      tester.widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher)).duration,
      Duration.zero,
    );
  });

  testWidgets('single accordion replaces its open value', (
    WidgetTester tester,
  ) async {
    Set<int> open = <int>{1};
    await tester.pumpWidget(
      _app(
        SizedBox(
          width: 320,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return JellyAccordion<int>(
                expandedValues: open,
                onChanged: (Set<int> next) => setState(() => open = next),
                items: const <JellyAccordionItem<int>>[
                  JellyAccordionItem<int>(
                    value: 1,
                    header: Text('First'),
                    child: Text('First body'),
                  ),
                  JellyAccordionItem<int>(
                    value: 2,
                    header: Text('Second'),
                    child: Text('Second body'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Second'));
    await tester.pumpAndSettle();
    expect(open, <int>{2});
  });

  testWidgets('typed tabs select enabled content', (
    WidgetTester tester,
  ) async {
    String value = 'one';
    await tester.pumpWidget(
      _app(
        SizedBox(
          width: 360,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return JellyTabs<String>(
                value: value,
                onChanged: (String next) => setState(() => value = next),
                tabs: const <JellyTab<String>>[
                  JellyTab<String>(
                    value: 'one',
                    label: Text('One'),
                    child: Text('First panel'),
                  ),
                  JellyTab<String>(
                    value: 'two',
                    label: Text('Two'),
                    child: Text('Second panel'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('First panel'), findsOneWidget);
    await tester.tap(find.text('Two'));
    await tester.pumpAndSettle();
    expect(value, 'two');
    expect(find.text('Second panel'), findsOneWidget);
  });

  testWidgets('resizable drag updates a bounded controlled ratio', (
    WidgetTester tester,
  ) async {
    double ratio = 0.5;
    await tester.pumpWidget(
      _app(
        SizedBox(
          width: 400,
          height: 160,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return JellyResizable(
                ratio: ratio,
                onChanged: (double next) => setState(() => ratio = next),
                first: const ColoredBox(color: Colors.red),
                second: const ColoredBox(color: Colors.blue),
              );
            },
          ),
        ),
      ),
    );

    await tester.drag(
        find.bySemanticsLabel('Resize panels'), const Offset(80, 0));
    await tester.pump();
    expect(ratio, greaterThan(0.5));
    expect(ratio, lessThanOrEqualTo(1));
  });
}
