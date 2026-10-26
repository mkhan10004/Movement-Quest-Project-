# Required local smart helper

## Question and benefit
Can an explicit equipment preference and recent completed-session history help a user select a saved plan? The card organizes existing choices. It neither prescribes exercise intensity nor predicts health, safety or ability.

Proposal owner: Muhammad Samad Khan. Mohammed Afeefuddin reviews rationale and test cases. These assignments are retained; actual individual implementation/review evidence is still required.

## Inputs and output
Input: saved plan ID and equipment category; equipment preference (none/bodyweight/dumbbell/band); completed-session timestamps as UTC milliseconds; integer per-plan counts over the previous seven days. No biometric or health inputs. Output: one plan, per-plan scores and a visible reason, or an actionable no-data/invalid message.

## Method and baseline
Deterministic hand-written ranking rules, not a trained model:
`score = 3 * exactEquipmentMatch - min(recentCompletedCount, 2)`.
No preference gives match=0 for every plan. Ties choose the lowest stable ID. The seven-day boundary is inclusive. Baseline returns the lowest plan ID regardless of history/preference.

Normal fixture: plan 1 dumbbell/0 recent => 0; plan 2 bodyweight/2 recent => 1; plan 3 bodyweight/0 recent => 3. With bodyweight preference the helper chooses 3 and baseline 1.

## Rationale and alternative
The fields already exist locally, and each result can be reproduced with arithmetic. A nearest-neighbor method using fictional labeled examples was considered; it would need example coverage and a distance threshold without offering clear benefit for this small categorical problem. Neither the input features nor the weights represent exercise suitability.

## Actual fixture evaluation
Executed directly in Dart 3.13.5 using `dart tool/evaluate_helper.dart`. Fixed synthetic clock: 2026-10-22T12:00:00Z. Full actual rows: evidence/helper_results.json. All 10 expected-output assertions passed. Cases cover normal, empty catalog, no history, invalid preference, invalid history, inclusive boundary, outside boundary, tie, penalty cap and counterexample.

Preference-label agreement on 7 valid synthetic cases: helper 6/7; baseline 4/7. Empty and invalid checks are excluded from that denominator. The labels and fixtures are hand-authored demonstrations, not held-out user evidence or population accuracy. No graduate held-out evaluation is claimed.

## Counterexample and retained limitation
With two bodyweight plans, a user may prefer the recently used plan 2, while the novelty penalty chooses plan 3. The counterexample intentionally has a correct ranking implementation and a preference-label mismatch. We retain the simple transparent scoring and a manual override rather than claiming to know the user's desired workout. Future improvement: an explicit preference for familiar versus less-recent plans, validated with new examples and peer feedback.

## Explanation and user control
The card says Suggested, not guaranteed, and explains equipment and recent count. Apply opens detail only; Start remains a separate action. Not now dismisses the card, and any plan can be chosen manually. Changing equipment in Settings re-ranks plans after persistence. A no-history message discloses lack of history. Unknown categories or malformed history suppress a suggestion without writing data.

## Remaining verification
Device interaction, dismissal/override, offline restart, and peer feedback require real Android evidence. Pure helper execution does not prove the full UI. Document the actual runs in docs/testing/manual_results.csv. AI development assistance is separately recorded in AI_Usage_Log.md.
