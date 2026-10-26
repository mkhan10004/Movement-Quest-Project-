import 'package:flutter/material.dart';

import '../models/workout.dart';
import '../state/quest_controller.dart';
import '../services/plan_helper.dart';
import '../widgets/common.dart';
import 'workout_detail.dart';
import 'plan_editor.dart';

class CatalogScreen extends StatefulWidget {
  final QuestController controller;
  const CatalogScreen({super.key, required this.controller});
  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String filter = 'all';
  bool dismissed = false;
  final expanded = <int>{};
  void open(int id) => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => WorkoutDetail(controller: widget.controller, planId: id),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final plans = c.plans
        .where((p) => filter == 'all' || p.equipment == filter)
        .toList();
    final ids = plans.map((p) => p.id).toSet();
    final count = c.logs
        .where((l) => l.completed && ids.contains(l.planId))
        .length;
    final suggestion = suggestPlan(
      c.plans,
      c.logs,
      c.settings.equipment,
      DateTime.now().millisecondsSinceEpoch,
    );
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'A little movement.\nYour own pace.',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text('Plan a short routine and record what you complete.'),
        ),
        FilledButton.icon(
          onPressed: c.busy
              ? null
              : () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => PlanEditor(controller: c),
                  ),
                ),
          icon: const Icon(Icons.add),
          label: const Text('Create plan'),
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          initialValue: filter,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Equipment filter'),
          items: ['all', ...equipmentOptions]
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Text(s == 'all' ? 'All equipment' : s),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => filter = v!),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text('$count completed sessions for visible plans'),
        ),
        if (!dismissed)
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Local plan helper',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (suggestion.plan != null) Text(suggestion.plan!.name),
                  Text(suggestion.explanation),
                  const Text(
                    'Uses all saved plans; the list filter does not change the ranking.',
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (suggestion.plan != null)
                        FilledButton(
                          onPressed: c.busy
                              ? null
                              : () => open(suggestion.plan!.id!),
                          child: const Text('Apply'),
                        ),
                      TextButton(
                        onPressed: () => setState(() => dismissed = true),
                        child: const Text('Not now'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        if (dismissed)
          TextButton(
            onPressed: () => setState(() => dismissed = false),
            child: const Text('Show local helper'),
          ),
        if (plans.isEmpty)
          Notice(
            c.plans.isEmpty
                ? 'No plans yet. Create your first quest above.'
                : 'No plans match this filter.',
          ),
        for (final p in plans)
          PlanCard(
            plan: p,
            completed: c.logs
                .where((l) => l.completed && l.planId == p.id)
                .length,
            expanded: expanded.contains(p.id),
            reduced: reducedMotion(context, c),
            onOpen: () => open(p.id!),
            onExpand: () => setState(() {
              if (!expanded.add(p.id!)) expanded.remove(p.id!);
            }),
          ),
      ],
    );
  }
}
