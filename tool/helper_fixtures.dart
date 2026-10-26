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
