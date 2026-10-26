import 'dart:math';

import '../models/workout.dart';

class Suggestion {
  final WorkoutPlan? plan;
  final String explanation;
  final Map<int, int> scores;
  final bool invalid;
  const Suggestion(
    this.plan,
    this.explanation,
    this.scores, {
    this.invalid = false,
  });
}

/// Pure local rules. No model, network, health data or automatic session creation.
Suggestion suggestPlan(
  List<WorkoutPlan> plans,
  List<TrainingLog> logs,
  String preference,
  int now,
) {
  try {
    if (preference != 'none' && !equipmentOptions.contains(preference)) {
      throw const FormatException(
        'Choose a listed equipment preference in Settings.',
      );
    }
    final ids = <int>{};
    for (final p in plans) {
      p.validate();
      if (p.id == null || !ids.add(p.id!))
        throw const FormatException('Plan IDs must be unique.');
    }
    for (final l in logs) {
      TrainingLog.validateSets(
        l.actualSets,
        l.targetSets,
        complete: l.completed,
      );
      if (!ids.contains(l.planId) ||
          !['draft', 'completed'].contains(l.status) ||
          (l.completed &&
              (l.completedAt == null ||
                  l.completedAt! > now ||
                  l.completedAt! < l.startedAt))) {
        throw const FormatException(
          'History is invalid. Correct the saved history before using suggestions.',
        );
      }
    }
    if (plans.isEmpty)
      return const Suggestion(null, 'Create a plan first.', {});
    final boundary = now - const Duration(days: 7).inMilliseconds;
    final counts = <int, int>{for (final p in plans) p.id!: 0};
    for (final l in logs.where(
      (l) => l.completed && l.completedAt! >= boundary && l.completedAt! <= now,
    )) {
      counts[l.planId] = counts[l.planId]! + 1;
    }
    final scores = <int, int>{
      for (final p in plans)
        p.id!:
            3 * (preference != 'none' && p.equipment == preference ? 1 : 0) -
            min(counts[p.id]!, 2),
    };
    final ranked = [...plans]
      ..sort((a, b) {
        final score = scores[b.id]!.compareTo(scores[a.id]!);
        return score == 0 ? a.id!.compareTo(b.id!) : score;
      });
    final pick = ranked.first;
    final noHistory = !logs.any((l) => l.completed);
    return Suggestion(
      pick,
      '${pick.equipment == preference
          ? 'Matches $preference'
          : preference == 'none'
          ? 'No equipment preference'
          : 'Different equipment'}; '
      '${counts[pick.id]} completed in the last 7 days. '
      '${noHistory ? 'No completed history yet. ' : ''}Suggested, not guaranteed. Choose any plan.',
      scores,
    );
  } on FormatException catch (e) {
    return Suggestion(null, e.message.toString(), const {}, invalid: true);
  }
}

WorkoutPlan? baseline(List<WorkoutPlan> plans) {
  if (plans.isEmpty) return null;
  return ([...plans]..sort((a, b) => a.id!.compareTo(b.id!))).first;
}
