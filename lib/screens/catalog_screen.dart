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
     