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
      