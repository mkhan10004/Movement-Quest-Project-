import 'package:flutter/material.dart';

import '../state/quest_controller.dart';
import '../widgets/common.dart';
import 'plan_editor.dart';
import 'history_screen.dart';

class WorkoutDetail extends StatefulWidget {
  final QuestController controller;
  final int planId;
  const WorkoutDetail({
    super.key,
    required this.controller,
    required this.planId,
  });
  @override
  State<WorkoutDetail> createState() => _WorkoutDetailState();
}

class _WorkoutDetailState extends State<WorkoutDetail> {
  final reps = TextEditingController();
  int? editIndex;
  bool allowPop = false, finished = false;
  String? error;
  QuestController get c => widget.controller;
  @override
  void dispose() {
    reps.dispose();
    super.dispose();
  }

  Future<bool> action(Future<void> Function() fn, String message) async {
    if (c.busy) return false;
    setState(() => error = null);
    try {
      await c.write(fn);
      if (mounted) feedback(context, message);
      return true;
    } catch (e) {
      if (mounted) setState(() => error = friendlyError(e));
      return false;
    }
  }

  Future<void> leave() async {
    if (c.busy) return;
    final draft = c.draft(widget.planId);
    if (draft != null) {
      final choice = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Leave this session?'),
          content: const Text(
            'Keep your saved draft to resume later, or discard only this draft.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'stay'),
              child: const Text('Stay'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'discard'),
              child: const Text('Discard draft'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, 'keep'),
              child: const Text('Keep draft and leave'),
            ),
          ],
        ),
      );
      if (choice == null || choice == 'stay') return;
      if (choice == 'discard' &&
          !await action(() => c.repository.reset(draft.id), 'Draft discarded'))
        return;
    }
    if (!mounted) return;
    setState(() => allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  Future<void> saveSet() async {
    final draft = c.draft(widget.planId);
    if (draft == null) return;
    final n = int.tryParse(reps.text);
    if (n == null || n < 1 || n > 100) {
      setState(() => error = 'Enter a whole number from 1 to 100 repetitions.');
      return;
    }
    if (await action(
      () => c.repository.saveSet(
        draft.id,
        editIndex ?? draft.actualSets.length,
        n,
        draft.actualSets.length,
      ),
      'Set saved',
    )) {
      if (mounted)
        setState(() {
          reps.clear();
          editIndex = null;
        });
    }
  }

  Future<void> deletePlan() async {
    if (!await confirm(
      context,
      'Delete plan and all history?',
      'This removes the plan, its saved draft, and every completed session linked to it.',
    ))
      return;
    if (await action(
      () => c.repository.deletePlan(widget.planId),
      'Plan and linked history deleted',
    )) {
      if (!mounted) return;
      setState(() => allowPop = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: c,
    builder: (context, _) {
      final plan = c.plan(widget.planId);
      final draft = c.draft(widget.planId);
      final reduced = reducedMotion(context, c);
      final body = plan == null
          ? const Notice('This plan no longer exists. Return to the catalog.')
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  plan.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text('${plan.exerciseName} · ${plan.equipment}'),
                Text(
                  'Plan target: ${plan.targetSets} sets × ${plan.targetReps} reps',
                ),
                const SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: reduced ? 0 : 320),
                  switchInCurve: Curves.easeInOut,
                  child: finished
                      ? const Padding(
                          key: ValueKey('finished'),
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Workout recorded. Your session is saved in history.',
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                if (draft == null)
                  FilledButton(
                    onPressed: c.busy
                        ? null
                        : () async {
                            if (await action(() async {
                              await c.repository.start(widget.planId);
                            }, 'Session ready')) {
                              if (mounted) setState(() => finished = false);
                            }
                          },
                    child: const Text('Start session'),
                  ),
                if (draft != null) ...[
                  Text(
                    'Session snapshot: ${draft.exerciseName}, ${draft.targetSets} × ${draft.targetReps} target reps',
                  ),
                  const Text(
                    'Changing a plan does not change this saved session target.',
                  ),
                  const SizedBox(height: 16),
                  AnimatedContainer(
                    duration: Duration(milliseconds: reduced ? 0 : 220),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: draft.actualSets.length == draft.targetSets
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            '${draft.actualSets.length} of ${draft.targetSets} sets saved',
                          ),
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: draft.actualSets.length / draft.targetSets,
                          semanticsLabel: 'Saved sets',
                          semanticsValue:
                              '${draft.actualSets.length} of ${draft.targetSets}',
                        ),
                      ],
                    ),
                  ),
                  for (var i = 0; i < draft.actualSets.length; i++)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Set ${i + 1}: ${draft.actualSets[i]} reps'),
                      trailing: TextButton(
                        onPressed: c.busy
                            ? null
                            : () {
                                setState(() {
                                  editIndex = i;
                                  reps.text = '${draft.actualSets[i]}';
                                });
                              },
                        child: Text('Edit set ${i + 1}'),
                      ),
                    ),
                  if (draft.actualSets.length < draft.targetSets ||
                      editIndex != null) ...[
                    TextField(
                      controller: reps,
                      enabled: !c.busy,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText:
                            'Actual reps for set ${(editIndex ?? draft.actualSets.length) + 1}',
                        helperText: 'Whole number, 1–100',
                      ),
                    ),
                    FilledButton(
                      onPressed: c.busy ? null : saveSet,
                      child: Text(
                        editIndex == null ? 'Log set' : 'Save correction',
                      ),
                    ),
                    if (editIndex != null)
                      TextButton(
                        onPressed: c.busy
                            ? null
                            : () => setState(() {
                                editIndex = null;
                                reps.clear();
                              }),
                        child: const Text('Cancel correction'),
                      ),
                  ],
                  Wrap(
                    spacing: 8,
                    children: [
                      TextButton(
                        onPressed: c.busy || draft.actualSets.isEmpty
                            ? null
                            : () async {
                                if (await action(
                                  () => c.repository.undo(draft.id),
                                  'Last set removed',
                                )) {
                                  if (mounted)
                                    setState(() {
                                      editIndex = null;
                                      reps.clear();
                                    });
                                }
                              },
                        child: const Text('Undo last set'),
                      ),
                      TextButton(
                        onPressed: c.busy
                            ? null
                            : () async {
                                if (await confirm(
                                  context,
                                  'Reset draft?',
                                  'Only this draft is deleted. Completed history stays.',
                                )) {
                                  if (await action(
                                    () => c.repository.reset(draft.id),
                                    'Draft reset',
                                  )) {
                                    if (mounted)
                                      setState(() {
                                        editIndex = null;
                                        reps.clear();
                                      });
                                  }
                                }
                              },
                        child: const Text('Reset draft'),
                      ),
                    ],
                  ),
                  FilledButton(
                    onPressed:
                        c.busy || draft.actualSets.length != draft.targetSets
                        ? null
                        : () async {
                            if (await action(
                              () => c.repository.finish(draft.id),
                              'Workout recorded',
                            )) {
                              if (mounted)
                                setState(() {
                                  finished = true;
                                  editIndex = null;
                                  reps.clear();
                                });
                            }
                          },
                    child: const Text('Finish session'),
                  ),
                ],
                if (c.busy)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: LinearProgressIndicator(),
                  ),
                if (error != null) Notice(error!),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: c.busy
                      ? null
                      : () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => Scaffold(
                              appBar: AppBar(title: const Text('Plan history')),
                              body: HistoryScreen(
                                controller: c,
                                planId: widget.planId,
                              ),
                            ),
                          ),
                        ),
                  child: const Text('View history'),
                ),
                TextButton(
                  onPressed: c.busy
                      ? null
                      : () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                PlanEditor(controller: c, original: plan),
                          ),
                        ),
                  child: const Text('Edit plan'),
                ),
                TextButton(
                  onPressed: c.busy ? null : deletePlan,
                  child: const Text('Delete plan'),
                ),
              ],
            );
      return PopScope(
        canPop: allowPop,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) leave();
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Your quest'),
            leading: IconButton(
              onPressed: c.busy ? null : leave,
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Leave workout',
            ),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: body,
            ),
          ),
        ),
      );
    },
  );
}
