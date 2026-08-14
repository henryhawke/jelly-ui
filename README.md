# Jelly UI for Flutter

Jelly UI is a Flutter design-system package with tactile soft-body surfaces,
native control behavior, a data-only visual plugin seam called **morphs**, and a
complete interactive web catalog. The repository no longer contains the retired
TypeScript/Web Components implementation.

```dart
import 'package:flutter/material.dart';
import 'package:jelly_morph_neobrutalism/jelly_morph_neobrutalism.dart';
import 'package:jelly_ui/jelly_ui.dart';

MaterialApp(
  theme: JellyTheme.material(
    base: ThemeData.light(),
    morph: JellyNeobrutalism.morph,
  ),
  home: JellyButton(
    onPressed: publish,
    child: const Text('PUBLISH'),
  ),
);
```

## Packages

- `packages/jelly_ui` — controls, typed tokens, motion policy, membrane physics,
  shared scheduler, rendering, semantics, fields, navigation, and overlays.
- `packages/jelly_morph_neobrutalism` — the FartUI Instrument language: nine
  opaque inks, expanded Archivo, Public Sans, hard shadows, and printed geometry.
- `apps/catalog` — responsive web catalog covering all 38 legacy families.

Morphs are immutable appearance instructions. They cannot inject widgets,
callbacks, gestures, async work, animation controllers, or physics behavior.
Motion and platform feedback are configured independently through
`JellyMotionSettings` and `JellyFeedbackSettings`.

## Develop and verify

```sh
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test packages/jelly_ui/test packages/jelly_ui/benchmark \
  packages/jelly_morph_neobrutalism/test apps/catalog/test
(cd apps/catalog && flutter build web --release)
```

Run the catalog locally with:

```sh
cd apps/catalog
flutter run -d chrome
```

The implementation blueprint is in [`docs/FLUTTER_BLUEPRINT.md`](docs/FLUTTER_BLUEPRINT.md).
Numeric lab/field boundaries are in
[`docs/PERFORMANCE_BUDGET.json`](docs/PERFORMANCE_BUDGET.json). Local VM
microbenchmarks are regression alarms; physical-device frame traces and
production Core Web Vitals remain release evidence.

## Architecture

```text
app state + native Flutter behavior
                 │
          Jelly components
                 │
      typed morph + motion policy
                 │
     JellySurface / CustomPainter
                 │
preallocated membrane + one parked scheduler
```

The hot paint path uses one deformed path for fill, zero-blur shadow, border,
and focus treatment. Physics notifications repaint without rebuilding stable
child content, and the process-wide scheduler stops requesting frames when the
last membrane settles.

## License

Jelly UI is MIT licensed. The Instrument morph bundles Archivo and Public Sans
under SIL OFL 1.1; its compiled asset includes the full font notices.
