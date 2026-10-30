import '../../core/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/store.dart';
import '../../ui/components.dart';
import '../../ui/charts.dart';

class HoldingPage extends ConsumerWidget {
  const HoldingPage({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(storeProvider);
    final matches = s.data.holdings.where((h) => h.id == id);
    if (matches.isEmpty) {
      return const PageFrame(
        title: 'Holding',
        children: [Notice('This holding is unavailable.')],
      );
    }
    final h = matches.first;
    final fd = h.type == 'Fixed deposits';
    return PageFrame(
      title: h.name,
      children: [
        Muted(h.type.toUpperCase()),
        const SizedBox(height: 10),
        Amount(h.value, size: 36),
        const SizedBox(height: 8),
        Muted(
          fd
              ? 'Principal balance · Interest paid at maturity'
              : s.hidden
              ? 'Return hidden'
              : '+${s.amount(h.gain)} · ${h.returnPercent.toStringAsFixed(2)}% since purchase',
        ),
        const SizedBox(height: 20),
        if (!fd)
          Panel(
            child: HistoryChart(
              values: h.history,
              labels: const ['May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'],
              title: '${h.name} value',
            ),
          ),
        const SectionTitle('Holding details'),
        Panel(
          child: Column(
            children: [
              DataRowTile(
                fd ? 'Principal' : 'Invested amount',
                s.amount(h.invested),
              ),
              if (!fd) ...[
                DataRowTile(
                  h.type == 'Stocks' ? 'Quantity' : 'Units',
                  s.hidden ? '••••' : h.units.toStringAsFixed(2),
                ),
                DataRowTile(
                  'Average cost per unit',
                  s.amount(h.cost, decimals: true),
                ),
                DataRowTile(
                  h.type == 'Stocks' ? 'Sample market price' : 'Sample NAV',
                  s.amount(h.price, decimals: true),
                ),
                DataRowTile('Unrealized gain', s.amount(h.gain)),
                const DataRowTile('Valuation date', '30 Oct 2026'),
              ] else ...[
                DataRowTile('Annual interest rate', '${h.rate}%'),
                const DataRowTile('Tenure', '12 months'),
                DataRowTile('Maturity date', shortDate(h.maturity!)),
                DataRowTile(
                  'Projected maturity value',
                  s.amount(h.maturityValue!),
                ),
                const DataRowTile('Payout', 'At maturity'),
                const DataRowTile('Status', 'Active'),
              ],
              DataRowTile('Start date', shortDate(h.purchaseDate)),
            ],
          ),
        ),
        if (fd)
          const Notice(
            'Projection uses simple interest: principal × 7% × 1 year. Illustrative gross payout, before tax. No accrued interest is added to net worth.',
          ),
        const SectionTitle('Investment activity'),
        Panel(
          child: DataRowTile(
            fd ? 'Deposit opened' : 'Initial purchase',
            s.amount(h.invested),
            subtitle:
                '${shortDate(h.purchaseDate)} · ${h.id.toUpperCase()}-BUY-001',
          ),
        ),
        const Muted(
          'Complete activity for this sample holding. No subsequent purchases, sales or withdrawals.',
        ),
        const AskButton('Explain my portfolio'),
      ],
    );
  }
}
