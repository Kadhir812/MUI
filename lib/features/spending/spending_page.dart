import '../../core/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../../ui/components.dart';
import '../../ui/charts.dart';

class SpendingPage extends ConsumerStatefulWidget {
  const SpendingPage({
    super.key,
    this.initialCategory,
    this.initialMonth = 10,
    this.initialQuery = '',
  });
  final String? initialCategory;
  final int initialMonth;
  final String initialQuery;
  @override
  ConsumerState<SpendingPage> createState() => _SpendingPageState();
}

class _SpendingPageState extends ConsumerState<SpendingPage> {
  late int month;
  late String? category;
  late TextEditingController query;
  String account = 'All accounts', kind = 'Spending', chart = 'Categories';
  @override
  void initState() {
    super.initState();
    month = widget.initialMonth;
    category = widget.initialCategory;
    query = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    query.dispose();
    super.dispose();
  }

  Future<void> filters() async {
    var nextAccount = account, nextKind = kind;
    final applied = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, update) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Filter activity',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 18),
                const Text('Account'),
                Choices(
                  items: const [
                    'All accounts',
                    'Everyday account',
                    'Credit card',
                  ],
                  selected: nextAccount,
                  onSelect: (v) => update(() => nextAccount = v),
                ),
                const Text('Activity'),
                Choices(
                  items: const [
                    'Spending',
                    'All activity',
                    'Income',
                    'Transfers',
                  ],
                  selected: nextKind,
                  onSelect: (v) => update(() => nextKind = v),
                ),
                const Muted('All sample transactions have Completed status.'),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Apply filters'),
                ),
                TextButton(
                  onPressed: () => update(() {
                    nextAccount = 'All accounts';
                    nextKind = 'Spending';
                  }),
                  child: const Text('Reset filters'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (applied == true && mounted) {
      setState(() {
        account = nextAccount;
        kind = nextKind;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(storeProvider), d = s.data;
    final filtered =
        d.entries
            .where(
              (e) =>
                  e.date.month == month &&
                  (category == null || e.category == category) &&
                  (account == 'All accounts' || e.account == account) &&
                  (kind == 'All activity' ||
                      kind == 'Spending' && e.isSpend ||
                      kind == 'Income' && e.kind == 'income' ||
                      kind == 'Transfers' && e.kind == 'transfer') &&
                  (query.text.isEmpty ||
                      '${e.merchant} ${e.category}'.toLowerCase().contains(
                        query.text.toLowerCase(),
                      )),
            )
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    final totals =
        d.categoryTotals(month).entries.where((e) => e.value > 0).toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    final total = d.spendTotal(month);
    final manualCount = d.entries
        .where(
          (entry) =>
              entry.isManual &&
              entry.date.year == 2026 &&
              entry.date.month == month &&
              entry.isSpend,
        )
        .length;
    final weekly = List.generate(
      5,
      (i) => d
          .spending(month)
          .where((e) => (e.date.day - 1) ~/ 7 == i)
          .fold<double>(0, (v, e) => v + e.spend),
    );
    return PageFrame(
      title: 'Spending & activity',
      actions: [
        IconButton(
          key: const ValueKey('spending-add-expense'),
          tooltip: 'Add expense',
          onPressed: () => context.push('/expenses/new'),
          icon: const Icon(Icons.add_rounded),
        ),
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
          onSelect: (v) => setState(
            () => month = ['August', 'September', 'October'].indexOf(v) + 8,
          ),
        ),
        const Muted('TOTAL MONTH SPENDING'),
        Amount(total, size: 36),
        const SizedBox(height: 8),
        Muted(
          month == 8
              ? 'August sample · 2026'
              : '${s.amount(total - d.spendTotal(month - 1))} change vs ${monthName(month - 1)}',
        ),
        const SizedBox(height: 8),
        if (manualCount > 0) ...[
          const SizedBox(height: 6),
          Muted(
            '$manualCount expense${manualCount == 1 ? '' : 's'} added by you',
          ),
        ],
        const SizedBox(height: 8),
        const Notice(
          'Sample transactions only—not a complete bank history. Spending totals include listed expenses and refunds, exclude income and transfers, and do not reconcile account balances.',
        ),
        const Muted(
          'Through day 30. Charts show the full sample month; filters below affect the record list. Summaries round to rupees; records show paise.',
        ),
        Choices(
          items: const ['Categories', 'Weekly trend'],
          selected: chart,
          onSelect: (v) => setState(() => chart = v),
        ),
        if (chart == 'Categories')
          Panel(
            child: Column(
              children: [
                for (final entry in totals)
                  InkWell(
                    onTap: () => setState(() {
                      category = category == entry.key ? null : entry.key;
                      kind = 'Spending';
                    }),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${entry.key}${category == entry.key ? ' · Selected' : ''}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(s.amount(entry.value)),
                            ],
                          ),
                          const SizedBox(height: 9),
                          if (!s.hidden)
                            ProgressLine(
                              entry.value / totals.first.value,
                              color:
                                  categoryColors[categories.indexOf(entry.key)],
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          )
        else
          Panel(
            child: HistoryChart(
              values: weekly,
              labels: const ['1–7', '8–14', '15–21', '22–28', '29–30'],
              title: 'Weekly spending',
            ),
          ),
        const AskButton('Why did spending increase?'),
        SectionTitle('Transactions', action: 'Filters', onTap: filters),
        TextField(
          controller: query,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Find merchant or category',
            labelText: 'Search transactions',
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(label: Text('$kind · $account')),
            if (category != null)
              InputChip(
                label: Text(category!),
                onDeleted: () => setState(() => category = null),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Muted(
          '${filtered.length} records · ${s.amount(filtered.fold<double>(0, (v, e) => v + e.spend))} net spending in results',
        ),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          Panel(
            child: Column(
              children: [
                const Notice('No transactions match these filters.'),
                TextButton(
                  onPressed: () => setState(() {
                    category = null;
                    account = 'All accounts';
                    kind = 'Spending';
                    query.clear();
                  }),
                  child: const Text('Clear filters'),
                ),
              ],
            ),
          )
        else
          Panel(
            child: Column(
              children: filtered
                  .map(
                    (e) => DataRowTile(
                      e.merchant,
                      '${e.kind == 'income' || e.kind == 'refund' ? '+' : ''}${s.amount(e.amount, decimals: true)}',
                      subtitle:
                          '${e.isManual ? 'You added · ' : ''}${e.date.day} ${monthName(e.date.month)} · ${e.category}',
                      onTap: () => context.push('/transactions/${e.id}'),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}
