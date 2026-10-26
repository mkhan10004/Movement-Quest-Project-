# Start here: Movement Quest implementation handoff

## 1. Keep the existing team repository
Do not replace .git or rewrite commits. Extract this ZIP into a separate folder first. Compare it with your current clone. The repository inspected for this handoff had only proposal design assets at commit 0df86c50d4ae37bd5d328b30a36c1d26c8f00535. If you or Samad have newer/unpushed code, merge deliberately rather than overwriting it.

The ZIP contains Proposal/Design unchanged plus a complete docs/design copy. No commits or pushes were made by the assistant. The original proposal ownership remains in CONTRIBUTIONS.md.

## 2. Generate the Android runner and run checks
From the folder with pubspec.yaml, run scripts/prepare_android.ps1, then scripts/verify.ps1 as explained in README.md. These scripts use your installed Flutter. The prepare script refuses to overwrite an existing android/ folder.

## 3. Run and test on Android
Create a 2-set, 10-rep plan; log 10 then 8 reps; edit the first set to 9; finish; verify history shows [9,8]. Add/edit/delete a past session. Keep a draft, close the app and reopen offline. Change settings and reopen. Use the full manual checklist on two configurations.

## 4. Preserve credit
Afeef reviews and integrates the UI/form/navigation/settings files. Samad reviews and integrates data/helper/tests/documentation. Review each other's changes and record real task/PR/test references. This assignment follows the proposal. Generated files alone are not evidence of either person's completed work.

## 5. October 24 checkpoint
Run core CRUD/activity/helper checks. Update real ClickUp tasks, owners, statuses and evidence. Capture a genuine Oct 24 board snapshot and detailed task views. Record defects as open. Do not reconstruct a missing Oct 21 snapshot as if captured then.

## 6. Final submission after verification
Use docs/FINAL_SUBMISSION_CHECKLIST.md. submission/ contains a staging set of generated documents, not a complete final ZIP. Add the installed/tested APK, approved proposal proof, real signed official acknowledgment, completed Kanban evidence, two-device results, and accessible YouTube link. Every member uploads their own final package to iCollege by the course deadline.

## What has actually run here
Dart 3.13.5 formatter and helper evaluator; 10 helper assertions passed. Nine host SQLite schema checks passed. Syntax parsing passed. Full Flutter analyzer/tests, Android build and device checks have not run. See evidence/ and docs/testing/TEST_STATUS.md.
