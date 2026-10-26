import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class QuestRepository {
  final Database db;

  QuestRepository(this.db);

  static Future<QuestRepository> open() async {
    final path = p.join(await getDatabasesPath(), 'movement_quest.db');

    final db = await openDatabase(path, version: 1);

    return QuestRepository(db);
  }

  Future<void> close() => db.close();
}
