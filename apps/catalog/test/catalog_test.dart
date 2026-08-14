import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_catalog/catalog.dart';
import 'package:jelly_ui/src/components/feedback/loading_clock.dart';

void main() {
  const Set<String> expectedLegacyFamilies = <String>{
    'accordion',
    'alert',
    'badge',
    'breadcrumbs',
    'button',
    'card',
    'checkbox',
    'chip',
    'collapsible',
    'dialog',
    'divider',
    'drawer',
    'icon-button',
    'input',
    'kbd',
    'label',
    'menu',
    'option',
    'otp',
    'pagination',
    'popover',
    'progress',
    'radio',
    'radio-group',
    'range',
    'resizable',
    'segment',
    'segmented',
    'select',
    'skeleton',
    'slider',
    'spinner',
    'switch',
    'tabs',
    'textarea',
    'theme',
    'toast',
    'tooltip',
  };

  test('catalog maps every legacy family exactly once', () {
    expect(legacyComponentFamilies, hasLength(38));
    expect(legacyComponentFamilies.toSet(), hasLength(38));
    expect(legacyComponentFamilies.toSet(), expectedLegacyFamilies);
  });

  testWidgets('catalog mounts every interactive section without exceptions', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const JellyCatalogApp());
    await tester.pump();

    expect(find.text('TACTILE BY DEFAULT'), findsOneWidget);
    expect(find.text('Actions & display'), findsOneWidget);
    expect(find.text('Choice controls'), findsOneWidget);
    expect(find.text('Fields'), findsOneWidget);
    expect(find.text('Values & loading'), findsOneWidget);
    expect(find.text('38 / 38 legacy families mapped.'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(JellyLoadingClock.instance.debugListenerCount, 0);
  });

  testWidgets('primary surface and switch update controlled catalog state', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const JellyCatalogApp());

    expect(find.text('ACTIVATIONS 0'), findsOneWidget);
    await tester.tap(find.text('PRESS THE JELLY'));
    await tester.pump();
    expect(find.text('ACTIVATIONS 1'), findsOneWidget);

    final Finder switchLabel = find.text('Animate membranes');
    await tester.ensureVisible(switchLabel);
    await tester.tap(switchLabel);
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(JellyLoadingClock.instance.debugListenerCount, 0);
  });

  testWidgets('dialog opens and closes from the catalog', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const JellyCatalogApp());

    final Finder dialogButton = find.text('DIALOG');
    await tester.scrollUntilVisible(
      dialogButton,
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(dialogButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Jelly dialog'), findsOneWidget);
    await tester.tap(find.text('CLOSE'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Jelly dialog'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(JellyLoadingClock.instance.debugListenerCount, 0);
  });
}
