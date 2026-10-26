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
    ),
  );

  Future<void> close() => db.close();
}