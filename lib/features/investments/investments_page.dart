import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/store.dart';
import '../../ui/components.dart';
import '../../ui/charts.dart';

class InvestmentsPage extends ConsumerStatefulWidget {
  const InvestmentsPage({super.key, this.initialType});
  final String? initialType;
  @override
  ConsumerState<InvestmentsPage> createState() => _InvestmentsPageState();
}

class _InvestmentsPageState extends ConsumerState<InvestmentsPage> {
  String view = 'Allocation', period = '6 months';
  String? selected;
  bool nested = false;
  @override
  void initState() {
    super.initState();
    selected =
        const [
          'Stocks',
          'Mutual funds',
          'Fixed deposits',
        ].contains(widget.initialType)
        ? widget.initialType
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(storeProvider), d = s.data;
    final holdings = d.holdings
        .where((h) => selected == null || h.type == selected)
        .toList();
    final start = period == '3 months' ? 3 : 0;
    return PageFrame(
      title: 'Investments',
      children: [
        const Muted('PORTFOLIO VALUE'),
        const SizedBox(height: 8),
        Amount(d.investmentValue, size: 38),
        const SizedBox(height: 8),
        Muted(
          s.hidden
              ? 'Return hidden'
              : '+${s.amount(d.investmentValue - d.invested)} · ${(100 * (d.investmentValue / d.invested - 1)).toStringAsFixed(2)}% simple return since 1 May',
        ),
        Choices(
          items: const ['Allocation', 'Performance'],
          selected: view,
          onSelect: (v) => setState(() => view = v),
        ),
        if (view == 'Allocation')
          Panel(
            child: Column(
              children: [
                AllocationRing(
                  holdings: d.holdings,
                  selected: selected,
                  onSelect: (v) => setState(() => selected = v),
                  nested: nested,
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Show holdings ring',
                    style: TextStyle(fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Outer ring shows holdings within each category',
                  ),
                  value: nested,
                  onChanged: (v) => setState(() => nested = v),
                ),
              ],
            ),
          )
        else ...[
          Choices(
            items: const ['3 months', '6 months'],
            selected: period,
            onSelect: (v) => setState(() => period = v),
          ),
          Panel(
            child: HistoryChart(
              values: d.portfolioHistory.sublist(start),
              labels: ['May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'].sublist(start),
              title: 'Portfolio history',
            ),
          ),
          Panel(
            child: Column(
              children: [
                DataRowTile('Original investment', s.amount(d.invested)),
                DataRowTile('Contributions after purchase', s.amount(0)),
                DataRowTile(
                  'Gain since purchase',
                  s.amount(d.investmentValue - d.invested),
                ),
              ],
            ),
          ),
          const Notice(
            'This portfolio has no deposits or withdrawals after 1 May. Simple return = gain ÷ invested amount. It is not an annualized return. FD interest is excluded until payout.',
          ),
        ],
        SectionTitle(
          selected ?? 'All holdings',
          action: selected == null ? null : 'Show all',
          onTap: () => setState(() => selected = null),
        ),
        Panel(
          child: Column(
            children: holdings
                .map(
                  (h) => DataRowTile(
                    h.name,
                    s.amount(h.value),
                    subtitle: h.type,
                    onTap: () => context.push('/holdings/${h.id}'),
                  ),
                )
                .toList(),
          ),
        ),
        const Muted('Prices and products · Valued 30 October 2026. '),
        const AskButton('Explain my portfolio'),
      ],
    );
  }
}
