import 'dart:convert';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/workout.dart';

/// Owns the connection. Widgets never open or close database handles.
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
      onConfigure: configure,
      onCreate: createSchema,
    ),
  );

  static Future<void> configure(Database db) =>
      db.execute('PRAGMA foreign_keys = ON');
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
      started_at INTEGER NOT NULL, completed_at INTEGER,
      target_sets_snapshot INTEGER NOT NULL CHECK(target_sets_snapshot BETWEEN 1 AND 10),
      target_reps_snapshot INTEGER NOT NULL CHECK(target_reps_snapshot BETWEEN 1 AND 100),
      exercise_name_snapshot TEXT NOT NULL, actual_sets_json TEXT NOT NULL,
      CHECK((status='draft' AND completed_at IS NULL) OR
        (status='completed' AND completed_at IS NOT NULL AND completed_at>=started_at)))''',
    );
    await db.execute('CREATE INDEX logs_plan ON training_logs(plan_id)');
    await db.execute(
      "CREATE UNIQUE INDEX one_draft_per_plan ON training_logs(plan_id) WHERE status='draft'",
    );
  }

  void _beforeWrite() {
    if (rejectNextWrite) {
      rejectNextWrite = false;
      throw StateError(
        'Demonstration write rejected. Your values are retained; retry.',
      );
    }
  }

  String _token() =>
      '${clock()}-${Random.secure().nextInt(1 << 32)}-${Random.secure().nextInt(1 << 32)}';
  Future<List<WorkoutPlan>> plans() async => (await db.query(
    'workout_plans',
    orderBy: 'id',
  )).map(WorkoutPlan.fromMap).toList();
  Future<List<TrainingLog>> logs() async => (await db.query(
    'training_logs',
    orderBy: 'started_at DESC, id DESC',
  )).map(TrainingLog.fromMap).toList();
  Future<int> savePlan(WorkoutPlan plan) async {
    plan.validate();
    _beforeWrite();
    if (plan.id == null) return db.insert('workout_plans', plan.toMap());
    final n = await db.update(
      'workout_plans',
      plan.toMap(),
      where: 'id=?',
      whereArgs: [plan.id],
    );
    if (n != 1) throw StateError('This plan no longer exists.');
    return plan.id!;
  }

  Future<void> deletePlan(int id) async {
    _beforeWrite();
    await db.transaction((tx) async {
      await tx.delete('workout_plans', where: 'id=?', whereArgs: [id]);
    });
  }

  Future<TrainingLog> _log(DatabaseExecutor tx, int id) async {
    final rows = await tx.query(
      'training_logs',
      where: 'id=?',
      whereArgs: [id],
    );
    if (rows.isEmpty)
      throw StateError('Session no longer exists. Refresh and try again.');
    return TrainingLog.fromMap(rows.single);
  }

  Future<WorkoutPlan> _plan(DatabaseExecutor tx, int id) async {
    final rows = await tx.query(
      'workout_plans',
      where: 'id=?',
      whereArgs: [id],
    );
    if (rows.isEmpty) throw StateError('Plan no longer exists.');
    return WorkoutPlan.fromMap(rows.single);
  }

  Future<TrainingLog> start(int planId) async {
    _beforeWrite();
    return db.transaction((tx) async {
      final existing = await tx.query(
        'training_logs',
        where: "plan_id=? AND status='draft'",
        whereArgs: [planId],
      );
      if (existing.isNotEmpty) return TrainingLog.fromMap(existing.single);
      final plan = await _plan(tx, planId);
      final id = await tx.insert('training_logs', {
        'plan_id': planId,
        'session_token': _token(),
        'status': 'draft',
        'started_at': clock(),
        'completed_at': null,
        'target_sets_snapshot': plan.targetSets,
        'target_reps_snapshot': plan.targetReps,
        'exercise_name_snapshot': plan.exerciseName,
        'actual_sets_json': '[]',
      });
      return _log(tx, id);
    });
  }

  /// Compare-and-set length makes retried/stale appends fail rather than double-log.
  Future<void> saveSet(int id, int index, int reps, int expectedLength) async {
    _beforeWrite();
    await db.transaction((tx) async {
      final log = await _log(tx, id);
      if (log.completed ||
          log.actualSets.length != expectedLength ||
          index < 0 ||
          index > log.actualSets.length) {
        throw StateError('Session changed. Refresh before recording this set.');
      }
      final sets = [...log.actualSets];
      if (index == sets.length) {
        sets.add(reps);
      } else {
        sets[index] = reps;
      }
      TrainingLog.validateSets(sets, log.targetSets);
      await tx.update(
        'training_logs',
        {'actual_sets_json': jsonEncode(sets)},
        where: 'id=?',
        whereArgs: [id],
      );
    });
  }

  Future<void> undo(int id) async {
    _beforeWrite();
    await db.transaction((tx) async {
      final log = await _log(tx, id);
      if (log.completed || log.actualSets.isEmpty)
        throw StateError('No draft set to undo.');
      final sets = [...log.actualSets]..removeLast();
      await tx.update(
        'training_logs',
        {'actual_sets_json': jsonEncode(sets)},
        where: 'id=?',
        whereArgs: [id],
      );
    });
  }

  Future<void> finish(int id) async {
    _beforeWrite();
    await db.transaction((tx) async {
      final log = await _log(tx, id);
      if (log.completed)
        return; // Idempotent finish keeps the original timestamp.
      TrainingLog.validateSets(log.actualSets, log.targetSets, complete: true);
      await tx.update(
        'training_logs',
        {'status': 'completed', 'completed_at': clock()},
        where: "id=? AND status='draft'",
        whereArgs: [id],
      );
    });
  }

  Future<void> reset(int id) async {
    _beforeWrite();
    await db.delete(
      'training_logs',
      where: "id=? AND status='draft'",
      whereArgs: [id],
    );
  }

  Future<void> saveHistory({
    int? id,
    required int planId,
    required List<int> sets,
    required int at,
  }) async {
    if (at < 0 || at > clock())
      throw const FormatException(
        'Choose a valid date that is not in the future.',
      );
    _beforeWrite();
    await db.transaction((tx) async {
      final plan = await _plan(tx, planId);
      final old = id == null ? null : await _log(tx, id);
      if (old != null && (!old.completed || old.planId != planId))
        throw StateError('Only completed logs can be corrected here.');
      final target = old?.targetSets ?? plan.targetSets;
      TrainingLog.validateSets(sets, target, complete: true);
      final values = <String, Object?>{
        'plan_id': planId,
        'session_token': old?.token ?? _token(),
        'status': 'completed',
        'started_at': at,
        'completed_at': at,
        'target_sets_snapshot': target,
        'target_reps_snapshot': old?.targetReps ?? plan.targetReps,
        'exercise_name_snapshot': old?.exerciseName ?? plan.exerciseName,
        'actual_sets_json': jsonEncode(sets),
      };
      if (id == null) {
        await tx.insert('training_logs', values);
      } else {
        await tx.update(
          'training_logs',
          values,
          where: 'id=?',
          whereArgs: [id],
        );
      }
    });
  }

  Future<void> deleteLog(int id) async {
    _beforeWrite();
    await db.delete('training_logs', where: 'id=?', whereArgs: [id]);
  }

  Future<void> close() => db.close();
}
