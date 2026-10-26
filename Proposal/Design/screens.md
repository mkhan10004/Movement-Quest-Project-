# Movement Quest screen annotations

Design baseline v1 · prepared October 18, 2026. All five state views are planned UI, not implementation evidence. Five-field template: purpose, entry, primary act, data, states.

## S1 Workout catalog

### Purpose
Help users browse saved plans, filter by equipment, see completed-session counts and choose a next plan.

### Entry
App launch is the start screen. Catalog tab from S4/S5 and successful creation/cancellation from S2 return here. Preserve filter when returning.

### Primary act
Add opens S2; tapping a card or its Open button opens S3. Edit opens S2 with its ID. Expand/Collapse reveals optional details. Suggestion Apply opens S3 without starting; Not now dismisses it.

### Data
Read WorkoutPlan and completed TrainingLog rows from SQLite. Selected equipment filter is screen state; equipment preference is in SharedPreferences. Count only completed sessions for displayed plans. Rule score = 3 * exact equipment match - min(completions in last 7 days, 2), ties lowest plan ID. No preference gives match=0. Baseline is lowest ID. Invalid data suppresses the suggestion with an explanation. No health input or trained model.

### States
Default: stored list/filter/count/helper. Empty: zero plans with Create action; filtered empty offers Clear filter. Loading: placeholders and unknown count, no fabricated zero. Error: read error with Retry and unchanged records. Success: saved-plan feedback with refreshed row. No history gives zero recent counts and an honest helper explanation.

## S2 Plan editor

### Purpose
Create or update one single-exercise plan with clear, bounded targets.

### Entry
S1 Add opens an empty new form; S1 Edit or S3 Edit opens existing values by plan ID. A new plan is not persisted until Save.

### Primary act
Save validates then inserts/updates; disable repeated Save while pending. Success returns to S1 for new plans or S3 for edits. Cancel/back with unsaved changes asks Keep editing or Discard. During a pending write, retain the form until its outcome is known.

### Data
SQLite WorkoutPlan fields: name, exercise key, equipment, target sets 1-10, target repetitions 1-100, self-selected intensity 1-5. Exercise comes from a small bundled list. Name trimmed and nonempty. Form draft/saving/errors owned by StatefulWidget. Editing a plan never rewrites historical target snapshots.

### States
Default: populated valid edit form. Empty: first-use blank form with labels and disabled Save until complete. Loading: pending save with preserved inputs. Error: inline invalid-repetition message or write failure with retained values and Retry. Success: brief Plan saved feedback before return, not an extra screen.

## S3 Workout detail

### Purpose
Show one plan and support start, set logging, correction, completion and reset without losing draft progress.

### Entry
S1 Open/Apply or S2 saved edit. Load by plan ID. If the plan no longer exists, show missing-plan feedback and Return to catalog.

### Primary act
Start creates or resumes one persisted draft. Log updates a set position; Edit/Undo corrects it. Finish requires all target sets and changes the same row to completed. Reset confirms deletion of only the active draft. Delete plan confirms cascade consequences. Back with a draft offers Keep and leave, Discard and leave, or Stay.

### Data
Read WorkoutPlan; create/read/update/delete linked draft TrainingLog. Snapshot targets at Start; store actual sets as validated JSON. Unique session token and one-draft-per-plan index prevent duplicate sessions. Pending actions are disabled; transactions preserve integrity. Finish is idempotent for the same session token. Completed log corrections happen on S4.

### States
Default: idle plan with Start. Empty: started draft with zero logged sets and first numeric entry. Loading: saving a set with old progress until committed. Error: preserve unsaved set and offer Retry without incrementing. Success: completed summary and View history, based on saved status. Undo/reset cancels completion transitions; no success is announced before write acknowledgment.

## S4 Training history

### Purpose
Review, manually add, correct and delete past training sessions and see an accurate completed count.

### Entry
History tab from S1/S5 or View history from S3 (filtered to that plan). Return via Catalog tab or back to the originating detail screen.

### Primary act
Add log opens a dialog selecting an existing plan, date and actual reps. Edit changes that log by ID; Delete confirms before removal. Save validates and refreshes history/count/helper inputs; Cancel discards only dialog edits.

### Data
Full TrainingLog CRUD with required parent plan ID. Manual completed logs snapshot the current plan targets and require all planned sets. ISO date input converts to UTC milliseconds; reject an invalid/future session date. Completed count excludes drafts; editing repetitions does not increase session count. Deleted parent records cannot be selected.

### States
Default: completed entries with Edit/Delete. Empty: no completed sessions, zero count and Add log; if no plan exists, direct users to S1 Create first. Loading: records and count pending. Error: failed correction keeps dialog values and offers Retry; failed delete keeps row. Success: refreshed corrected row and confirmation; count recalculates after add/delete.

## S5 Settings

### Purpose
Let users control theme, equipment preference and reduced motion with persistent local values.

### Entry
Settings tab from catalog/history. Catalog tab returns S1; history tab returns S4. No login or network step.

### Primary act
Change dropdown/switch to persist the chosen setting. On success keep the new choice; on failure revert the visible value to the last saved value and offer Retry. Changing equipment re-ranks suggestions without selecting or starting a workout.

### Data
SharedPreferences keys: theme_mode (system/light/dark), equipment_preference (none/bodyweight/dumbbell/band), reduced_motion (system/on/off). Absent keys use defaults. This tri-state motion preference can use a dropdown; the wireframe switch depicts the explicit on/off override. SQLite records are never stored in preference keys.

### States
Default: loaded saved preferences. Empty: no preference keys, display System / No preference / Follow device defaults. Loading: disable controls until saved values are read. Error: rollback and retry, no record loss. Success: Preferences saved and verified restoration planned for restart tests.

## Shared behavior and accessibility

Use readable contrast, text labels and 48 logical-pixel targets. Numeric fields show units and validate whole numbers. Support portrait/landscape, scrolling, keyboard insets and large text without clipping. Use textual progress, semantic labels, accessible status announcements and focus on the first invalid field. Respect effective reduced motion from the device unless explicitly overridden. Card taps have Open button alternatives. Controllers/listeners are disposed; async UI updates check mounted state.

## Parent deletion and session integrity

Plan deletion always requires confirmation of cascading deletion of its logs. Cancel leaves all data unchanged. Reset removes only the active draft, never completed sessions. All dependent lists, counts and helper inputs refresh after committed edits/deletes. Writes use parameters, transactions and unique tokens; failed writes retain usable input. Navigation dialogs are subordinate to five screen roles, not extra core screens.

## Design verification plan

After approval, verify each of the 25 drawn states, both entities’ CRUD, rapid double taps, cascade/cancel, draft restart, helper baseline/five case types, persistence failures, offline restart and two device configurations. Ask a peer to trace create/log/correct/delete/cancel/settings tasks, record actual observation, revise, and recheck. No peer result or passed test is asserted here.
