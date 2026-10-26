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

  