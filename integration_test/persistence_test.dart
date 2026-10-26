import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movement_quest/data/quest_repository.dart';
import 'package:movement_quest/models/workout.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'native SQLite closes/reopens with draft and SharedPreferences survive new adapter',
    (tester) async {
      final path = p.join(
        await getDatabasesPath(),
        'mq_integration_${DateTime.now().microsecondsSinceEpoch}.db',
      );
      final prefs = SharedPreferencesAsync();
      const key = 'mq_integration_probe';
      QuestRepository? repo;
      try {
        Future<QuestRepository> open() async => QuestRepository(
          await openDatabase(
            path,
            version: 1,
            onConfigure: QuestRepository.configure,
            onCreate: QuestRepository.createSchema,
          ),
        );
        repo = await open();
        final now = DateTime.now().millisecondsSinceEpoch;
        final id = await repo.savePlan(
          WorkoutPlan(
            name: 'Integration quest',
            exerciseKey: 'squat',
            equipment: 'bodyweight',
            targetSets: 2,
            targetReps: 10,
            intensity: 3,
            createdAt: now,
            updatedAt: now,
          ),
        );
        final log = await repo.start(id);
        await repo.saveSet(log.id, 0, 9, 0);
        await prefs.setString(key, 'dark');
        await repo.close();
        repo = await open();
        expect((await repo.plans()).single.name, 'Integration quest');
        expect((await repo.logs()).single.actualSets, [9]);
        expect((await repo.start(id)).id, log.id);
        expect(await SharedPreferencesAsync().getString(key), 'dark');
      } finally {
        await repo?.close();
        await deleteDatabase(path);
        await prefs.remove(key);
      }
    },
  );
}
