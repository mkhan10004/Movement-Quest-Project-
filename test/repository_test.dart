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
  test('plan create read update delete', () async {
    final id = await repo.savePlan(plan());
    expect((await repo.plans()).single.name, 'Short quest');
    await repo.savePlan(plan(id: id, name: 'Changed'));
    expect((await repo.plans()).single.name, 'Changed');
    await repo.deletePlan(id);
    expect(await repo.plans(), isEmpty);
  });
  test('reject invalid plan without writing', () async {
    await expectLater(repo.savePlan(plan(sets: 0)), throwsFormatException);
    expect(await repo.plans(), isEmpty);
  });
  test('start twice returns same draft', () async {
    final id = await repo.savePlan(plan());
    final a = await repo.start(id), b = await repo.start(id);
    expect(a.id, b.id);
    expect((await repo.logs()).length, 1);
  });
  test('concurrent start is serialized to one draft', () async {
    final id = await repo.savePlan(plan());
    final drafts = await Future.wait([repo.start(id), repo.start(id)]);
    expect(drafts[0].id, drafts[1].id);
  });
  test('stale append cannot duplicate a set', () async {
    final id = await repo.savePlan(plan());
    final log = await repo.start(id);
    await repo.saveSet(log.id, 0, 10, 0);
    await expectLater(repo.saveSet(log.id, 0, 10, 0), throwsStateError);
    expect((await repo.logs()).single.actualSets, [10]);
  });
  test('edit and undo persist corrected draft', () async {
    final id = await repo.savePlan(plan());
    final log = await repo.start(id);
    await repo.saveSet(log.id, 0, 10, 0);
    await repo.saveSet(log.id, 0, 8, 1);
    expect((await repo.logs()).single.actualSets, [8]);
    await repo.undo(log.id);
    expect((await repo.logs()).single.actualSets, isEmpty);
  });
  test('unfinished draft cannot finish', () async {
    final id = await repo.savePlan(plan());
    final log = await repo.start(id);
    await expectLater(repo.finish(log.id), throwsFormatException);
    expect((await repo.logs()).single.completed, false);
  });
  test('finish idempotent and reset never removes completed log', () async {
    final id = await repo.savePlan(plan(sets: 1));
    final log = await repo.start(id);
    await repo.saveSet(log.id, 0, 10, 0);
    await repo.finish(log.id);
    await repo.finish(log.id);
    await repo.reset(log.id);
    expect((await repo.logs()).length, 1);
    expect((await repo.logs()).single.completed, true);
  });
  test('history supports create edit delete', () async {
    final id = await repo.savePlan(plan());
    await repo.saveHistory(planId: id, sets: [10, 9], at: now);
    final log = (await repo.logs()).single;
    await repo.saveHistory(id: log.id, planId: id, sets: [8, 7], at: now);
    expect((await repo.logs()).single.actualSets, [8, 7]);
    await repo.deleteLog(log.id);
    expect(await repo.logs(), isEmpty);
  });
  test('plan edit preserves existing log snapshots', () async {
    final id = await repo.savePlan(plan());
    final log = await repo.start(id);
    await repo.savePlan(plan(id: id, sets: 3, reps: 20));
    expect((await repo.logs()).single.targetSets, 2);
    expect((await repo.logs()).single.id, log.id);
    expect((await repo.logs()).single.targetReps, 10);
  });
  test('delete parent cascades draft and completed sessions', () async {
    final id = await repo.savePlan(plan());
    await repo.start(id);
    await repo.saveHistory(planId: id, sets: [8, 9], at: now);
    await repo.deletePlan(id);
    expect(await repo.logs(), isEmpty);
  });
  test('failed write preserves row and allows retry', () async {
    final id = await repo.savePlan(plan());
    repo.rejectNextWrite = true;
    await expectLater(
      repo.savePlan(plan(id: id, name: 'Retry')),
      throwsStateError,
    );
    expect((await repo.plans()).single.name, 'Short quest');
    await repo.savePlan(plan(id: id, name: 'Retry'));
    expect((await repo.plans()).single.name, 'Retry');
  });
  test('future history rejected', () async {
    final id = await repo.savePlan(plan());
    await expectLater(
      repo.saveHistory(planId: id, sets: [8, 9], at: now + 1),
      throwsFormatException,
    );
    expect(await repo.logs(), isEmpty);
  });
  test('invalid repetitions cannot be committed', () async {
    final id = await repo.savePlan(plan());
    final log = await repo.start(id);
    await expectLater(repo.saveSet(log.id, 0, 101, 0), throwsFormatException);
    expect((await repo.logs()).single.actualSets, isEmpty);
  });
}
