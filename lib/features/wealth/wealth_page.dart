import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../../ui/charts.dart';
import '../../ui/components.dart';

class WealthPage extends ConsumerWidget {
  const WealthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(storeProvider);
    final d = s.data;
    final cash = FinancialData.everyday + FinancialData.savings;
    final liabilities = FinancialData.liabilities;
    final previousIndex = d.wealthHistory.length - 2;
    final cashChange = cash - d.cashHistory[previousIndex];
    final investmentChange =
        d.investmentValue - d.portfolioHistory[previousIndex];
    final debtReduction = d.liabilityHistory[previousIndex] - liabilities;
    final netWorthChange = d.netWorth - d.wealthHistory[previousIndex];

    return PageFrame(
      title: 'Wealth',
      children: [
        const Muted('BALANCE SHEET · 30 OCTOBER 2026'),
        const SizedBox(height: 8),
        Amount(d.netWorth, size: 38),
        const SizedBox(height: 4),
        Muted(
          s.hidden
              ? 'Your balances are hidden.'
              : '${s.amount(d.assets)} owned  −  ${s.amount(liabilities)} owed',
        ),
        const SizedBox(height: 18),

        const SectionTitle('Monthly net worth'),
        const Muted(
          'What you own minus what you owe. Each point is a month-end snapshot.',
        ),
        Panel(
          padding: 14,
          child: HistoryChart(
            values: d.wealthHistory,
            labels: const ['May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'],
            showTimeframes: true,
          ),
        ),

        const SectionTitle('What you own'),
        Panel(
          child: Column(
            children: [
              DataRowTile(
                'Everyday account',
                s.amount(FinancialData.everyday),
                subtitle: 'Available balance · Ending 2048',
                onTap: () => context.push('/accounts/everyday'),
              ),
              DataRowTile(
                'Savings account',
                s.amount(FinancialData.savings),
                subtitle: 'Includes money set aside for goals',
                onTap: () => context.push('/accounts/savings'),
              ),
              DataRowTile(
                'Investments',
                s.amount(d.investmentValue),
                subtitle:
                    '${d.holdings.length} holdings · current values',
                onTap: () => context.push('/investments'),
              ),
              const Divider(),
              DataRowTile('Total assets', s.amount(d.assets)),
            ],
          ),
        ),

        const SectionTitle('What you owe'),
        Panel(
          child: Column(
            children: [
              DataRowTile(
                'Credit card',
                s.amount(liabilities),
                subtitle: 'Outstanding balance · Ending 1182',
                onTap: () => context.push('/accounts/credit'),
              ),
              const Divider(),
              DataRowTile('Total owed', s.amount(liabilities)),
            ],
          ),
        ),

        const SectionTitle('Change since 30 September'),
        Panel(
          child: Column(
            children: [
              DataRowTile('Money in accounts', _signed(s, cashChange)),
              DataRowTile('Investment value', _signed(s, investmentChange)),
              DataRowTile('Lower card balance', _signed(s, debtReduction)),
              const Divider(),
              DataRowTile('Net worth change', _signed(s, netWorthChange)),
            ],
          ),
        ),
        const Notice(
          'Balances are month-end snapshots; recent transactions do not calculate them. Goal savings are already included in the savings account. Fixed deposits are valued at principal.',
        ),
        const AskButton('Explain these numbers'),
      ],
    );
  }

  String _signed(FinanceStore store, double value) =>
      '${value > 0
          ? '+'
          : value < 0
          ? '−'
          : ''}${store.amount(value.abs())}';
}
