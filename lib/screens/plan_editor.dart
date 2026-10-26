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

