import '../../core/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/store.dart';
import '../../ui/components.dart';

class GoalPage extends ConsumerWidget {
  const GoalPage({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(storeProvider);
    final found = s.data.goals.where((g) => g.id == id);
    if (found.isEmpty) {
      return const PageFrame(
        title: 'Goal',
        children: [Notice('This goal is unavailable.')],
      );
    }
    final g = found.first;
    final projected = g.saved + g.monthly * g.monthsLeft;
    return PageFrame(
      title: g.name,
      children: [
        const Muted('SAVED SO FAR'),
        Amount(g.saved, size: 38),
        const SizedBox(height: 8),
        Muted('of ${s.amount(g.target)} · by ${shortDate(g.deadline)}'),
        const SizedBox(height: 24),
        if (!s.hidden) ProgressLine(g.progress),
        const SizedBox(height: 14),
        Text(
          s.hidden
              ? 'Progress hidden'
              : '${(g.progress * 100).round()}% of the way there',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SectionTitle('Your path forward'),
        Panel(
          child: Column(
            children: [
              DataRowTile('Remaining', s.amount(g.remaining)),
              DataRowTile('Monthly contribution plan', s.amount(g.monthly)),
              DataRowTile('Contribution months remaining', '${g.monthsLeft}'),
              DataRowTile('Required per month', s.amount(g.requiredMonthly)),
              DataRowTile('Projected at deadline', s.amount(projected)),
            ],
          ),
        ),
        Notice(
          projected >= g.target
              ? 'Your planned contributions would reach the target by the deadline.'
              : 'At the current plan, you would be ${s.amount(g.target - projected)} short. Review a revised plan below.',
        ),
        const SizedBox(height: 14),
        const Muted(
          'Projection assumes one contribution per month starting next month, no interest, no withdrawals, and an unchanged target. This edits a plan; no money moves.',
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: () => context.push(
            '/assistant?q=${Uri.encodeComponent('Help with goal ${g.id}')}',
          ),
          child: const Text('Review a suggested plan'),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => context.push('/goals/${g.id}/edit'),
          child: const Text('Edit goal'),
        ),
        const SectionTitle('Contribution history'),
        if (g.contributions.isEmpty)
          const Panel(
            child: Muted(
              'No contributions yet. New goals start with zero saved.',
            ),
          )
        else
          Panel(
            child: Column(
              children: [
                for (var i = 0; i < g.contributions.length; i++)
                  DataRowTile(
                    monthName(5 + i),
                    s.amount(g.contributions[i]),
                    subtitle: '2026 · Savings allocation',
                  ),
              ],
            ),
          ),
        if (s.canUndo)
          TextButton(
            onPressed: s.busy
                ? null
                : () =>
                      reportChange(context, s, s.undo(), 'Last change undone'),
            child: const Text('Undo last change'),
          ),
      ],
    );
  }
}
