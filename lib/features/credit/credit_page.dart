import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/store.dart';
import '../../ui/components.dart';

class CreditPage extends ConsumerWidget {
  const CreditPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(storeProvider);
    return PageFrame(
      title: 'Credit health',
      children: [
        const Muted('ILLUSTRATIVE CREDIT SCORE'),
        const SizedBox(height: 12),
        Text(
          s.hidden ? '•••' : '782',
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w600,
            letterSpacing: -2,
          ),
        ),
        const Text('Healthy in this demo', style: TextStyle(fontSize: 20)),
        const SizedBox(height: 22),
        if (!s.hidden) const ProgressLine((782 - 300) / 600),
        const SizedBox(height: 10),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Muted('300'), Muted('Demo range'), Muted('900')],
        ),
        const SizedBox(height: 22),
        const Notice(
          'This is a simulated score, not a report from a credit bureau. The range and factors are illustrative; no credit check has been performed.',
        ),
        const SectionTitle('What contributes'),
        Panel(
          child: Column(
            children: [
              const DataRowTile(
                'Payment record',
                'On time',
                subtitle: '12 of 12 sample payments',
              ),
              DataRowTile(
                'Credit utilization',
                s.hidden ? '••••' : '24.25%',
                subtitle:
                    '${s.amount(48500)} balance / ${s.amount(200000)} limit',
              ),
              const DataRowTile('Credit age', '4 years 2 months'),
              const DataRowTile('Recent enquiries', '1 in 6 months'),
            ],
          ),
        ),
        const SectionTitle('Score history'),
        Panel(child: ScoreHistory(hidden: s.hidden)),
        const DataRowTile('Updated', '28 Oct 2026'),
        const DataRowTile('Provider', 'Demo dataset'),
        const AskButton('Explain my credit health'),
      ],
    );
  }
}

class ScoreHistory extends StatelessWidget {
  const ScoreHistory({super.key, required this.hidden});
  final bool hidden;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final item in const [
        ('May', 752),
        ('June', 758),
        ('July', 764),
        ('August', 771),
        ('September', 778),
        ('October', 782),
      ])
        DataRowTile(item.$1, hidden ? '•••' : '${item.$2}'),
    ],
  );
}
