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

  Future<void> initialize() async {
    loading = true;
    _emit();
    try {
      settings = await settingsStore.read();
      settingsError = null;
    } catch (_) {
      settingsError =
          'Preferences could not be loaded. Retry or restore defaults.';
    }
    await refresh();
  }

  Future<void> refresh() async {
    try {
      final nextPlans = await repository.plans();
      final nextLogs = await repository.logs();
      plans = nextPlans;
      logs = nextLogs;
      readError = null;
    } catch (_) {
      readError = 'Saved records could not be loaded. Retry. Existing data is unchanged.';
    }
    loading = false;
    _emit();
  }

  Future<void> write(Future<void> Function() operation) async {
    if (busy) throw StateError('A save is already in progress.');
    busy = true;
    _emit();
    try {
      await operation();
      await refresh();
    } finally {
      busy = false;
      _emit();
    }
  }

  Future<void> saveSettings(QuestSettings next) async {
    if (busy) throw StateError('Please wait for the current save.');
    busy = true;
    _emit();
    try {
      await settingsStore.save(next);
      settings = next;
      settingsError = null;
    } finally {
      busy = false;
      _emit();
    }
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
