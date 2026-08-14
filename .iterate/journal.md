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
