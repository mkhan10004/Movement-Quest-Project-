# Manual acceptance checks

For EACH of two distinct Android devices/emulator configurations, record model, OS/API, resolution, text scale, orientation, app commit/build and date. Enter actual results in manual_results.csv and save real screenshots/recordings in evidence/.

| ID | Procedure | Expected result |
| --- | --- | --- |
| M01 | Fresh install; visit catalog/history/settings | Honest empty states; no invented sessions; all navigation works |
| M02 | Create, read, edit and delete a disposable plan | Exactly one correct row; confirmation before delete |
| M03 | Try blank name, sets 0/11, reps 0/101 and text | Validation; no row created |
| M04 | Create 2x10 plan; Start rapidly twice | One saved draft |
| M05 | Log 10 then 8; edit first to 9; Undo last; re-log 8 | Saved values [9,8], correct set count |
| M06 | Finish twice rapidly; revisit history | One completed row; count increases once |
| M07 | Keep a new partial draft; force-stop and relaunch | Same draft restored, completed history unchanged |
| M08 | Reset a draft; cancel first, then confirm | Cancel keeps it; confirm removes draft only |
| M09 | Add past log; edit reps/date; delete it | Full child CRUD; totals and helper re-evaluate |
| M10 | Edit plan targets after starting a session | Existing draft and completed snapshots unchanged |
| M11 | Delete plan with draft + history; cancel, then confirm | Cancel preserves all; confirm cascades all linked logs |
| M12 | Toggle theme/equipment/motion; force-stop offline | All preferences restore; helper re-ranks |
| M13 | Airplane mode; create/log/settings; close/relaunch | All saved records/settings restore with network disabled |
| M14 | Change equipment filter; add/delete history | Count matches only completed logs for displayed plans |
| M15 | Helper Apply, Not now, manual different plan | Apply does not create session; manual choice works |
| M16 | Portrait/landscape and 200% text scale | No clipped fields/actions, scroll/keyboard usable |
| M17 | Reduced motion on and TalkBack | Optional transitions suppressed; labeled controls and text progress |
| M18 | Run with failure demo; arm bug icon, save a plan | Write fails once, input remains, Retry saves one row |
| M19 | Open editor, change a field, Back | Discard confirmation; Cancel preserves editor |
| M20 | Install actual release APK on each configuration | Installs, launches and core flow works |

Failure demo: `flutter run --dart-define=ENABLE_FAILURE_DEMO=true -d DEVICE_ID`. Tap the bug icon before the desired save. The deliberate failure is labeled as a test scenario, not a historical production bug. The default release build omits the control.

The device integration test closes/reopens a SQLite connection, not the OS process. M07/M12/M13 remain necessary. Do not clear app data during the restart test.
