# SQLite schema and local settings

Database: movement_quest.db, version 1. Source of truth: SQLite. No Firebase schema applies.

## workout_plans
id INTEGER primary key/autoincrement; name TEXT trimmed length 1-80; exercise_key in squat/push_up/row/press/curl; equipment in bodyweight/dumbbell/band; target_sets 1-10; target_reps 1-100; intensity 1-5; created_at and updated_at UTC epoch milliseconds.

## training_logs
id INTEGER primary key/autoincrement; plan_id required foreign key to workout_plans with ON DELETE CASCADE; session_token TEXT unique; status draft/completed; started_at UTC epoch milliseconds; completed_at nullable until completed; target_sets_snapshot 1-10; target_reps_snapshot 1-100; exercise_name_snapshot TEXT; actual_sets_json ordered integer list.

CHECK enforces status/date consistency. A normal plan_id index supports related reads; a partial unique index on plan_id WHERE status='draft' enforces one active draft per plan. PRAGMA foreign_keys=ON runs for every connection. SQL writes use bound values.

JSON syntax, integer reps 1-100, maximum list length and exact completion length are checked in Dart. SQL deliberately does not require platform-specific JSON extensions. Manual history dates must be nonfuture and nonnegative. Catalog counts derive only from completed rows in the current visible-plan set. Seven-day helper counts use completed_at inclusive of the boundary and exclude future records.

## Settings
SharedPreferencesAsync stores quest_settings_v1 as one JSON object: theme=system/light/dark, equipment=none/bodyweight/dumbbell/band, motion=system/on/off. System motion reads the device accessibility setting. No app-user data leaves the device.

## Schema evolution plan
Version 1 is the first implementation schema, so no destructive upgrade handler is installed. Future changes must increment the database version, migrate transactionally, preserve log IDs/tokens/snapshots and test old-version fixtures. Never delete the database simply to make an upgrade succeed.
