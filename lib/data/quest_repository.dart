import 'dart:convert';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/workout.dart';

/// Educational reconstruction. Not an authentic historical Git revision.
class QuestRepository {
  final Database db;
  final int Function() clock;
  bool rejectNextWrite = false;

  QuestRepository(this.db, {int Function()? clock})
    : clock = clock ?? (() => DateTime.now().millisecondsSinceEpoch);

  static Future<QuestRepository> open() async => QuestRepository(
    await openDatabase(
      p.join(await getDatabasesPath(), 'movement_quest.db'),
      version: 1,
      onCreate: createSchema,
    ),
  );

  static Future<void> createSchema(Database db, int version) async {
    await db.execute('''CREATE TABLE workout_plans (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL CHECK(length(trim(name)) BETWEEN 1 AND 80),
      exercise_key TEXT NOT NULL CHECK(exercise_key IN ('squat','push_up','row','press','curl')),
      equipment TEXT NOT NULL CHECK(equipment IN ('bodyweight','dumbbell','band')),
      target_sets INTEGER NOT NULL CHECK(target_sets BETWEEN 1 AND 10),
      target_reps INTEGER NOT NULL CHECK(target_reps BETWEEN 1 AND 100),
      intensity INTEGER NOT NULL CHECK(intensity BETWEEN 1 AND 5),
      created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL)''');

    await db.execute(
      '''CREATE TABLE training_logs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      plan_id INTEGER NOT NULL REFERENCES workout_plans(id) ON DELETE CASCADE,
      session_token TEXT NOT NULL UNIQUE,
      status TEXT NOT NULL CHECK(status IN ('draft','completed')),
      started_at INTEGER NOT NULL,
      completed_at INTEGER,
      target_sets_snapshot INTEGER NOT NULL CHECK(target_sets_snapshot BETWEEN 1 AND 10),
      target_reps_snapshot INTEGER NOT NULL CHECK(target_reps_snapshot BETWEEN 1 AND 100),
      exercise_name_snapshot TEXT NOT NULL,
      actual_sets_json TEXT NOT NULL,
      CHECK((status='draft' AND completed_at IS NULL) OR
        (status='completed' AND completed_at IS NOT NULL AND completed_at>=started_at)))''',
    );

    await db.execute('CREATE INDEX logs_plan ON training_logs(plan_id)');

    await db.execute(
      "CREATE UNIQUE INDEX one_draft_per_plan ON training_logs(plan_id) WHERE status='draft'",
    );
  }

  Future<void> close() => db.close();
}
