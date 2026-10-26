# Data sketch notes

The Dart file is a planning artifact, not production-ready CRUD. Exactly two related SQLite tables are proposed. One plan describes one exercise with target sets/repetitions. One log describes one draft or completed session; actual set repetitions are an ordered JSON value list.

SQLite owns records; SharedPreferences owns simple settings. All timestamps use UTC epoch milliseconds. Foreign keys are enabled on every open. Confirmed parent deletion cascades; reset deletes only the active draft. Historical target snapshots preserve what was planned at session start. One session token and one-draft-per-plan index guard duplicates. Full read/write mapping, error handling and migrations must be implemented and tested after approval.

## Firebase schema note

Not applicable. Movement Quest uses no Firebase, remote authentication or remote sync. This follows the supplied local-only project requirements.

## Proposed verification

Exercise the database constraints and the Dart-side JSON/completion checks. Check malformed rows, invalid targets, repeated finish, parent cascade and cancel behavior, offline restart, corrupt JSON recovery and count refresh. The design pack does not assert that an app or runtime tests already exist.