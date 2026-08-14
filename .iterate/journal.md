# Jelly Flutter conversion journal

## Iteration 0 — bootstrap

- Re-read the accepted Flutter blueprint and canonical FartUI Instrument rules.
- Confirmed the source baseline is `8e39a8e` and preserved it by creating `codex/flutter-rebuild`.
- Split the objective into 15 dependency-ordered units with executable acceptance checks.
- Critical scope ruling: “complete” means all 38 legacy component families have an intentional Flutter API and catalog fixture; it does not mean claiming physical-device performance from a browser or simulator.
- Note to future self: keep the physics/rendering seam private until two real render adapters exist, and never let a morph inject behavior or per-frame callbacks.

## Iteration 1 — JLY-000 freeze blueprint and state

- Acceptance passed: `git diff --check` and all three planning/state documents are non-empty.
- The 969-line blueprint is now the implementation authority, with the FartUI source remaining the visual authority for the first morph.
- Note to future self: do not quietly weaken the ten blueprint decisions; choose conservative defaults and record them in public docs/tests.

## Iteration 2 — JLY-001 workspace foundation

- Created a Dart workspace with `packages/jelly_ui`, `packages/jelly_morph_neobrutalism`, and the web-only `apps/catalog` application.
- Selected Dart 3.5 as the minimum because workspace resolution requires it; retained Flutter 3.22 as the provisional package floor.
- Acceptance passed: `flutter pub get` resolved the workspace and `flutter analyze --no-fatal-infos` reported no issues.
- Note to future self: generated Flutter 3.44 examples use Dart dot shorthands, so avoid those while the package advertises Dart 3.5.

## Iteration 3 — JLY-002 typed design-system seam

- Implemented one data-only `JellyMorph`, exhaustive surface roles, semantic palette/type/geometry/transition tokens, deterministic state recipes, `JellyThemeData`, and local/global theme installation.
- Kept motion and feedback independent from visual morphs; morph data contains no builders, gestures, context, async work, or callbacks.
- Acceptance passed: 8 theme/morph tests plus the fatal-info analyzer.
- Note to future self: `JellyTheme.material` compiles both standard and high-contrast variants into one extension; widgets must resolve the media variant outside paint.

### META after iteration 3

- **Velocity:** 3 of 3 units completed; pace is steady, but component-family units may need internal slicing without expanding the ledger.
- **Drift:** The ledger still targets the requested Flutter conversion, morph system, performance, and browser proof.
- **Patterns:** The advertised Dart 3.5 floor catches new-language syntax early; keep full analyzer runs in every unit.
- **Regression canary:** Re-ran JLY-002's 8 tests and JLY-001's analyzer gate; both remained green.

## Iteration 4 — JLY-003 membrane physics

- Ported the rounded-rectangle membrane to preallocated structure-of-arrays buffers, including smoothed normals, pressure/area correction, neighbor coupling, bounded substeps, pointer impulses, sustained holds, directional stretch, perspective projection, and defensive recovery.
- Reduced the unmeasured web default from 240 to a provisional 144 standard samples; final quality counts remain benchmark-owned rather than API promises.
- Acceptance passed: 9 physics tests cover geometry, typed buffers, symmetry, settling, frame-rate envelopes, resize, directionality, and non-finite recovery; analyzer is clean.
- Note to future self: `computeProjectedSurface` mutates reusable buffers; painters must consume them synchronously and never retain point objects.
