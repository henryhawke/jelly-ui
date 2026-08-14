# Jelly Flutter conversion ledger

Objective: replace Jelly UI's public product surface with a production-quality Flutter package, preserve the soft-body interaction, ship a typed morph seam with the FartUI neobrutalist Instrument morph, and verify the catalog in a browser.

- [done] JLY-000 — Freeze blueprint and iteration state | acceptance: `git diff --check && test -s docs/FLUTTER_BLUEPRINT.md && test -s .iterate/ledger.md && test -s .iterate/journal.md` | evidence: passed 2026-08-14; blueprint, ledger, and journal present; diff check clean
- [done] JLY-001 — Create Dart workspace, Flutter package, morph package, and web catalog | acceptance: `flutter pub get && flutter analyze --no-fatal-infos` | evidence: passed 2026-08-14; workspace resolved 26 dependencies and analyzer reported no issues
- [done] JLY-002 — Implement typed theme, token, recipe, morph, motion, and feedback contracts | acceptance: `flutter test packages/jelly_ui/test/theme` | evidence: 8 tests passed 2026-08-14; fatal-info analyzer clean
- [done] JLY-003 — Port deterministic allocation-conscious membrane physics | acceptance: `flutter test packages/jelly_ui/test/physics` | evidence: 9 tests passed 2026-08-14; 60/90/120 Hz envelope and analyzer clean
- [done] JLY-004 — Implement shared parked scheduler, surface controller, painter, and JellySurface | acceptance: `flutter test packages/jelly_ui/test/rendering packages/jelly_ui/test/motion` | evidence: 7 tests passed 2026-08-14; shared parking, mutation safety, reduced motion, repaint isolation, and analyzer clean
- [done] JLY-005 — Implement display and action components | acceptance: `flutter test packages/jelly_ui/test/components/display_action_test.dart` | evidence: 6 tests passed 2026-08-14; actions, display primitives, semantics, keyboard, press timing, and analyzer clean
- [todo] JLY-006 — Implement choice components | acceptance: `flutter test packages/jelly_ui/test/components/choice_test.dart` | evidence: pending
- [todo] JLY-007 — Implement fields and value controls | acceptance: `flutter test packages/jelly_ui/test/components/fields_test.dart` | evidence: pending
- [todo] JLY-008 — Implement disclosure and layout components | acceptance: `flutter test packages/jelly_ui/test/components/disclosure_layout_test.dart` | evidence: pending
- [todo] JLY-009 — Implement feedback, overlay, and navigation components | acceptance: `flutter test packages/jelly_ui/test/components/feedback_overlay_navigation_test.dart` | evidence: pending
- [todo] JLY-010 — Implement exact neobrutalist Instrument morph package | acceptance: `flutter test packages/jelly_morph_neobrutalism/test` | evidence: pending
- [todo] JLY-011 — Build complete interactive catalog and legacy-family coverage gate | acceptance: `flutter test apps/catalog/test && flutter build web --release --target lib/main.dart --web-renderer canvaskit` | evidence: pending
- [todo] JLY-012 — Complete accessibility, reduced-motion, semantics, and contract test matrix | acceptance: `flutter test packages/jelly_ui/test/accessibility packages/jelly_ui/test/contracts` | evidence: pending
- [todo] JLY-013 — Add performance contracts and benchmark harness | acceptance: `flutter test packages/jelly_ui/benchmark packages/jelly_ui/test/performance` | evidence: pending
- [todo] JLY-014 — Run full quality gate and interactively test the release catalog in browser | acceptance: `dart format --output=none --set-exit-if-changed . && flutter analyze --fatal-infos && flutter test && flutter build web --release --target lib/main.dart --web-renderer canvaskit` plus browser interaction receipt | evidence: pending
