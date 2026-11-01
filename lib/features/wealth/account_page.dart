import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/store.dart';
import '../../ui/components.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!const ['everyday', 'savings', 'credit'].contains(id)) {
      return const PageFrame(
        title: 'Account',
        children: [Notice('This account is unavailable.')],
      );
    }
    final s = ref.watch(storeProvider);
    final name = id == 'savings'
        ? 'Savings account'
        : id == 'credit'
        ? 'Credit card'
        : 'Everyday account';
    final balance = id == 'savings'
        ? 210000
        : id == 'credit'
        ? 48500
        : 186500;
    final records = s.data.entries.where((e) => e.account == name).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return PageFrame(
      title: name,
      children: [
        Muted(id == 'credit' ? 'OUTSTANDING BALANCE' : 'BALANCE'),
        Amount(balance, size: 36),
        const SizedBox(height: 14),
        const Notice(
          'Balance snapshot as of 30 October 2026. The transactions below are not a complete account ledger.',
        ),
        if (id == 'savings') ...[
          const SectionTitle('Allocated savings'),
          Panel(
            child: Column(
              children: [
                for (final g in s.data.goals)
                  DataRowTile(
                    g.name,
                    s.amount(g.saved),
                    onTap: () => context.push('/goals/${g.id}'),
                  ),
              ],
            ),
          ),
          const Muted('Goal allocation is a planning view, not a transfer.'),
        ] else ...[
          const SectionTitle('Activity'),
          Panel(
            child: Column(
              children: records
                  .map(
                    (e) => DataRowTile(
                      e.merchant,
                      s.amount(e.amount, decimals: true),
                      subtitle:
                          '${e.isManual ? 'You added · ' : ''}${e.date.day}/${e.date.month}/2026 · ${e.kind}',
                      onTap: () => context.push('/transactions/${e.id}'),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ],
    );
  }
}
