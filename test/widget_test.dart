import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movement_quest/widgets/common.dart';
import 'package:movement_quest/models/workout.dart';
import 'package:movement_quest/screens/plan_editor.dart';
import 'package:movement_quest/state/quest_controller.dart';
import 'package:movement_quest/data/quest_repository.dart';
import 'package:movement_quest/data/settings_store.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  testWidgets('PlanCard exposes open alternative and supplied count', (
    tester,
  ) async {
    var opened = false;
    final p = WorkoutPlan(
      id: 1,
      name: 'Morning',
      exerciseKey: 'squat',
      equipment: 'bodyweight',
      targetSets: 2,
      targetReps: 10,
      intensity: 3,
      createdAt: 0,
      updatedAt: 0,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlanCard(
            plan: p,
            completed: 4,
            expanded: true,
            reduced: true,
            onOpen: () => opened = true,
            onExpand: () {},
          ),
        ),
      ),
    );
    expect(find.text('4 completed sessions'), findsOneWidget);
    await tester.tap(find.text('Open'));
    expect(opened, true);
    expect(tester.takeException(), isNull);
  });
  testWidgets('invalid name stays in form without database insert', (
    tester,
  ) async {
    sqfliteFfiInit();
    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: QuestRepository.configure,
        onCreate: QuestRepository.createSchema,
      ),
    );
    final repo = QuestRepository(db),
        c = QuestController(QuestRepository(db), SettingsStore());
    await tester.pumpWidget(MaterialApp(home: PlanEditor(controller: c)));
    await tester.ensureVisible(find.text('Save plan'));
    await tester.tap(find.text('Save plan'));
    await tester.pump();
    expect(find.text('Enter a plan name.'), findsOneWidget);
    expect(await repo.plans(), isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
    c.dispose();
    await repo.close();
  });
}
