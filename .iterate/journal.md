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

## Iteration 5 — JLY-004 rendering runtime

- Added one process-wide scheduler using a mutation-safe identity set; it requests one frame for all active surfaces and fully parks when the last body settles.
- Added `JellySurfaceController`, reduced/none motion branches, a reusable cubic-path painter, deformed zero-blur shadow, external focus treatment, and repaint-isolated `JellySurface`.
- Proved controller notifications repaint the painter without rebuilding the stable child subtree.
- Acceptance passed: 7 motion/rendering tests and a fatal-info analyzer run.
- Note to future self: public widgets should feed centered local coordinates into their controller and use Flutter semantics/focus outside the painter.

## Iteration 6 — JLY-005 display and actions

- Implemented Jelly button, icon button, card, badge, chip, divider, label, keyboard key, and alert on the shared surface.
- Added one focus/keyboard/pointer/semantics interaction wrapper with instant press state, stable loading dimensions, disabled behavior, and centered physics coordinates.
- Acceptance passed: 6 focused tests and fatal-info analysis; the JLY-004 motion/rendering canary also remained at 7 passing tests.
- Note to future self: display-only chips must not masquerade as disabled buttons; the implementation branches to a non-interactive surface when no callback exists.

### META after iteration 6

- **Velocity:** 6 of 6 units completed; component-family velocity is holding after the foundation investment.
- **Drift:** All new UI is generic Jelly; no Fart With Friends app vocabulary or shell behavior leaked into the package.
- **Patterns:** Semantics actions disappear if child gesture semantics are excluded without an explicit `Semantics.onTap`; keep semantic ownership at the wrapper.
- **Regression canary:** JLY-004 motion/rendering suite remained 7/7 after the component wrapper began consuming it.

## Iteration 7 — JLY-006 controlled choices

- Added controlled checkbox, radio/radio-group, switch, and typed segmented controls with 48dp targets, keyboard activation, merged label semantics, and native checked/toggled flags.
- Separated visual selection from semantic selection so checkbox/radio/switch do not incorrectly announce themselves as selected list items.
- Acceptance passed: 6 focused choice tests and fatal-info analysis.
- Note to future self: `MergeSemantics` still needs explicit exclusion when a custom semantic label and a visible text label coexist, otherwise assistive technology can receive duplicate names.

## Iteration 8 — JLY-007 native fields and values

- Added text field, text area, one-time-code field, typed select, slider, and range slider APIs.
- Kept Flutter's native `TextField`, dropdown, slider, and range-slider engines for IME, autofill, keyboard navigation, selection, semantics, and platform bug fixes; Jelly owns the surrounding surface and token styling.
- Acceptance passed: 6 focused tests, fatal-info analysis, and the choice-control canary.
- Note to future self: do not replace `EditableText` merely to draw custom slots; a visual flourish is not worth regressing composition input, autofill, cursor movement, or screen readers.

## Iteration 9 — JLY-008 disclosure and layout

- Added controlled collapsible, accordion, typed tabs, and horizontal/vertical resizable split layout.
- Expansion and tab transitions honor reduced motion; maintained disclosure children retain state; resize handles expose slider semantics, mouse cursors, drag input, and RTL-aware horizontal deltas.
- Acceptance passed: 5 focused tests and fatal-info analysis.
- Note to future self: preserving a child means keeping it under a stable element such as `Visibility`; swapping between unrelated wrapper types silently discards state even if both branches render the same child.

### META after iteration 9

- **Velocity:** 9 of 9 units completed; the broad family units remain testable because controlled-state primitives are reused.
- **Drift:** The implementation still follows the blueprint's data-only morph seam and native-behavior rule; no app-specific behavior has entered core.
- **Patterns:** Flutter-native interaction engines plus Jelly surface composition are producing smaller, more accessible APIs than custom render-object replacements.
- **Regression canary:** Choice controls stayed 6/6 after field integration, and disclosure/layout passed 5/5 after correcting maintained-state element identity.

## Iteration 10 — JLY-009 feedback, overlays, and navigation

- Added skeleton, spinner, determinate progress, dialog, drawer, typed menu, controlled popover, toast, tooltip, breadcrumbs, and controlled pagination.
- Skeletons share one repaint-only clock that parks with no listeners; overlays retain Flutter routes, portals, focus behavior, back dismissal, and Scaffold integration.
- Added a solid/quiet button variant needed by pagination without leaking visual recipes into widget callers.
- Acceptance passed: 8 focused tests, fatal-info analysis, and 11 display/disclosure regression tests.
- Note to future self: `Semantics(scopesRoute: true)` requires `explicitChildNodes: true`; route semantics are stricter than ordinary container semantics because ownership must be unambiguous.

## Iteration 11 — JLY-010 exact Instrument morph

- Re-read the canonical FartUI token source, typography facade, visual rules, and six-state interaction law before translating the morph.
- Shipped the exact nine opaque colors, 3px default borders, 12/16/24 radii, 4/5/6px zero-blur depth tiers, +1px pressed sink, bone/no-shadow disabled state, FartUI timing curves, and the same printed theme in all brightness modes.
- Bundled the canonical Archivo width/weight and Public Sans weight variable fonts with SIL OFL 1.1 notices; every Archivo role carries `wdth` 125 and numerals use tabular figures.
- Extended the generic palette seam with two-tone focus data so dark fills can use paper while light fills use ink without the core knowing any morph id.
- Acceptance passed: 6 morph tests, 11 core theme/render regression tests, binary font inspection, and fatal-info analysis.
- Note to future self: one focus color is insufficient for a bright nine-token system; the right abstraction is a contrast pair resolved from effective fill, not a hard-coded exception for one morph.

## Iteration 12 — JLY-011 complete web catalog

- Replaced the generated counter with a responsive, interactive Instrument catalog exercising actions, display, choices, fields, values, loading, disclosure, layout, navigation, and overlays.
- Added an exact 38-family registry/coverage gate and widget tests for mounting, controlled state, scrolling, and native dialog routes.
- The full catalog exposed a shared-clock lifecycle defect: identity-tracked method tear-offs were removed with new closure objects. Skeleton state now owns a stable listener identity, unregisters on disposal, and cancels the pending frame when the final listener leaves.
- Acceptance passed: 4 catalog tests, fatal-info analysis, and a release web build; Flutter's Wasm compatibility dry run also succeeded.
- Note to future self: a shared scheduler is only truly parked if it cancels the already-queued callback when its last consumer disappears; “the next tick will notice” still leaks a transient frame into teardown.

### META after iteration 12

- **Velocity:** 12 of 12 units completed; all requested component families and the first morph now exist, leaving cross-cutting gates rather than feature construction.
- **Drift:** The catalog demonstrates generic Jelly APIs under FartUI appearance without importing FWF product shell or vocabulary into core.
- **Patterns:** Mounting the whole design system in one page catches lifecycle and continuous-animation defects that isolated component tests miss.
- **Regression canary:** Catalog state, overlay routes, analyzer, and release compilation remain green after the loading-clock lifecycle repair.
