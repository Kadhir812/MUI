import '../../core/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/store.dart';
import '../../ui/components.dart';

class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(storeProvider);
    return PageFrame(
      title: 'Your goals',
      children: [
        const Text(
          'Make room for\nwhat matters.',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 18),
        const Muted('A plan for your savings, one step at a time.'),
        const SizedBox(height: 24),
        for (final g in s.data.goals)
          Panel(
            onTap: () => context.push('/goals/${g.id}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  g.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text('${s.amount(g.saved)} of ${s.amount(g.target)}'),
                const SizedBox(height: 14),
                if (!s.hidden) ProgressLine(g.progress),
                const SizedBox(height: 14),
                Muted('By ${shortDate(g.deadline)} · View plan →'),
              ],
            ),
          ),
        if (s.data.goals.isEmpty)
          const Notice('Start with a goal that matters to you.'),
        FilledButton.icon(
          onPressed: () => context.push('/goals/new/edit'),
          icon: const Icon(Icons.add),
          label: const Text('Create a goal'),
        ),
        const SizedBox(height: 20),
        Notice(
          '${s.amount(s.data.allocatedSavings)} is allocated from your savings account. Goal balances are not additional assets.',
        ),
      ],
    );
  }
}
