import 'package:flutter/foundation.dart';

import '../data/quest_repository.dart';
import '../data/settings_store.dart';
import '../models/workout.dart';

class QuestController extends ChangeNotifier {
  final QuestRepository repository;
  final SettingsStore settingsStore;
  List<WorkoutPlan> plans = [];
  List<TrainingLog> logs = [];
  QuestSettings settings = const QuestSettings();
  bool loading = true, busy = false;
  String? readError, settingsError;
  bool _closed = false;
  QuestController(this.repository, this.settingsStore);
  void _emit() {
    if (!_closed) notifyListeners();
  }

  WorkoutPlan? plan(int id) {
    for (final p in plans) {
      if (p.id == id) return p;
    }
    return null;
  }

  TrainingLog? draft(int id) {
    for (final l in logs) {
      if (l.planId == id && !l.completed) return l;
    }
    return null;
  }

  @override
  void dispose() {
    _closed = true;
    super.dispose();
  }
}
