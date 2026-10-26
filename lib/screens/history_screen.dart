import 'package:flutter/material.dart';

import '../models/workout.dart';
import '../state/quest_controller.dart';
import '../widgets/common.dart';

class HistoryScreen extends StatefulWidget {
  final QuestController controller;
  final int? planId;
  const HistoryScreen({super.key, required this.controller, this.planId});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int? filter;
  @override
  void initState() {
    super.initState();
    filter = widget.planId;
  }

  Future<void> edit([TrainingLog? log]) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => LogEditor(
        controller: widget.controller,
        original: log,
        initialPlan: filter,
      ),
    );
  }

  Future<void> remove(TrainingLog log) async {
    if (!await confirm(
      context,
      'Delete session?',
      'This completed session will be removed and counts recalculated.',
    ))
      return;
    try {
      await widget.controller.write(
        () => widget.controller.repository.deleteLog(log.id),
      );
      if (mounted) feedback(context, 'Session deleted');
    } catch (e) {
      if (mounted) feedback(context, friendlyError(e));
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final c = widget.controller;
      final selected = c.plans.any((p) => p.id == filter) ? filter : null;
      final logs = c.logs
          .where(
            (l) => l.completed && (selected == null || l.planId == selected),
          )
          .toList();
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Training history',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            key: ValueKey(selected),
            initialValue: selected ?? -1,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Plan filter'),
            items: [
              const DropdownMenuItem(value: -1, child: Text('All plans')),
              ...c.plans.map(
                (p) => DropdownMenuItem(value: p.id, child: Text(p.name)),
              ),
            ],
            onChanged: c.busy
                ? null
                : (v) => setState(() => filter = v == -1 ? null : v),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text('${logs.length} completed sessions'),
          ),
          FilledButton.icon(
            onPressed: c.busy || c.plans.isEmpty ? null : () => edit(),
            icon: const Icon(Icons.add),
            label: const Text('Add past session'),
          ),
          if (c.plans.isEmpty)
            const Notice('Create a plan in the Catalog before adding history.'),
          if (logs.isEmpty && c.plans.isNotEmpty)
            const Notice(
              'No completed sessions yet. Record one or add a past session.',
            ),
          for (final l in logs)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.plan(l.planId)?.name ?? 'Plan ${l.planId}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '${l.exerciseName} · ${DateTime.fromMillisecondsSinceEpoch(l.completedAt!).toLocal().toString().substring(0, 16)}',
                    ),
                    Text('Actual reps: ${l.actualSets.join(', ')}'),
                    Text('Target at start: ${l.targetSets} × ${l.targetReps}'),
                    Wrap(
                      spacing: 8,
                      children: [
                        TextButton(
                          onPressed: c.busy ? null : () => edit(l),
                          child: const Text('Edit session'),
                        ),
                        TextButton(
                          onPressed: c.busy ? null : () => remove(l),
                          child: const Text('Delete session'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );
}

class LogEditor extends StatefulWidget {
  final QuestController controller;
  final TrainingLog? original;
  final int? initialPlan;
  const LogEditor({
    super.key,
    required this.controller,
    this.original,
    this.initialPlan,
  });
  @override
  State<LogEditor> createState() => _LogEditorState();
}

class _LogEditorState extends State<LogEditor> {
  final form = GlobalKey<FormState>();
  late final TextEditingController reps, date;
  late int planId;
  bool saving = false;
  String? error;
  @override
  void initState() {
    super.initState();
    final old = widget.original;
    planId =
        old?.planId ?? widget.initialPlan ?? widget.controller.plans.first.id!;
    reps = TextEditingController(text: old?.actualSets.join(', ') ?? '');
    date = TextEditingController(
      text: DateTime.fromMillisecondsSinceEpoch(
        old?.completedAt ?? DateTime.now().millisecondsSinceEpoch,
      ).toIso8601String().substring(0, 10),
    );
  }

  @override
  void dispose() {
    reps.dispose();
    date.dispose();
    super.dispose();
  }

  List<int> values() =>
      reps.text.split(',').map((s) => int.parse(s.trim())).toList();
  int get target =>
      widget.original?.targetSets ?? widget.controller.plan(planId)!.targetSets;
  Future<void> save() async {
    if (saving || !form.currentState!.validate()) return;
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await widget.controller.write(
        () => widget.controller.repository.saveHistory(
          id: widget.original?.id,
          planId: planId,
          sets: values(),
          at: DateTime.parse(date.text).millisecondsSinceEpoch,
        ),
      );
      if (mounted) {
        feedback(context, 'Session saved');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted)
        setState(() {
          saving = false;
          error = friendlyError(e);
        });
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !saving,
    child: AlertDialog(
      title: Text(
        widget.original == null ? 'Add past session' : 'Correct session',
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: planId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Plan'),
                  items: widget.controller.plans
                      .map(
                        (p) =>
                            DropdownMenuItem(value: p.id, child: Text(p.name)),
                      )
                      .toList(),
                  onChanged: saving || widget.original != null
                      ? null
                      : (v) => setState(() => planId = v!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: date,
                  enabled: !saving,
                  decoration: const InputDecoration(
                    labelText: 'Session date (YYYY-MM-DD)',
                    helperText: 'Local calendar date',
                  ),
                  validator: (v) {
                    final d = DateTime.tryParse(v ?? '');
                    if (d == null ||
                        !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(v!) ||
                        d.toIso8601String().substring(0, 10) != v ||
                        d.isAfter(DateTime.now()) ||
                        d.millisecondsSinceEpoch < 0)
                      return 'Use a valid date, today or earlier.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: reps,
                  enabled: !saving,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Actual repetitions',
                    helperText:
                        'Exactly $target comma-separated sets; 1–100 each',
                  ),
                  validator: (_) {
                    try {
                      TrainingLog.validateSets(
                        values(),
                        target,
                        complete: true,
                      );
                      return null;
                    } catch (_) {
                      return 'Enter exactly $target sets, e.g. ${List.filled(target, 10).join(', ')}';
                    }
                  },
                ),
                if (error != null) Notice(error!),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: saving ? null : save,
          child: Text(
            saving
                ? 'Saving…'
                : error == null
                ? 'Save'
                : 'Retry save',
          ),
        ),
      ],
    ),
  );
}
