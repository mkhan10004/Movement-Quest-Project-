# Movement Quest design pack

Version: proposed design baseline v1. Prepared October 18, 2026. This is a preimplementation design, not screenshots or evidence of a working app. GitHub commit/freeze is pending the team upload.

## Contents

- `wireframes/01-workout-catalog.png` — S1, default/empty/loading/error/success.
- `wireframes/02-plan-editor.png` — S2, all five states.
- `wireframes/03-workout-detail.png` — S3, all five states.
- `wireframes/04-training-history.png` — S4, all five states.
- `wireframes/05-settings.png` — S5, all five states.
- `screens.md` — exactly five required annotation fields per screen, plus shared policies.
- `navigation-map.png` — labeled boxes/arrows, S1 explicitly marked START.
- `storyboards/` — three separate PNG pages, one animation per page.
- `animation-notes.md` — text specification and reduced-motion behavior.
- `data-sketch.dart` — proposed Dart models, SQLite tables, relationship and integrity policies.
- `data-notes.md` — data boundary, Firebase not-applicable note and verification plan.
- `design-changelog.md` — baseline/future change policy.
- `manifest.json` — file inventory and checksums for the prepared pack.

## Required state interpretation

Each wireframe PNG is a large five-column sheet. Read left to right: default, empty, loading, error, success. Open at full resolution for detail. Empty settings means no saved preference keys; empty editor means a blank new form; empty workout activity means a persisted draft with zero sets. These remain distinct states of the same screen. Examples and counts are synthetic illustration. Success in the editor is transient feedback before returning, not a sixth screen.

## Freeze and later changes

Upload this `docs/design/` folder to the repository root and make an authentic commit by the required checkpoint. Record the actual commit hash/date in your team evidence; no commit/freeze has been performed by this package. Keep the baseline commit and document later revisions with reason, actual peer feedback and recheck outcome. Never backdate activity. Do not initialize/implement Flutter until the required instructor approval.

## Scope

Undergraduate core: five screen roles, two related entities with full CRUD, one start/progress/finish/reset activity, equipment filter, completed count and persistent preferences. A local explainable rule-based recommendation uses equipment/recent use and an ID-order baseline; users can ignore it. No medical or competitive claims. This pack does not implement graduate extensions or claim approval. It complements the proposal, signed acknowledgment and real ClickUp evidence; it does not replace them.
