import 'package:flutter/material.dart';

import '../models/workout.dart';
import '../state/quest_controller.dart';
import '../widgets/common.dart';

class PlanEditor extends StatefulWidget {
  final QuestController controller;
  final WorkoutPlan? original;
  const PlanEditor({super.key, required this.controller, this.original});
  @override
  State<PlanEditor> createState() => _PlanEditorState();
}

class _PlanEditorState extends State<PlanEditor> {
  final form = GlobalKey<FormState>();
  late final TextEditingController name, sets, reps;
  late String exercise, equipment;
  late double intensity;
  bool saving = false, dirty = false, allowPop = false;
  String? error;
  @override
  void initState() {
    super.initState();
    final p = widget.original;
    name = TextEditingController(text: p?.name ?? '');
    sets = TextEditingController(text: '${p?.targetSets ?? 2}');
    reps = TextEditingController(text: '${p?.targetReps ?? 10}');
    exercise = p?.exerciseKey ?? 'squat';
    equipment = p?.equipment ?? 'bodyweight';
    intensity = (p?.intensity ?? 3).toDouble();
  }

  @override
  void dispose() {
    name.dispose();
    sets.dispose();
    reps.dispose();
    super.dispose();
  }

  Future<void> leave() async {
    if (saving) return;
    if (!dirty ||
        await confirm(
          context,
          'Discard changes?',
          'Unsaved plan changes will be discarded.',
        )) {
      if (!mounted) return;
      setState(() => allowPop = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  Future<void> save() async {
    if (saving || !form.currentState!.validate()) return;
    setState(() {
      saving = true;
      error = null;
    });
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final p = WorkoutPlan(
        id: widget.original?.id,
        name: name.text,
        exerciseKey: exercise,
        equipment: equipment,
        targetSets: int.parse(sets.text),
        targetReps: int.parse(reps.text),
        intensity: intensity.round(),
        createdAt: widget.original?.createdAt ?? now,
        updatedAt: now,
      );
      await widget.controller.write(() async {
        await widget.controller.repository.savePlan(p);
      });
      if (!mounted) return;
      setState(() {
        allowPop = true;
        saving = false;
      });
      feedback(context, 'Plan saved');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    } catch (e) {
      if (mounted)
        setState(() {
          error = friendlyError(e);
          saving = false;
        });
    }
  }

  Widget number(TextEditingController c, String label, int max) =>
      TextFormField(
        controller: c,
        enabled: !saving,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          helperText: 'Whole number, 1–$max',
        ),
        validator: (s) {
          final n = int.tryParse(s ?? '');
          return n == null || n < 1 || n > max
              ? 'Enter a whole number from 1 to $max.'
              : null;
        },
      );
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: allowPop,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) leave();
    },
    child: Scaffold(
      appBar: AppBar(
        title: Text(widget.original == null ? 'Create a quest' : 'Edit plan'),
        leading: IconButton(
          onPressed: saving ? null : leave,
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Cancel editor',
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Form(
            key: form,
            onChanged: () {
              dirty = true;
            },
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextFormField(
                  controller: name,
                  enabled: !saving,
                  maxLength: 80,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Plan name'),
                  validator: (s) => s == null || s.trim().isEmpty
                      ? 'Enter a plan name.'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: exercise,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Exercise'),
                  items: exercises.entries
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        ),
                      )
                      .toList(),
                  onChanged: saving
                      ? null
                      : (v) => setState(() {
                          exercise = v!;
                          dirty = true;
                        }),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: equipment,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Equipment'),
                  items: equipmentOptions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: saving
                      ? null
                      : (v) => setState(() {
                          equipment = v!;
                          dirty = true;
                        }),
                ),
                const SizedBox(height: 16),
                number(sets, 'Target sets', 10),
                const SizedBox(height: 16),
                number(reps, 'Target reps per set', 100),
                const SizedBox(height: 16),
                Text('Your intensity label: ${intensity.round()}/5'),
                Slider(
                  value: intensity,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: '${intensity.round()}',
                  semanticFormatterCallback: (v) =>
                      'Intensity label ${v.round()} of 5',
                  onChanged: saving
                      ? null
                      : (v) => setState(() {
                          intensity = v;
                          dirty = true;
                        }),
                ),
                const Text(
                  'A personal label you choose; the app does not recommend exertion.',
                ),
                if (error != null) Notice(error!),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: saving ? null : save,
                  child: Text(
                    saving
                        ? 'Saving…'
                        : error != null
                        ? 'Retry save'
                        : 'Save plan',
                  ),
                ),
                TextButton(
                  onPressed: saving ? null : leave,
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
