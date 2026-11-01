import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../../ui/components.dart';

class BalanceSheetPage extends ConsumerWidget {
  const BalanceSheetPage({super.key, required this.section});

  final String section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(storeProvider);
    final data = store.data;
    final isAssets = section == 'assets';
    if (!isAssets && section != 'liabilities') {
      return const PageFrame(
        title: 'Balance sheet',
        children: [Notice('This balance sheet section is unavailable.')],
      );
    }

    return PageFrame(
      title: isAssets ? 'Assets' : 'Liabilities',
      children: [
        Muted(
          isAssets
              ? 'WHAT YOU OWN · 30 OCTOBER 2026'
              : 'WHAT YOU OWE · 30 OCTOBER 2026',
        ),
        const SizedBox(height: 8),
        Amount(isAssets ? data.assets : FinancialData.liabilities, size: 36),
        const SizedBox(height: 8),
        const Muted('Net worth = total assets − total liabilities.'),
        const SectionTitle('Items'),
        Panel(
          child: Column(
            children: isAssets
                ? [
                    DataRowTile(
                      'Everyday account',
                      store.amount(FinancialData.everyday),
                      subtitle: 'Available balance · Ending 2048',
                      onTap: () => context.push('/accounts/everyday'),
                    ),
                    DataRowTile(
                      'Savings account',
                      store.amount(FinancialData.savings),
                      subtitle: 'Includes money set aside for goals',
                      onTap: () => context.push('/accounts/savings'),
                    ),
                    for (final holding in data.holdings)
                      DataRowTile(
                        holding.name,
                        store.amount(holding.value),
                        subtitle: holding.type,
                        onTap: () => context.push('/holdings/${holding.id}'),
                      ),
                    const Divider(),
                    DataRowTile('Total assets', store.amount(data.assets)),
                  ]
                : [
                    DataRowTile(
                      'Credit card',
                      store.amount(FinancialData.liabilities),
                      subtitle: 'Outstanding balance · Ending 1182',
                      onTap: () => context.push('/accounts/credit'),
                    ),
                    const Divider(),
                    DataRowTile(
                      'Total liabilities',
                      store.amount(FinancialData.liabilities),
                    ),
                  ],
          ),
        ),
        const Notice(
          'Illustrative snapshot dated 30 October 2026. Transactions do not reconcile these sample balances.',
        ),
      ],
    );
  }
}
