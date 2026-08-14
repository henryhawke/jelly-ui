# jelly_ui

Tactile Flutter controls powered by an allocation-conscious soft-body surface.
Jelly keeps native Flutter editing, routes, focus, keyboard input, semantics,
and controlled state while adding a repaint-only membrane behind each surface.

## Install

```yaml
dependencies:
  jelly_ui: ^1.0.0-dev.1
```

```dart
import 'package:jelly_ui/jelly_ui.dart';
```

Install the neutral built-in theme once at the application boundary:

```dart
MaterialApp(
  theme: JellyTheme.material(base: ThemeData.light()),
  home: const MyHome(),
);
```

Then use controlled Flutter APIs:

```dart
JellySwitch(
  value: notifications,
  onChanged: (value) => setState(() => notifications = value),
  label: const Text('Notifications'),
)
```

## Component families

- Actions/display: button, icon button, card, alert, badge, chip, divider,
  keyboard key, and label.
- Choice: checkbox, radio/group, switch, segment/segmented.
- Fields/values: input, textarea, OTP, typed option/select, slider, range.
- Disclosure/layout: collapsible, accordion, tabs, resizable split.
- Feedback: progress, spinner, and shared-clock skeleton.
- Overlays/navigation: dialog, drawer, menu, popover, toast, tooltip,
  breadcrumbs, and pagination.

## Morphs

Apps can install a first- or third-party `JellyMorph`:

```dart
JellyTheme.material(
  base: ThemeData.light(),
  morph: myMorph,
  motion: const JellyMotionSettings.adaptive(),
  feedback: const JellyFeedbackSettings.platform(),
)
```

Morph authors should import `package:jelly_ui/morph.dart`. A morph supplies only
typed palette, typography, geometry, transitions, and exhaustive surface-state
recipes. It has no build context or behavior hooks.

## Performance and accessibility

- One shared scheduler serves all active surfaces and parks at rest.
- Physics hot channels are preallocated `Float32List` buffers.
- `CustomPainter(repaint:)` updates the surface without rebuilding its child.
- Reduced motion removes decorative continuous motion and bounds interaction
  feedback; high contrast and RTL are resolved from Flutter media/direction.
- Controls expose native semantic roles/actions and maintain at least 48dp
  interaction targets.

Automated tests cover those contracts, 320dp at 200% text, WCAG contrast pairs,
keyboard activation, and lifecycle parking. Real assistive technology and
physical-device profiling are still required for a production qualification.
