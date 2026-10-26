import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:movement_quest/data/quest_repository.dart';
import 'package:movement_quest/models/workout.dart';

void main() {
  sqfliteFfiInit();
  late QuestRepository repo;
  final now = DateTime.utc(2026, 10, 22, 12).millisecondsSinceEpoch;
  WorkoutPlan plan({
    int? id,
    int sets = 2,
    int reps = 10,
    String name = 'Short quest',
  }) => WorkoutPlan(
    id: id,
    name: name,
    exerciseKey: 'squat',
    equipment: 'bodyweight',
    targetSets: sets,
    targetReps: reps,
    intensity: 3,
    createdAt: now,
    updatedAt: now,
  );
  setUp(() async {
    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: QuestRepository.configure,
        onCreate: QuestRepository.createSchema,
      ),
    );
    repo = QuestRepository(db, clock: () => now);
  });
  tearDown(() async {
    await repo.close();
  });

