import 'dart:convert';

const equipmentOptions = ['bodyweight', 'dumbbell', 'band'];
const exercises = {
  'squat': 'Squat',
  'push_up': 'Push-up',
  'row': 'Row',
  'press': 'Press',
  'curl': 'Curl',
};

class WorkoutPlan {
  final int? id;
  final String name, exerciseKey, equipment;
  final int targetSets, targetReps, intensity, createdAt, updatedAt;
  const WorkoutPlan({
    this.id,
    required this.name,
    required this.exerciseKey,
    required this.equipment,
    required this.targetSets,
    required this.targetReps,
    required this.intensity,
    required this.createdAt,
    required this.updatedAt,
  });
  String get exerciseName => exercises[exerciseKey] ?? exerciseKey;
  void validate() {
    if (name.trim().isEmpty || name.trim().length > 80) {
      throw const FormatException('Use a plan name of 1–80 characters.');
    }
    if (!exercises.containsKey(exerciseKey) ||
        !equipmentOptions.contains(equipment)) {
      throw const FormatException('Choose a listed exercise and equipment.');
    }
    if (targetSets < 1 ||
        targetSets > 10 ||
        targetReps < 1 ||
        targetReps > 100 ||
        intensity < 1 ||
        intensity > 5) {
      throw const FormatException(
        'Sets: 1–10. Repetitions: 1–100. Intensity label: 1–5.',
      );
    }
  }

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'name': name.trim(),
    'exercise_key': exerciseKey,
    'equipment': equipment,
    'target_sets': targetSets,
    'target_reps': targetReps,
    'intensity': intensity,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
  factory WorkoutPlan.fromMap(Map<String, Object?> m) => WorkoutPlan(
    id: m['id'] as int,
    name: m['name'] as String,
    exerciseKey: m['exercise_key'] as String,
    equipment: m['equipment'] as String,
    targetSets: m['target_sets'] as int,
    targetReps: m['target_reps'] as int,
    intensity: m['intensity'] as int,
    createdAt: m['created_at'] as int,
    updatedAt: m['updated_at'] as int,
  );
}

class TrainingLog {
  final int id, planId, startedAt, targetSets, targetReps;
  final int? completedAt;
  final String token, status, exerciseName;
  final List<int> actualSets;
  TrainingLog({
    required this.id,
    required this.planId,
    required this.token,
    required this.status,
    required this.startedAt,
    this.completedAt,
    required this.targetSets,
    required this.targetReps,
    required this.exerciseName,
    required List<int> actualSets,
  }) : actualSets = List.unmodifiable(actualSets);
  bool get completed => status == 'completed';
  static void validateSets(
    List<int> sets,
    int target, {
    bool complete = false,
  }) {
    if (target < 1 ||
        target > 10 ||
        sets.length > target ||
        sets.any((v) => v < 1 || v > 100) ||
        (complete && sets.length != target)) {
      throw const FormatException(
        'Record each planned set with 1–100 repetitions.',
      );
    }
  }


