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
  late int selectedYear;
  late String? category;
  late TextEditingController query;
  bool yearView = false;
  String account = 'All accounts', kind = 'Spending';
  @override
  void initState() {
    super.initState();
    month = widget.initialMonth;
    selectedYear = demoYear;
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
                const Muted('All listed transactions have Completed status.'),
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
                  e.date.year == selectedYear &&
                  (yearView || e.date.month == month) &&
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
        (yearView
                ? d.yearCategoryTotals(selectedYear)
                : d.categoryTotals(month, year: selectedYear))
            .entries
            .where((e) => e.value > 0)
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    final total = yearView
        ? d
              .monthlySpendTotals(selectedYear)
              .fold<double>(0, (sum, value) => sum + value)
        : d.spendTotal(month, year: selectedYear);
    final selectedChange = yearView || category == null
        ? null
        : d.spendTotal(month, category: category, year: selectedYear) -
              d.spendTotal(month - 1, category: category, year: selectedYear);
    final manualCount = d.entries
        .where(
          (entry) =>
              entry.isManual &&
              entry.date.year == selectedYear &&
              (yearView || entry.date.month == month) &&
              entry.isSpend,
        )
        .length;
    return PageFrame(
      title: 'Spending & activity',
      actions: [
        IconButton(
          tooltip: 'Search your finances',
          onPressed: () => context.push('/search'),
          icon: const Icon(Icons.search_rounded),
        ),
        const SizedBox(width: 6),
      ],
      children: [
        SizedBox(
          height: 50,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                for (final entry in List.generate(
                  12,
                  (index) => (index + 1, monthName(index + 1)),
                )..add((0, 'Overview')))
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() {
                        yearView = entry.$1 == 0;
                        if (!yearView) month = entry.$1;
                      }),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              entry.$2,
                              style: TextStyle(
                                fontWeight:
                                    (yearView
                                        ? entry.$1 == 0
                                        : month == entry.$1)
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color:
                                    (yearView
                                        ? entry.$1 == 0
                                        : month == entry.$1)
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 6),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              height: 2,
                              width: 28,
                              color:
                                  (yearView ? entry.$1 == 0 : month == entry.$1)
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Muted(
                      yearView ? 'TOTAL YEAR SPENDING' : 'TOTAL MONTH SPENDING',
                    ),
                  ),
                  TextButton.icon(
                    key: const ValueKey('spending-add-expense'),
                    onPressed: () => context.push('/expenses/new'),
                    icon: const Icon(Icons.add_rounded, size: 17),
                    label: const Text('Add expense'),
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Amount(total, size: 36),
              const SizedBox(height: 8),
              Muted(
                yearView
                    ? 'January–December · $selectedYear'
                    : month == 1
                    ? 'January · $selectedYear'
                    : '${s.amount(total - d.spendTotal(month - 1, year: selectedYear))} change vs ${monthName(month - 1)}',
              ),
              if (category != null) ...[
                const SizedBox(height: 14),
                Notice(
                  '$category · '
                  '${selectedChange == null || selectedChange == 0 ? 'unchanged' : '${selectedChange > 0 ? '+' : '-'}${s.amount(selectedChange.abs())}'} '
                  'vs ${monthName(month - 1)}',
                ),
              ],
              if (manualCount > 0) ...[
                const SizedBox(height: 10),
                Muted(
                  '$manualCount expense${manualCount == 1 ? '' : 's'} added by you',
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 10),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Spending shape',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.touch_app_outlined,
                    size: 17,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 5),
                  Muted(yearView ? '$selectedYear' : 'Tap to filter'),
                ],
              ),
              const SizedBox(height: 2),
              Divider(
                height: 18,
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: 0.6),
              ),
              CategorySpiderChart(
                categories: totals.map((entry) => entry.key).toList(),
                values: totals.map((entry) => entry.value).toList(),
                colors: totals
                    .map(
                      (entry) => categoryColors[categories.indexOf(entry.key)],
                    )
                    .toList(),
                selectedCategory: category,
                monthlyTotals: yearView
                    ? d.monthlySpendTotals(selectedYear)
                    : null,
                monthlyTitle: yearView ? '$selectedYear spending' : null,
                monthlyLabels: yearView
                    ? const [
                        'January',
                        'February',
                        'March',
                        'April',
                        'May',
                        'June',
                        'July',
                        'August',
                        'September',
                        'October',
                        'November',
                        'December',
                      ]
                    : null,
                onCategoryTap: (value) => setState(() {
                  category = category == value ? null : value;
                  kind = 'Spending';
                }),
              ),
            ],
          ),
        ),
        const AskButton('Why did spending increase?'),
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Transactions',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              TextButton.icon(
                onPressed: filters,
                icon: const Icon(Icons.tune_rounded, size: 17),
                label: const Text('Filter'),
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ),
        TextField(
          controller: query,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            hintText: 'Search merchant or category',
            suffixIcon: query.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      query.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.close_rounded, size: 18),
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Muted('${filtered.length} records'),
              const Spacer(),
              Text(
                '${s.amount(filtered.fold<double>(0, (v, e) => v + e.spend))} net',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        if (filtered.isEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
          )
        else
          Column(
            children: [
              for (var i = 0; i < filtered.length; i++) ...[
                DataRowTile(
                  filtered[i].merchant,
                  '${filtered[i].kind == 'income' || filtered[i].kind == 'refund' ? '+' : ''}${s.amount(filtered[i].amount, decimals: true)}',
                  subtitle:
                      '${filtered[i].isManual ? 'You added · ' : ''}${filtered[i].date.day} ${monthName(filtered[i].date.month)} · ${filtered[i].category}',
                  color:
                      categoryColors[categories
                          .indexOf(filtered[i].category)
                          .clamp(0, categoryColors.length - 1)],
                  onTap: () => context.push('/transactions/${filtered[i].id}'),
                ),
                if (i < filtered.length - 1) const Divider(height: 1),
              ],
            ],
          ),
      ],
    );
  }
}
