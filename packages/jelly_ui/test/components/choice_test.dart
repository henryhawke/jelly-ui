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
  testWidgets('checkbox is controlled and exposes checked semantics', (
    WidgetTester tester,
  ) async {
    bool value = false;
    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return JellyCheckbox(
              value: value,
              semanticLabel: 'Accept terms',
              label: const Text('Accept terms'),
              onChanged: (bool? next) => setState(() => value = next!),
            );
          },
        ),
      ),
    );

    expect(
      tester.getSemantics(find.bySemanticsLabel('Accept terms')),
      matchesSemantics(
        label: 'Accept terms',
        hasCheckedState: true,
        isChecked: false,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
    await tester.tap(find.text('Accept terms'));
    await tester.pump();
    expect(value, isTrue);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('tristate checkbox cycles false, true, null, false', (
    WidgetTester tester,
  ) async {
    bool? value = false;
    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return JellyCheckbox(
              value: value,
              tristate: true,
              onChanged: (bool? next) => setState(() => value = next),
            );
          },
        ),
      ),
    );

    await tester.tap(find.byType(JellyCheckbox));
    await tester.pump();
    expect(value, isTrue);
    await tester.tap(find.byType(JellyCheckbox));
    await tester.pump();
    expect(value, isNull);
    expect(find.byIcon(Icons.remove), findsOneWidget);
    await tester.tap(find.byType(JellyCheckbox));
    await tester.pump();
    expect(value, isFalse);
  });

  testWidgets('radio group owns one controlled selection', (
    WidgetTester tester,
  ) async {
    String selected = 'a';
    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return JellyRadioGroup<String>(
              groupValue: selected,
              onChanged: (String? value) => setState(() => selected = value!),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  JellyRadio<String>(
                    value: 'a',
                    semanticLabel: 'Choice A',
                    label: Text('Alpha'),
                  ),
                  JellyRadio<String>(
                    value: 'b',
                    semanticLabel: 'Choice B',
                    label: Text('Beta'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    expect(
      tester.getSemantics(find.bySemanticsLabel('Choice A')),
      matchesSemantics(
        label: 'Choice A',
        hasCheckedState: true,
        isChecked: true,
        hasEnabledState: true,
        isEnabled: true,
        isInMutuallyExclusiveGroup: true,
        hasTapAction: true,
      ),
    );
    await tester.tap(find.text('Beta'));
    await tester.pump();
    expect(selected, 'b');
  });

  testWidgets('switch toggles and reduced motion removes travel duration', (
    WidgetTester tester,
  ) async {
    bool value = false;
    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return JellySwitch(
              value: value,
              semanticLabel: 'Notifications',
              label: const Text('Notifications'),
              onChanged: (bool next) => setState(() => value = next),
            );
          },
        ),
        reduceMotion: true,
      ),
    );

    expect(tester.widget<AnimatedAlign>(find.byType(AnimatedAlign)).duration,
        Duration.zero);
    await tester.tap(find.text('Notifications'));
    await tester.pump();
    expect(value, isTrue);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Notifications')),
      matchesSemantics(
        label: 'Notifications',
        hasToggledState: true,
        isToggled: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
  });

  testWidgets('segmented control changes one enabled typed value', (
    WidgetTester tester,
  ) async {
    int value = 1;
    await tester.pumpWidget(
      _app(
        SizedBox(
          width: 360,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return JellySegmented<int>(
                value: value,
                onChanged: (int next) => setState(() => value = next),
                segments: const <JellySegment<int>>[
                  JellySegment<int>(value: 1, label: Text('One')),
                  JellySegment<int>(value: 2, label: Text('Two')),
                  JellySegment<int>(
                    value: 3,
                    label: Text('Three'),
                    enabled: false,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Two'));
    await tester.pump();
    expect(value, 2);
    await tester.tap(find.text('Three'));
    await tester.pump();
    expect(value, 2);
    expect(tester.getSize(find.text('Two')).height, greaterThan(0));
  });

  testWidgets('choice ink never shrinks below the package target', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            JellyCheckbox(value: false, onChanged: null),
            JellyRadio<int>(value: 1, groupValue: 1),
            JellySwitch(value: false, onChanged: null),
          ],
        ),
      ),
    );

    expect(tester.getSize(find.byType(JellyCheckbox)).height,
        greaterThanOrEqualTo(48));
    expect(tester.getSize(find.byType(JellyRadio<int>)).height,
        greaterThanOrEqualTo(48));
    expect(tester.getSize(find.byType(JellySwitch)).height,
        greaterThanOrEqualTo(48));
  });
}
