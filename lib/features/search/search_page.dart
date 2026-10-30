import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/store.dart';
import '../../ui/components.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});
  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final controller = TextEditingController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(storeProvider);
    final q = controller.text.trim().toLowerCase();
    const sections = [
      ('Wealth', 'net worth assets liabilities accounts', '/wealth'),
      ('Investments', 'portfolio stocks mutual funds', '/investments'),
      (
        'Fixed deposits',
        'fd maturity interest',
        '/investments?type=Fixed%20deposits',
      ),
      (
        'Spending & transactions',
        'expenses payments merchant categories history',
        '/spending',
      ),
      ('Savings goals', 'goals emergency japan saving', '/goals'),
      ('Credit health', 'credit score utilization', '/credit'),
    ];
    final sectionMatches = sections
        .where((r) => q.isEmpty || '${r.$1} ${r.$2}'.toLowerCase().contains(q))
        .toList();
    final holdings = q.isEmpty
        ? s.data.holdings.take(0)
        : s.data.holdings.where(
            (h) => '${h.name} ${h.type}'.toLowerCase().contains(q),
          );
    final goals = q.isEmpty
        ? s.data.goals.take(0)
        : s.data.goals.where((g) => g.name.toLowerCase().contains(q));
    final transactions = q.isEmpty
        ? s.data.entries.take(0)
        : s.data.entries.where(
            (e) =>
                '${e.merchant} ${e.category} ${e.id}'.toLowerCase().contains(q),
          );
    final groceryIntent =
        q.contains('grocer') &&
        (q.contains('last month') ||
            q.contains('september') ||
            q.contains('october') ||
            q.contains('this month'));
    final noResults =
        sectionMatches.isEmpty &&
        holdings.isEmpty &&
        goals.isEmpty &&
        transactions.isEmpty &&
        !groceryIntent;
    return PageFrame(
      title: 'Find your way',
      actions: const [],
      children: [
        TextField(
          controller: controller,
          autofocus: true,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: 'Search your finances',
            hintText: 'Try “FD” or “last month groceries”',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: q.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: () => setState(controller.clear),
                    icon: const Icon(Icons.close),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        const Muted(
          'Jump to a section, holding, goal or transaction. Dates use the demo reference date: 30 October 2026.',
        ),
        if (groceryIntent)
          Panel(
            onTap: () => context.push(
              '/spending?category=Groceries&month=${q.contains('last month') || q.contains('september') ? 9 : 10}',
            ),
            child: DataRowTile(
              'Groceries',
              q.contains('last month') || q.contains('september')
                  ? 'September'
                  : 'October',
              subtitle:
                  'Open matching transactions · You can change these filters',
            ),
          ),
        if (sectionMatches.isNotEmpty) ...[
          SectionTitle(q.isEmpty ? 'Explore your finances' : 'Sections'),
          Panel(
            child: Column(
              children: [
                for (final r in sectionMatches)
                  DataRowTile(r.$1, '', onTap: () => context.push(r.$3)),
              ],
            ),
          ),
        ],
        if (holdings.isNotEmpty) ...[
          const SectionTitle('Holdings'),
          Panel(
            child: Column(
              children: [
                for (final h in holdings)
                  DataRowTile(
                    h.name,
                    s.amount(h.value),
                    subtitle: h.type,
                    onTap: () => context.push('/holdings/${h.id}'),
                  ),
              ],
            ),
          ),
        ],
        if (goals.isNotEmpty) ...[
          const SectionTitle('Goals'),
          Panel(
            child: Column(
              children: [
                for (final g in goals)
                  DataRowTile(
                    g.name,
                    s.amount(g.saved),
                    onTap: () => context.push('/goals/${g.id}'),
                  ),
              ],
            ),
          ),
        ],
        if (transactions.isNotEmpty) ...[
          SectionTitle('Transactions · ${transactions.length}'),
          Panel(
            child: Column(
              children: [
                for (final e in transactions)
                  DataRowTile(
                    e.merchant,
                    s.amount(e.amount, decimals: true),
                    subtitle: '${e.date.day}/${e.date.month} · ${e.category}',
                    onTap: () => context.push('/transactions/${e.id}'),
                  ),
              ],
            ),
          ),
        ],
        if (noResults)
          const Padding(
            padding: EdgeInsets.only(top: 24),
            child: Notice(
              'No matching records. Try a merchant, “fixed deposits”, “goals”, or “last month groceries”.',
            ),
          ),
      ],
    );
  }
}
