import 'package:flutter/material.dart';

import '../data/settings_store.dart';
import '../models/workout.dart';
import '../state/quest_controller.dart';
import '../widgets/common.dart';

class SettingsScreen extends StatefulWidget {
  final QuestController controller;
  const SettingsScreen({super.key, required this.controller});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? error;
  QuestSettings? failed;
  Future<void> save(QuestSettings s) async {
    try {
      await widget.controller.saveSettings(s);
      if (mounted) {
        setState(() {
          error = null;
          failed = null;
        });
        feedback(context, 'Preferences saved');
      }
    } catch (e) {
      if (mounted)
        setState(() {
          error = friendlyError(e);
          failed = s;
        });
    }
  }

  Widget choice(
    String label,
    String value,
    List<String> choices,
    ValueChanged<String> change,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: DropdownButtonFormField<String>(
      key: ValueKey('$label$value'),
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: choices
          .map(
            (s) => DropdownMenuItem(
              value: s,
              child: Text(
                s == 'none'
                    ? 'No preference'
                    : s == 'system'
                    ? 'Follow device'
                    : s,
              ),
            ),
          )
          .toList(),
      onChanged: widget.controller.busy ? null : (s) => change(s!),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final c = widget.controller, s = c.settings;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Make it yours',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 20),
        if (c.settingsError != null)
          Notice(c.settingsError!, retry: c.initialize),
        if (c.settingsError != null)
          TextButton(
            onPressed: c.busy ? null : () => save(const QuestSettings()),
            child: const Text('Restore preference defaults'),
          ),
        choice('Theme', s.theme, [
          'system',
          'light',
          'dark',
        ], (v) => save(s.copy(theme: v))),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Dark theme'),
          subtitle: const Text(
            'Switch to an explicit light or dark preference',
          ),
          value:
              s.theme == 'dark' ||
              (s.theme == 'system' &&
                  Theme.of(context).brightness == Brightness.dark),
          onChanged: c.busy
              ? null
              : (v) => save(s.copy(theme: v ? 'dark' : 'light')),
        ),
        const SizedBox(height: 20),
        choice('Equipment preference', s.equipment, [
          'none',
          ...equipmentOptions,
        ], (v) => save(s.copy(equipment: v))),
        choice('Reduced motion', s.motion, [
          'system',
          'on',
          'off',
        ], (v) => save(s.copy(motion: v))),
        if (error != null)
          Notice(error!, retry: failed == null ? null : () => save(failed!)),
        if (c.busy) const LinearProgressIndicator(),
        const Text(
          'Your plans, session logs and settings stay on this device. There is no account or cloud sync.',
        ),
        const SizedBox(height: 20),
        const Text(
          'Movement Quest records your choices. Suggestions are convenience rankings, without medical or performance claims.',
        ),
      ],
    );
  }
}
