# 23-minute presentation and code explanation guide

Rehearse and replace pending evidence with actual results before recording. Every member explains their real work.

## 1. Movement Quest

0:00–1:00. Both introduce themselves. Explain the app purpose: one exercise per plan, recording actual sets, no medical or competitive claims. Proposal approval must be verified before describing it as approved.

## 2. Scope and original roles

1:00–2:00. State original proposal responsibilities, not invented completed contributions. Afeef reviews accessibility/integration and helper reasoning. Samad coordinates quality. Explain that individual evidence appears later.

## 3. Catalog and plan editor

2:00–4:30. Afeef demonstrates catalog then create/edit form. I1: compare StatelessWidget PlanCard in widgets/common.dart with StatefulWidget PlanEditor. build renders current state; expansion state belongs to CatalogScreen. I2: trace the intensity Slider callback to setState, then Save to WorkoutPlan and repository. Explain target versus actual reps. Show invalid name and numeric bounds.

## 4. Saved workout progress

4:30–7:00. Samad demonstrates Start, repeated tap guard, logging, correction, Undo, Finish and Reset. Show start/saveSet/finish/reset in quest_repository.dart. Explain transaction, expected list length, unique draft index and stable token. Demonstrate both confirmed and cancelled reset or delete. Finish twice must leave one completed session.

## 5. History and offline settings

7:00–9:00. Samad demonstrates child CRUD and cascade policy for D1. Afeef changes theme/equipment/motion and performs the actual offline restart for D2. Explain SQLite relationship data versus the small SharedPreferences object. GitHub/ClickUp/YouTube are coordination/submission tools, not runtime app backends. Do not claim restart success before demonstrating it.

## 6. State and lifecycle

9:00–11:00. Afeef answers A1 by tracing editor Save through controller.write to repository.savePlan and refresh. A2: show controller disposal in editor/detail, mounted checks after awaits, no timer dependency and root repository ownership. Samad explains close/reopen semantics. Demonstrate leaving a screen before a read finishes where feasible.

## 7. Explainable local helper

11:00–13:00. Samad shows services/plan_helper.dart and input categories/count timestamps. Counts cover the preceding seven days inclusively and cap at two. Ties use lowest ID. Demonstrate reason text, Not now and manual override. Afeef explains how equipment preference changes the next ranking. Label the method rule-based, not trained ML.

## 8. Helper evaluation

13:00–14:30. Samad opens evidence/helper_results.json and tool/helper_fixtures.dart. The evaluator ran in Dart 3.13.5. The 7 valid labels exclude 3 empty/invalid cases. A user may prefer a recent plan, so the convenience ranking mismatches that label. Explain nearest-neighbor alternative and retained limitation. This is not held-out testing, population accuracy or health evidence.

## 9. Tests and failure recovery

14:30–17:00. Samad answers T1 using manual acceptance matrix and actual run outputs when available. Host SQL checks do not run Dart repository or native plugins. Show two actual device configurations after testing. T2: run --dart-define=ENABLE_FAILURE_DEMO=true, arm bug icon, save a plan, observe retained input and retry. Describe this as deliberately tested failure, not an invented historical bug. Update this slide with real Flutter/device results before final recording.

## 10. Accessibility and design review

17:00–19:00. Afeef shows enlarged text, landscape, keyboard access and reduced motion on the actual app. Compare a genuine before/after design revision after a peer review. Use docs/PEER_REVIEW.md. No fabricated observation is allowed; update this slide when the review has actually happened.

## 11. Individual task evidence

19:00–21:30. Each member answers R1 with their real feature branch/PR/commit and review. Show task owner, acceptance criteria, exact code and test outcome. Include the four dated snapshots and one measured flow improvement. Do not claim generated files prove independent authorship. Refer to AI_Usage_Log.md for assistance.

## 12. Release and reflection

21:30–23:00. Each member summarizes one real learning experience and a next improvement. Check all selected IDs I1/I2/A1/A2/D1/D2/T1/T2/R1/R4 have been answered in the recording. The final package needs approved proposal, signed acknowledgment, final report, evidence, tested APK and accessible video. Keep total recording 20–25 minutes.
