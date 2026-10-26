import '../lib/models/workout.dart';
import '../lib/services/plan_helper.dart';

final fixtureNow = DateTime.utc(2026, 10, 22, 12).millisecondsSinceEpoch;
WorkoutPlan fixturePlan(int id, String equipment) => WorkoutPlan(
  id: id,
  name: 'Plan $id',
  exerciseKey: 'squat',
  equipment: equipment,
  targetSets: 1,
  targetReps: 10,
  intensity: 3,
  createdAt: fixtureNow,
  updatedAt: fixtureNow,
);
TrainingLog fixtureLog(int id, int planId, int at) => TrainingLog(
  id: id,
  planId: planId,
  token: 'fixture-$id',
  status: 'completed',
  startedAt: at,
  completedAt: at,
  targetSets: 1,
  targetReps: 10,
  exerciseName: 'Squat',
  actualSets: [10],
);
List<Map<String, Object?>> evaluateFixtures() {
  final a = fixturePlan(1, 'dumbbell'),
      b = fixturePlan(2, 'bodyweight'),
      c = fixturePlan(3, 'bodyweight');
  final history = [fixtureLog(1, 2, fixtureNow), fixtureLog(2, 2, fixtureNow)];
  final cases = <Map<String, Object?>>[];
  void run(
    String name,
    List<WorkoutPlan> plans,
    List<TrainingLog> logs,
    String pref,
    int? expected, {
    int? desired,
    bool invalid = false,
  }) {
    final r = suggestPlan(plans, logs, pref, fixtureNow);
    cases.add({
      'case': name,
      'expected_plan': expected,
      'actual_plan': r.plan?.id,
      'expected_invalid': invalid,
      'actual_invalid': r.invalid,
      'passed': r.plan?.id == expected && r.invalid == invalid,
      'preference_label': desired,
      'baseline_plan': baseline(plans)?.id,
      'helper_match': desired == null ? null : r.plan?.id == desired,
      'baseline_match': desired == null ? null : baseline(plans)?.id == desired,
      'reason': r.explanation,
    });
  }

  run('normal', [a, b, c], history, 'bodyweight', 3, desired: 3);
  run('no catalog', [], [], 'none', null);
  run('no history', [a, b, c], [], 'bodyweight', 2, desired: 2);
  run('invalid preference', [a, b], [], 'unknown', null, invalid: true);
  run(
    'invalid history',
    [a, b],
    [fixtureLog(3, 99, fixtureNow)],
    'none',
    null,
    invalid: true,
  );
  run(
    'boundary inclusive',
    [b, c],
    [fixtureLog(4, 2, fixtureNow - const Duration(days: 7).inMilliseconds)],
    'bodyweight',
    3,
    desired: 3,
  );
  run(
    'older than boundary',
    [b, c],
    [fixtureLog(4, 2, fixtureNow - const Duration(days: 7).inMilliseconds - 1)],
    'bodyweight',
    2,
    desired: 2,
  );
  run('tie', [b, c], [], 'none', 2, desired: 2);
  run(
    'penalty cap',
    [b, c],
    [
      ...history,
      fixtureLog(3, 3, fixtureNow),
      fixtureLog(4, 3, fixtureNow),
      fixtureLog(5, 3, fixtureNow),
    ],
    'bodyweight',
    2,
    desired: 2,
  );
  run('counterexample', [b, c], history, 'bodyweight', 3, desired: 2);
  return cases;
}
