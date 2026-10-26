class WorkoutPlan {
  final int? id;
  final String name;
  final String exerciseKey;
  final String equipment;
  final int targetSets;
  final int targetReps;
  final int intensity;
  final int createdAt;
  final int updatedAt;

  // Constructor, validation, toMap(), and fromMap()
}
class TrainingLog {
  final int id;
  final int planId;
  final String token;
  final bool completed;
  final int startedAt;
  final int? completedAt;
  final int targetSets;
  final int targetReps;
  final String exerciseName;
  final List<int> actualSets;

  // Constructor, fromMap(), and validateSets()
}