import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_ui/jelly_ui.dart';

Widget _app(Widget child) {
  return MaterialApp(
    theme: JellyTheme.material(base: ThemeData.light()),
    home: Scaffold(
      body: Center(child: SizedBox(width: 360, child: child)),
    ),
  );
}

void main() {
  testWidgets('text field retains native editing and focus behavior', (
    WidgetTester tester,
  ) async {
    final TextEditingController controller = TextEditingController();
    addTearDown(controller.dispose);
    String changed = '';
    await tester.pumpWidget(
      _app(
        JellyTextField(
          controller: controller,
          label: const Text('Name'),
          hintText: 'Ada',
          semanticLabel: 'Display name',
          onChanged: (String value) => changed = value,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Grace');
    await tester.pump();
    expect(controller.text, 'Grace');
    expect(changed, 'Grace');
    expect(tester.widget<TextField>(find.byType(TextField)).focusNode?.hasFocus,
        isTrue);
    expect(
      tester.widget<JellySurface>(find.byType(JellySurface)).states,
      contains(WidgetState.focused),
    );
  });

  testWidgets('field error is live and resolves the error surface state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const JellyTextField(
          errorText: 'Required',
          helperText: 'Ignored while invalid',
        ),
      ),
    );

    expect(find.text('Required'), findsOneWidget);
    expect(find.text('Ignored while invalid'), findsNothing);
    expect(
      tester.widget<JellySurface>(find.byType(JellySurface)).states,
      contains(WidgetState.error),
    );
    expect(
      tester.getSemantics(find.text('Required')),
      matchesSemantics(
        label: 'Required',
        isLiveRegion: true,
      ),
    );
  });

  testWidgets('text area is a multiline native field', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app(const JellyTextArea(minLines: 3)));

    final TextField field = tester.widget<TextField>(find.byType(TextField));
    expect(field.minLines, 3);
    expect(field.maxLines, 8);
    expect(field.keyboardType, TextInputType.multiline);
  });

  testWidgets('otp accepts digits only and completes at the requested length', (
    WidgetTester tester,
  ) async {
    String? completed;
    await tester.pumpWidget(
      _app(
        JellyOtpField(
          length: 4,
          onCompleted: (String value) => completed = value,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '1a23b4');
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField)).controller?.text,
        anyOf(isNull, '1234'));
    expect(find.text('1234'), findsOneWidget);
    expect(completed, '1234');
  });

  testWidgets('typed select returns the selected option', (
    WidgetTester tester,
  ) async {
    String? value = 'a';
    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return JellySelect<String>(
              value: value,
              onChanged: (String? next) => setState(() => value = next),
              options: const <JellyOption<String>>[
                JellyOption<String>(value: 'a', label: Text('Alpha')),
                JellyOption<String>(value: 'b', label: Text('Beta')),
              ],
            );
          },
        ),
      ),
    );

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Beta').last);
    await tester.pumpAndSettle();
    expect(value, 'b');
  });

  testWidgets('slider and range slider preserve controlled values', (
    WidgetTester tester,
  ) async {
    double scalar = 0.25;
    RangeValues range = const RangeValues(0.2, 0.8);
    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                JellySlider(
                  value: scalar,
                  onChanged: (double value) {
                    setState(() => scalar = value);
                  },
                ),
                JellyRangeSlider(
                  values: range,
                  onChanged: (RangeValues values) {
                    setState(() => range = values);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );

    await tester.drag(find.byType(Slider), const Offset(100, 0));
    await tester.pump();
    expect(scalar, greaterThan(0.25));
    await tester.dragFrom(
      tester.getCenter(find.byType(RangeSlider)) - const Offset(80, 0),
      const Offset(40, 0),
    );
    await tester.pump();
    expect(range.start, greaterThanOrEqualTo(0.2));
    expect(range.end, 0.8);
  });
}
