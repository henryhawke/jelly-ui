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
  testWidgets('loading feedback exposes values and honors reduced motion', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            JellySkeleton(width: 180, semanticLabel: 'Loading profile'),
            JellySpinner(semanticLabel: 'Loading results'),
            SizedBox(
              width: 200,
              child: JellyProgress(value: 0.42, semanticLabel: 'Upload'),
            ),
          ],
        ),
        reduceMotion: true,
      ),
    );

    expect(
      tester
          .widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator),
          )
          .value,
      0.72,
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Upload')),
      matchesSemantics(label: 'Upload', value: '42%'),
    );
    expect(find.bySemanticsLabel('Loading profile'), findsOneWidget);
  });

  testWidgets('dialog opens on Flutter route and returns a result', (
    WidgetTester tester,
  ) async {
    String? result;
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (BuildContext context) {
            return JellyButton(
              onPressed: () async {
                result = await showJellyDialog<String>(
                  context: context,
                  builder: (BuildContext context) => JellyDialog(
                    title: const Text('Confirm'),
                    actions: <Widget>[
                      JellyButton(
                        onPressed: () => Navigator.pop(context, 'yes'),
                        child: const Text('Yes'),
                      ),
                    ],
                    child: const Text('Continue?'),
                  ),
                );
              },
              child: const Text('Open dialog'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();
    expect(find.text('Continue?'), findsOneWidget);
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();
    expect(result, 'yes');
  });

  testWidgets('drawer is Scaffold compatible', (WidgetTester tester) async {
    final GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
    await tester.pumpWidget(
      MaterialApp(
        theme: JellyTheme.material(base: ThemeData.light()),
        home: Scaffold(
          key: key,
          drawer: const JellyDrawer(child: Text('Drawer content')),
          body: const SizedBox.shrink(),
        ),
      ),
    );

    key.currentState!.openDrawer();
    await tester.pumpAndSettle();
    expect(find.text('Drawer content'), findsOneWidget);
    expect(find.bySemanticsLabel('Navigation menu'), findsOneWidget);
  });

  testWidgets('menu returns a typed selection', (WidgetTester tester) async {
    int? selected;
    await tester.pumpWidget(
      _app(
        JellyMenu<int>(
          onSelected: (int value) => selected = value,
          items: const <JellyMenuItem<int>>[
            JellyMenuItem<int>(value: 1, child: Text('First action')),
            JellyMenuItem<int>(value: 2, child: Text('Second action')),
          ],
          child: const Text('Open menu'),
        ),
      ),
    );

    await tester.tap(find.text('Open menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Second action'));
    await tester.pumpAndSettle();
    expect(selected, 2);
  });

  testWidgets('popover controller mounts and removes anchored content', (
    WidgetTester tester,
  ) async {
    final JellyPopoverController controller = JellyPopoverController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _app(
        JellyPopover(
          controller: controller,
          popover: const Text('Popover body'),
          anchorBuilder: (
            BuildContext context,
            JellyPopoverController controller,
          ) {
            return JellyButton(
              onPressed: controller.toggle,
              child: const Text('Toggle popover'),
            );
          },
        ),
      ),
    );

    expect(find.text('Popover body'), findsNothing);
    await tester.tap(find.text('Toggle popover'));
    await tester.pump();
    expect(controller.open, isTrue);
    expect(find.text('Popover body'), findsOneWidget);
    controller.hide();
    await tester.pump();
    expect(find.text('Popover body'), findsNothing);
  });

  testWidgets('toast uses the nearest ScaffoldMessenger live region', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (BuildContext context) {
            return JellyButton(
              onPressed: () => JellyToast.show(
                context,
                message: const Text('Saved'),
                semanticLabel: 'Saved successfully',
              ),
              child: const Text('Show toast'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Show toast'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Saved'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is Semantics &&
            widget.properties.liveRegion == true &&
            widget.properties.label == 'Saved successfully',
      ),
      findsOneWidget,
    );
  });

  testWidgets('tooltip retains native trigger configuration', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const JellyTooltip(
          message: 'Helpful detail',
          triggerMode: TooltipTriggerMode.tap,
          child: Icon(Icons.info),
        ),
      ),
    );

    final Tooltip tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
    expect(tooltip.message, 'Helpful detail');
    expect(tooltip.triggerMode, TooltipTriggerMode.tap);
  });

  testWidgets('breadcrumbs and pagination invoke controlled navigation', (
    WidgetTester tester,
  ) async {
    bool homePressed = false;
    int page = 1;
    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                JellyBreadcrumbs(
                  items: <JellyBreadcrumbItem>[
                    JellyBreadcrumbItem(
                      label: const Text('Home'),
                      onPressed: () => homePressed = true,
                    ),
                    const JellyBreadcrumbItem(label: Text('Library')),
                  ],
                ),
                JellyPagination(
                  page: page,
                  pageCount: 8,
                  onChanged: (int next) => setState(() => page = next),
                ),
              ],
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Home'));
    await tester.pump();
    expect(homePressed, isTrue);
    await tester.tap(find.byTooltip('Next page'));
    await tester.pump();
    expect(page, 2);
  });
}
