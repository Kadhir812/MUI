import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/formatters.dart';
import '../../data/store.dart';
import '../../ui/components.dart';

class IncomePage extends ConsumerStatefulWidget {
  const IncomePage({super.key, this.initialMonth = 10});

  final int initialMonth;

  @override
  ConsumerState<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends ConsumerState<IncomePage> {
  late int month = widget.initialMonth;

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(storeProvider);
    final data = store.data;
    final records = data.income(month);
    final total = data.incomeTotal(month);
    final previousTotal = month > 8 ? data.incomeTotal(month - 1) : null;

    return PageFrame(
      title: 'Income',
      actions: [
        IconButton(
          tooltip: 'Search your finances',
          onPressed: () => context.push('/search'),
          icon: const Icon(Icons.search_rounded),
        ),
        const SizedBox(width: 6),
      ],
      children: [
        Choices(
          items: const ['August', 'September', 'October'],
          selected: monthName(month),
          onSelect: (value) => setState(
            () => month = ['August', 'September', 'October'].indexOf(value) + 8,
          ),
        ),
        const Muted('RECORDED INCOME'),
        const SizedBox(height: 4),
        Amount(total, size: 36),
        const SizedBox(height: 6),
        Muted(
          previousTotal == null
              ? 'Income records for ${monthName(month)} 2026.'
              : store.hidden
              ? 'Monthly comparison hidden.'
              : '${store.amount((total - previousTotal).abs())} ${total >= previousTotal ? 'more' : 'less'} than ${monthName(month - 1)}.',
        ),
        const SizedBox(height: 12),
        const Notice(
          'Includes illustrative sample records and any income you add. Added income updates this history and cash-flow summaries, but does not change sample account balances or net worth.',
        ),
        const SectionTitle('Income records'),
        if (records.isEmpty)
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'No income recorded for this month.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                const Muted(
                  'Add a record to include it in your cash-flow view.',
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  key: const ValueKey('income-add-empty'),
                  onPressed: () => context.push('/income/new'),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add income'),
                ),
              ],
            ),
          )
        else
          Panel(
            child: Column(
              children: [
                for (final entry in records)
                  DataRowTile(
                    entry.merchant,
                    store.amount(entry.amount, decimals: true),
                    subtitle:
                        '${entry.isManual ? 'Added by you · ' : 'Sample · '}${shortDate(entry.date)} · ${entry.account}',
                    onTap: () => context.push('/transactions/${entry.id}'),
                  ),
              ],
            ),
          ),
        if (records.isNotEmpty)
          FilledButton.icon(
            key: const ValueKey('income-add-record'),
            onPressed: () => context.push('/income/new'),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add income'),
          ),
      ],
    );
  }
}
