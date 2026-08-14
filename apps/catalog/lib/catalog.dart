import 'package:flutter/material.dart';
import 'package:jelly_morph_neobrutalism/jelly_morph_neobrutalism.dart';
import 'package:jelly_ui/jelly_ui.dart';

const List<String> legacyComponentFamilies = <String>[
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
];

class JellyCatalogApp extends StatelessWidget {
  const JellyCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jelly UI catalog',
      debugShowCheckedModeBanner: false,
      theme: JellyTheme.material(
        base: ThemeData.light().copyWith(
          scaffoldBackgroundColor: JellyInstrumentPalette.sky,
          colorScheme: ColorScheme.fromSeed(
            seedColor: JellyInstrumentPalette.lime,
            surface: JellyInstrumentPalette.paper,
          ),
        ),
        morph: JellyNeobrutalism.morph,
      ),
      home: const JellyCatalogHome(),
    );
  }
}

class JellyCatalogHome extends StatefulWidget {
  const JellyCatalogHome({super.key});

  @override
  State<JellyCatalogHome> createState() => _JellyCatalogHomeState();
}

class _JellyCatalogHomeState extends State<JellyCatalogHome> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final JellyPopoverController _popoverController = JellyPopoverController();
  bool _checked = false;
  bool _switched = true;
  bool _collapsedOpen = false;
  String _radio = 'soft';
  String _segment = 'spring';
  String _tab = 'motion';
  String? _select = 'cyan';
  Set<int> _accordion = <int>{1};
  double _slider = 0.64;
  RangeValues _range = const RangeValues(0.2, 0.78);
  double _split = 0.5;
  int _page = 3;
  int _activations = 0;
  String _menuChoice = 'none';

  @override
  void dispose() {
    _popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const JellyDrawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            JellyLabel(text: 'CATALOG DRAWER'),
            SizedBox(height: 16),
            Text('A native Scaffold drawer wearing the active Jelly morph.'),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _CatalogHeader(),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double width = constraints.maxWidth >= 1120
                      ? (constraints.maxWidth - 24) / 2
                      : constraints.maxWidth;
                  return Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    children: <Widget>[
                      SizedBox(width: width, child: _actionsAndDisplay()),
                      SizedBox(width: width, child: _choices()),
                      SizedBox(width: width, child: _fields()),
                      SizedBox(width: width, child: _valuesAndLoading()),
                      SizedBox(width: width, child: _disclosureAndLayout()),
                      SizedBox(width: width, child: _navigation()),
                      SizedBox(width: width, child: _overlays()),
                      SizedBox(width: width, child: _contractPanel()),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionsAndDisplay() {
    return _CatalogPanel(
      eyebrow: '01 / SURFACES',
      title: 'Actions & display',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              JellyButton(
                onPressed: () => setState(() => _activations += 1),
                child: const Text('PRESS THE JELLY'),
              ),
              JellyButton(
                onPressed: () {},
                variant: JellyButtonVariant.quiet,
                child: const Text('QUIET ACTION'),
              ),
              JellyIconButton(
                onPressed: () {},
                icon: const Icon(Icons.auto_awesome),
                tooltip: 'Spark the surface',
              ),
            ],
          ),
          const SizedBox(height: 12),
          JellyLabel(text: 'ACTIVATIONS $_activations'),
          const SizedBox(height: 16),
          const JellyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('A membrane, not a bitmap'),
                SizedBox(height: 8),
                Text(
                    'Pointer impulses deform one parked, repaint-only surface.'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              JellyBadge(label: 'LIVE', tone: JellySemanticTone.success),
              JellyChip(label: Text('JELLY CHIP')),
              JellyKbd('⌘ K'),
            ],
          ),
          const SizedBox(height: 16),
          const JellyDivider(),
          const SizedBox(height: 16),
          const JellyAlert(
            title: 'Everything is typed',
            child: Text('Morphs provide immutable visual instructions only.'),
          ),
        ],
      ),
    );
  }

  Widget _choices() {
    return _CatalogPanel(
      eyebrow: '02 / INPUT',
      title: 'Choice controls',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          JellyCheckbox(
            value: _checked,
            onChanged: (bool? value) => setState(() => _checked = value!),
            label: const Text('Enable tactile feedback'),
            semanticLabel: 'Enable tactile feedback',
          ),
          const SizedBox(height: 8),
          JellySwitch(
            value: _switched,
            onChanged: (bool value) => setState(() => _switched = value),
            label: const Text('Animate membranes'),
            semanticLabel: 'Animate membranes',
          ),
          const SizedBox(height: 8),
          JellyRadioGroup<String>(
            groupValue: _radio,
            onChanged: (String? value) => setState(() => _radio = value!),
            child: const Wrap(
              spacing: 12,
              children: <Widget>[
                JellyRadio<String>(value: 'soft', label: Text('Soft')),
                JellyRadio<String>(value: 'snappy', label: Text('Snappy')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          JellySegmented<String>(
            value: _segment,
            onChanged: (String value) => setState(() => _segment = value),
            segments: const <JellySegment<String>>[
              JellySegment<String>(value: 'spring', label: Text('Spring')),
              JellySegment<String>(value: 'stretch', label: Text('Stretch')),
              JellySegment<String>(value: 'pop', label: Text('Pop')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fields() {
    return _CatalogPanel(
      eyebrow: '03 / EDITING',
      title: 'Fields',
      child: Column(
        children: <Widget>[
          const JellyTextField(
            label: Text('Component name'),
            hintText: 'Jelly button',
            helperText: 'Native editing, IME, autofill, and selection.',
          ),
          const SizedBox(height: 16),
          const JellyTextArea(
            label: Text('Notes'),
            hintText: 'Describe the feel…',
            minLines: 3,
          ),
          const SizedBox(height: 16),
          const JellyOtpField(length: 4),
          const SizedBox(height: 16),
          JellySelect<String>(
            label: const Text('Accent ink'),
            value: _select,
            onChanged: (String? value) => setState(() => _select = value),
            options: const <JellyOption<String>>[
              JellyOption<String>(value: 'cyan', label: Text('Cyan')),
              JellyOption<String>(value: 'lime', label: Text('Lime')),
              JellyOption<String>(value: 'magenta', label: Text('Magenta')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _valuesAndLoading() {
    return _CatalogPanel(
      eyebrow: '04 / SIGNAL',
      title: 'Values & loading',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          JellyLabel(text: 'INTENSITY ${(_slider * 100).round()}'),
          JellySlider(
            value: _slider,
            onChanged: (double value) => setState(() => _slider = value),
          ),
          const SizedBox(height: 8),
          JellyRangeSlider(
            values: _range,
            onChanged: (RangeValues values) => setState(() => _range = values),
          ),
          const SizedBox(height: 16),
          JellyProgress(value: _slider, semanticLabel: 'Catalog progress'),
          const SizedBox(height: 20),
          const Row(
            children: <Widget>[
              JellySpinner(semanticLabel: 'Loading preview'),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    JellySkeleton(width: 180, height: 18),
                    SizedBox(height: 8),
                    JellySkeleton(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _disclosureAndLayout() {
    return _CatalogPanel(
      eyebrow: '05 / STRUCTURE',
      title: 'Disclosure & layout',
      child: Column(
        children: <Widget>[
          JellyCollapsible(
            expanded: _collapsedOpen,
            onChanged: (bool value) => setState(() => _collapsedOpen = value),
            header: const Text('Why is it fast?'),
            child: const Text(
              'Physics writes typed buffers; painting listens without rebuilding children.',
            ),
          ),
          const SizedBox(height: 16),
          JellyAccordion<int>(
            expandedValues: _accordion,
            onChanged: (Set<int> values) => setState(() => _accordion = values),
            items: const <JellyAccordionItem<int>>[
              JellyAccordionItem<int>(
                value: 1,
                header: Text('Morph boundary'),
                child: Text('Data changes appearance; behavior stays in core.'),
              ),
              JellyAccordionItem<int>(
                value: 2,
                header: Text('Motion boundary'),
                child: Text('Reduced motion is independent from every morph.'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          JellyTabs<String>(
            value: _tab,
            onChanged: (String value) => setState(() => _tab = value),
            tabs: const <JellyTab<String>>[
              JellyTab<String>(
                value: 'motion',
                label: Text('Motion'),
                child: Text('One scheduler parks every settled surface.'),
              ),
              JellyTab<String>(
                value: 'paint',
                label: Text('Paint'),
                child:
                    Text('One deformed path draws fill, border, and shadow.'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: JellyResizable(
              ratio: _split,
              onChanged: (double value) => setState(() => _split = value),
              first: const JellyCard(child: Center(child: Text('PHYSICS'))),
              second: const JellyCard(child: Center(child: Text('PAINT'))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navigation() {
    return _CatalogPanel(
      eyebrow: '06 / WAYFINDING',
      title: 'Navigation',
      child: Column(
        children: <Widget>[
          JellyBreadcrumbs(
            items: <JellyBreadcrumbItem>[
              JellyBreadcrumbItem(label: const Text('Jelly'), onPressed: () {}),
              JellyBreadcrumbItem(
                  label: const Text('Morphs'), onPressed: () {}),
              const JellyBreadcrumbItem(label: Text('Instrument')),
            ],
          ),
          const SizedBox(height: 16),
          JellyPagination(
            page: _page,
            pageCount: 9,
            onChanged: (int value) => setState(() => _page = value),
          ),
        ],
      ),
    );
  }

  Widget _overlays() {
    return _CatalogPanel(
      eyebrow: '07 / LAYERS',
      title: 'Overlays',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          JellyButton(
            onPressed: () => _showDialog(context),
            child: const Text('DIALOG'),
          ),
          JellyButton(
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            variant: JellyButtonVariant.quiet,
            child: const Text('DRAWER'),
          ),
          JellyMenu<String>(
            onSelected: (String value) => setState(() => _menuChoice = value),
            items: const <JellyMenuItem<String>>[
              JellyMenuItem<String>(
                  value: 'duplicate', child: Text('Duplicate')),
              JellyMenuItem<String>(value: 'archive', child: Text('Archive')),
            ],
            child: JellyChip(label: Text('MENU: $_menuChoice')),
          ),
          JellyPopover(
            controller: _popoverController,
            popover:
                const Text('Anchored, dismissible, and controller-driven.'),
            anchorBuilder: (
              BuildContext context,
              JellyPopoverController controller,
            ) {
              return JellyButton(
                onPressed: controller.toggle,
                variant: JellyButtonVariant.quiet,
                child: const Text('POPOVER'),
              );
            },
          ),
          Builder(
            builder: (BuildContext context) {
              return JellyButton(
                onPressed: () => JellyToast.show(
                  context,
                  message: const Text('Surface parked. No wasted frames.'),
                ),
                variant: JellyButtonVariant.quiet,
                child: const Text('TOAST'),
              );
            },
          ),
          const JellyTooltip(
            message: 'Native tooltip behavior, Jelly tokens',
            child: JellyKbd('HOVER ME'),
          ),
        ],
      ),
    );
  }

  Widget _contractPanel() {
    return const _CatalogPanel(
      eyebrow: '08 / CONTRACT',
      title: 'Complete family map',
      child: Text(
        '38 / 38 legacy families mapped. Morphs are immutable data. Motion and feedback remain independent. Native editing and overlays stay native.',
      ),
    );
  }

  Future<void> _showDialog(BuildContext context) async {
    await showJellyDialog<void>(
      context: context,
      builder: (BuildContext context) => JellyDialog(
        title: const Text('Jelly dialog'),
        actions: <Widget>[
          JellyButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
        child: const Text(
            'Routes, focus, Escape, and back remain Flutter-native.'),
      ),
    );
  }
}

class _CatalogHeader extends StatelessWidget {
  const _CatalogHeader();

  @override
  Widget build(BuildContext context) {
    final theme = JellyTheme.of(context).resolveFor(context);
    return JellyCard(
      padding: const EdgeInsets.all(24),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runAlignment: WrapAlignment.center,
        spacing: 24,
        runSpacing: 16,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const JellyLabel(text: 'JELLY / FLUTTER / INSTRUMENT'),
              const SizedBox(height: 8),
              Text('TACTILE BY DEFAULT', style: theme.typography.display),
              const SizedBox(height: 8),
              const Text(
                  '38 families · one membrane engine · zero behavior in morphs'),
            ],
          ),
          const JellyBadge(
            label: 'CATALOG ONLINE',
            tone: JellySemanticTone.success,
          ),
        ],
      ),
    );
  }
}

class _CatalogPanel extends StatelessWidget {
  const _CatalogPanel({
    required this.eyebrow,
    required this.title,
    required this.child,
  });

  final String eyebrow;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = JellyTheme.of(context).resolveFor(context);
    return JellyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          JellyLabel(text: eyebrow),
          const SizedBox(height: 8),
          Text(title, style: theme.typography.title),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
