import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/workout.dart';

class QuestSettings {
  final String theme, equipment, motion;
  const QuestSettings({
    this.theme = 'system',
    this.equipment = 'none',
    this.motion = 'system',
  });
  QuestSettings copy({String? theme, String? equipment, String? motion}) =>
      QuestSettings(
        theme: theme ?? this.theme,
        equipment: equipment ?? this.equipment,
        motion: motion ?? this.motion,
      );
  void validate() {
    if (!['system', 'light', 'dark'].contains(theme) ||
        !['none', ...equipmentOptions].contains(equipment) ||
        !['system', 'on', 'off'].contains(motion)) {
      throw const FormatException(
        'Invalid preferences. Choose listed options.',
      );
    }
  }
}

class SettingsStore {
  final SharedPreferencesAsync prefs;
  SettingsStore([SharedPreferencesAsync? prefs])
    : prefs = prefs ?? SharedPreferencesAsync();
  Future<QuestSettings> read() async {
    final raw = await prefs.getString('quest_settings_v1');
    if (raw == null) return const QuestSettings();
    final m = jsonDecode(raw) as Map<String, dynamic>;
    final settings = QuestSettings(
      theme: m['theme'] as String,
      equipment: m['equipment'] as String,
      motion: m['motion'] as String,
    );
    settings.validate();
    return settings;
  }

