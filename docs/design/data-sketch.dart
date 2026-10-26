// Movement Quest: design-only Dart/SQLite sketch, not an app implementation.
// SQLite is the source of truth. No Firebase / remote sync is used.
// Schema version 1 is proposed for a new database after instructor approval.
// Execute each CREATE statement separately using sqflite onCreate.
import 'dart:convert';

enum LogStatus { draft, completed }

class WorkoutPlan {
  final int? id; // null only for an unsaved draft model
  final String name, exerciseKey, equipment;
  final int targetSets, targetReps, intensity, createdAtMs, updatedAtMs;
  const WorkoutPlan({this.id, required this.name, required this.exerciseKey,
    required this.equipment, required this.targetSets, required this.targetReps,
    required this.intensity, required this.createdAtMs, required this.updatedAtMs});
  Map<String, Object?> toRow() => {
    if (id != null) 'id': id, 'name': name.trim(), 'exercise_key': exerciseKey,
    'equipment': equipment, 'target_sets': targetSets, 'target_reps': targetReps,
    'intensity': intensity, 'created_at_ms': createdAtMs, 'updated_at_ms': updatedAtMs,
  };
}

class TrainingLog {
  final int? id;
  final int planId, startedAtMs, targetSetsSnapshot, targetRepsSnapshot;
  final int? completedAtMs;
  final String sessionToken, exerciseNameSnapshot;
  final LogStatus status;
  // Example: [10, 8] means actual reps for set positions 1 and 2.
  // Undo truncates/removes a set and restores the appropriate draft state.
  // Never count the length of this list as the number of sessions.
  final List<int> actualSets;
  const TrainingLog({this.id, required this.planId, required this.sessionToken,
    required this.status, required this.startedAtMs, this.completedAtMs,
    required this.targetSetsSnapshot, required this.targetRepsSnapshot,
    required this.exerciseNameSnapshot, required this.actualSets});
  Map<String, Object?> toRow() => {
    if (id != null) 'id': id, 'plan_id': planId, 'session_token': sessionToken,
    'status': status.name, 'started_at_ms': startedAtMs,
    'completed_at_ms': completedAtMs, 'target_sets_snapshot': targetSetsSnapshot,
    'target_reps_snapshot': targetRepsSnapshot,
    'exercise_name_snapshot': exerciseNameSnapshot,
    'actual_sets_json': jsonEncode(actualSets),
  };
}

const proposedSchema = r'''
CREATE TABLE workout_plans (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL CHECK(length(trim(name)) > 0),
  exercise_key TEXT NOT NULL,
  equipment TEXT NOT NULL CHECK(equipment IN ('bodyweight','dumbbell','band')),
  target_sets INTEGER NOT NULL CHECK(target_sets BETWEEN 1 AND 10),
  target_reps INTEGER NOT NULL CHECK(target_reps BETWEEN 1 AND 100),
  intensity INTEGER NOT NULL CHECK(intensity BETWEEN 1 AND 5),
  created_at_ms INTEGER NOT NULL,
  updated_at_ms INTEGER NOT NULL
);
CREATE TABLE training_logs (
  id INTEGER PRIMARY KEY,
  plan_id INTEGER NOT NULL REFERENCES workout_plans(id) ON DELETE CASCADE,
  session_token TEXT NOT NULL UNIQUE,
  status TEXT NOT NULL CHECK(status IN ('draft','completed')),
  started_at_ms INTEGER NOT NULL,
  completed_at_ms INTEGER,
  target_sets_snapshot INTEGER NOT NULL CHECK(target_sets_snapshot BETWEEN 1 AND 10),
  target_reps_snapshot INTEGER NOT NULL CHECK(target_reps_snapshot BETWEEN 1 AND 100),
  exercise_name_snapshot TEXT NOT NULL,
  actual_sets_json TEXT NOT NULL DEFAULT '[]',
  CHECK((status = 'draft' AND completed_at_ms IS NULL) OR
        (status = 'completed' AND completed_at_ms IS NOT NULL AND completed_at_ms >= started_at_ms))
);
CREATE INDEX idx_training_logs_plan_id ON training_logs(plan_id);
CREATE UNIQUE INDEX idx_one_draft_per_plan ON training_logs(plan_id) WHERE status = 'draft';
''';

// Connection policy: enable PRAGMA foreign_keys = ON in onConfigure on EVERY open.
// Use placeholders/whereArgs for data values; never interpolate form values.
// Relationship: WorkoutPlan 1 -> many TrainingLogs. Exactly two domain tables.
// actual_sets_json is an ordered value list within a log, not a third entity.
// Service validation (proposed, enforced before writes):
// - Exercise key exists in bundled list; name is trimmed/nonempty.
// - Validate whole-number targets and actual reps 1..100.
// - actualSets.length <= targetSetsSnapshot; completed requires exact equality.
// - Parse JSON defensively; reject corrupt data with recoverable UI feedback.
// - Completed dates must be valid and not future relative to a testable clock.
// - Keep actualSets immutable in production (copy/list.unmodifiable).
// - Keep historical target snapshots when a plan is edited.
// Transaction policy:
// - Start: find existing draft for plan, otherwise insert once with stable token.
// - Save set: replace the same row/position; advance only after commit.
// - Finish: UPDATE existing row WHERE session_token = ? AND status = 'draft'.
//   A repeat tap reads the existing completed result, not a new insertion.
// - Reset: confirmed DELETE of active draft only; completed logs are preserved.
// - Plan delete: confirm cascade consequences before DELETE WHERE id = ?.
// - History correction: UPDATE by log ID, then refresh derived reads.
// Aggregate: SELECT COUNT(*) FROM training_logs WHERE status = 'completed';
// Include joined plan/filter predicates when displaying filtered counts.
// Index/UNIQUE handling: after a constraint race, re-read the existing draft.
// SharedPreferences only: theme_mode, equipment_preference, reduced_motion.
// Firebase schema note: NOT APPLICABLE. No cloud storage/auth/inference or sync.
// GitHub and ClickUp coordinate coursework; they never store runtime user data.
