# Movement Quest

A local Flutter companion for short, single-exercise workout plans and reversible set logging. CSC4360 MAD, Mon-Wed. Team CODING MASTER. Both members are undergraduates.

## Delivery status
Afeef reports that the APK runs on two devices. October 24 screenshots show plan listing/editing, negative-set validation, set progress and history/delete controls. See evidence/SCREENSHOT_EVIDENCE.md. Earlier source checks passed: 10/10 helper assertions and 9/9 host SQLite schema checks. Full Flutter analysis/test output, device-specific offline/restart results and the exact release APK are not attached to this documentation update.

## Original responsibilities
| Member | Proposal responsibility |
| --- | --- |
| Mohammed Afeefuddin (Afeef) | Lead/UI owner: wireframes, navigation, forms, settings, demo coordination; accessibility and integration review. |
| Muhammad Samad Khan (Samad) | Data owner: SQLite, CRUD, activity persistence/integrity; quality owner: helper evaluation, tests, documentation, release coordination. Afeef reviews quality gates. |

These are the existing proposal assignments, not a claim that either student independently authored this generated implementation. Individual credit comes from actual work, reviews, commits and explanations. Existing repository history is preserved. AI_Usage_Log.md records this assistance.

## Source features
- Five roles: catalog, editor, workout detail/activity, history and settings.
- Plan CRUD and linked log CRUD; SQLite foreign keys and cascading parent deletion.
- Saved draft sessions, set correction, undo, finish and draft-only reset.
- A unique draft per plan, stable session token, guarded writes and idempotent Finish.
- Equipment filtering and counts computed only from completed sessions.
- SharedPreferences theme, equipment preference and system/on/off reduced motion.
- Local rule-based suggestion, explanation, Apply, Not now and manual override.
- Three optional animations with reduced-motion handling. Text accompanies progress.
- Debug-only failure demonstration enabled with --dart-define=ENABLE_FAILURE_DEMO=true.

## Setup on Windows
Prerequisites: Flutter stable with Dart >=3.9 and Flutter >=3.35, Android SDK, accepted Android licenses, an Android device/emulator. The native Android runner is generated from your installed Flutter SDK rather than shipping an unverified Gradle wrapper. No iOS/web/desktop runner is included.

```powershell
# Open PowerShell in the extracted project root containing pubspec.yaml.
$env:Path = "D:\mad\flutter\bin;" + $env:Path
flutter doctor
powershell -ExecutionPolicy Bypass -File scripts\prepare_android.ps1
powershell -ExecutionPolicy Bypass -File scripts\verify.ps1
flutter devices
flutter run -d YOUR_ANDROID_DEVICE_ID
```

Replace YOUR_ANDROID_DEVICE_ID with the real ID from flutter devices. On macOS/Linux use bash scripts/prepare_android.sh, then flutter pub get, dart format lib test tool integration_test, flutter analyze, flutter test --coverage, and flutter run -d DEVICE_ID.

Commit pubspec.lock after successful resolution. Requested dependency ranges are in pubspec.yaml; no exact package resolution is claimed here. Record flutter --version in evidence/flutter_version.txt.

## Release and verification
```powershell
flutter test integration_test/persistence_test.dart -d YOUR_ANDROID_DEVICE_ID
powershell -ExecutionPolicy Bypass -File scripts\build_release.ps1
```
The build script runs checks and copies the APK to submission/app-release.apk. Install that actual APK on two devices/emulators and follow docs/testing/MANUAL_ACCEPTANCE.md. A successful build does not prove offline restart or usability.

## Local data and architecture
Two tables: workout_plans and training_logs. The child stores repetitions as JSON and immutable target snapshots. See docs/SCHEMA.md and ARCHITECTURE.md. Preferences use one JSON value named quest_settings_v1. There is no Firebase, cloud authentication, cloud inference, or network data service.

## Evidence and links
Repository: https://github.com/mkhan10004/Movement-Quest-Project-
ClickUp: https://sharing.clickup.com/90141780810/b/h/6-901422403415-2/13f8349006cb5fe
Required evidence file: Kanban_Contribution_Evidence.pdf (currently a partial evidence workbook; missing snapshots/traces are explicitly marked).
Oct 21 and Oct 24 are planning checkpoints. Final individual submission: Oct 28, 2026, 11:59 PM Eastern, according to the supplied course guide. Upload selected questions before recording/presenting. Verify any instructor updates.

## Known limitations
See docs/KNOWN_ISSUES.md. Complete device acceptance verification is outstanding. One exercise per plan; no export, remote sync or recommendation of training intensity. Small synthetic helper evaluation is not a user study. Past sessions use local calendar dates; editing a date stores local midnight. No retention of deleted plans/logs after confirmed cascade.

## License
All rights reserved by the respective contributors unless separately licensed. No open-source redistribution license has been selected by the team. Third-party dependencies retain their own licenses. See LICENSE.txt.
