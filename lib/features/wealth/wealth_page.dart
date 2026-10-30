import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/store.dart';
import '../../ui/components.dart';
import '../../ui/charts.dart';

class WealthPage extends ConsumerStatefulWidget {
  const WealthPage({super.key});
  @override
  ConsumerState<WealthPage> createState() => _WealthPageState();
}

class _WealthPageState extends ConsumerState<WealthPage> {
  String period = '6 months';
  @override
  Widget build(BuildContext context) {
    final s = ref.watch(storeProvider), d = s.data;
    final start = period == '3 months' ? 3 : 0;
    final history = d.wealthHistory.sublist(start);
    final change = history.last - history.first;
    return PageFrame(
      title: 'Your wealth',
      children: [
        const Muted('NET WORTH · 30 OCTOBER 2026'),
        const SizedBox(height: 10),
        Amount(d.netWorth, size: 38),
        const SizedBox(height: 8),
        Muted('${s.amount(change)} growth across selected snapshots'),
        Choices(
          items: const ['3 months', '6 months'],
          selected: period,
          onSelect: (v) => setState(() => period = v),
        ),
        Panel(
          child: HistoryChart(
            values: history,
            labels: ['May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'].sublist(start),
          ),
        ),
        const SectionTitle('What you own'),
        Panel(
          child: Column(
            children: [
              DataRowTile(
                'Everyday account',
                s.amount(186500),
                subtitle: 'Available balance · Ending 2048',
                onTap: () => context.push('/accounts/everyday'),
              ),
              DataRowTile(
                'Savings account',
                s.amount(210000),
                subtitle: 'Allocated across your goals',
                onTap: () => context.push('/accounts/savings'),
              ),
              DataRowTile(
                'Investments',
                s.amount(d.investmentValue),
                subtitle: '5 holdings · Marked to sample prices',
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
                s.amount(48500),
                subtitle: 'Outstanding balance · Ending 1182',
                onTap: () => context.push('/accounts/credit'),
              ),
              const Divider(),
              DataRowTile('Total liabilities', s.amount(48500)),
            ],
          ),
        ),
        const SectionTitle('How this is calculated'),
        Panel(
          child: Column(
            children: [
              DataRowTile('Assets', s.amount(d.assets)),
              DataRowTile('Less liabilities', s.amount(48500)),
              const Divider(),
              DataRowTile('Net worth', s.amount(d.netWorth)),
            ],
          ),
        ),
        const Notice(
          'Goal savings are already included in your savings account. They are not added again. Fixed deposits are valued at principal; projected interest is shown separately.',
        ),
        const AskButton('Explain my wealth'),
      ],
    );
  }
}
