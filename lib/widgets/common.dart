import 'package:flutter/material.dart';

import '../state/quest_controller.dart';
import '../models/workout.dart';

String friendlyError(Object e) => e is FormatException
    ? e.message.toString()
    : e is StateError
    ? e.message
    : 'Could not save. Your values are retained. Try again.';
void feedback(BuildContext context, String text) =>
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
bool reducedMotion(BuildContext context, QuestController c) =>
    c.settings.motion == 'on' ||
    (c.settings.motion == 'system' && MediaQuery.disableAnimationsOf(context));
Future<bool> confirm(
  BuildContext context,
  String title,
  String message,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    ) ??
    false;

class Notice extends StatelessWidget {
  final String message;
  final VoidCallback? retry;
  const Notice(this.message, {super.key, this.retry});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message),
        if (retry != null)
          TextButton(onPressed: retry, child: const Text('Retry')),
      ],
    ),
  );
}

class PlanCard extends StatelessWidget {
  final WorkoutPlan plan;
  final int completed;
  final bool expanded, reduced;
  final VoidCallback onOpen, onExpand;
  const PlanCard({
    super.key,
    required this.plan,
    required this.completed,
    required this.expanded,
    required this.reduced,
    required this.onOpen,
    required this.onExpand,
  });
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onOpen,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                plan.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          Text('${plan.exerciseName} · ${plan.equipment}'),
          Text('$completed completed sessions'),
          AnimatedSize(
            duration: Duration(milliseconds: reduced ? 0 : 180),
            curve: Curves.easeInOutCubic,
            child: expanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      '${plan.targetSets} sets × ${plan.targetReps} target reps\nYour intensity label: ${plan.intensity}/5',
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Wrap(
            spacing: 8,
            children: [
              FilledButton(onPressed: onOpen, child: const Text('Open')),
              TextButton(
                onPressed: onExpand,
                child: Text(expanded ? 'Collapse details' : 'Expand details'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
