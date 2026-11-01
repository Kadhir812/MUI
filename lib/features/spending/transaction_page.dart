import '../../core/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../../ui/components.dart';

class TransactionPage extends ConsumerWidget {
  const TransactionPage({super.key, required this.id});
  final String id;
  Future<void> editCategory(
    BuildContext context,
    FinanceStore store,
    Entry entry,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose category',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                for (final c in categories)
                  ListTile(
                    title: Text(c),
                    trailing: c == entry.category
                        ? const Icon(Icons.check)
                        : null,
                    onTap: () => Navigator.pop(ctx, c),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    if (selected != null && selected != entry.category && context.mounted) {
      await reportChange(
        context,
        store,
        store.categorize(entry.id, selected),
        'Category updated to $selected',
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(storeProvider);
    final found = s.data.entries.where((e) => e.id == id);
    if (found.isEmpty) {
      return const PageFrame(
        title: 'Transaction',
        children: [Notice('This transaction is unavailable.')],
      );
    }
    final e = found.first;
    return PageFrame(
      title: 'Transaction detail',
      children: [
        const SizedBox(height: 12),
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.receipt_long_outlined, size: 34),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            e.merchant,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 10),
        Center(child: Amount(e.amount, size: 36, decimals: true)),
        const SizedBox(height: 8),
        Center(child: Muted('${e.status} · ${e.kind}')),
        const SizedBox(height: 26),
        Panel(
          child: Column(
            children: [
              DataRowTile('Date', shortDate(e.date)),
              DataRowTile('Account', e.account),
              DataRowTile('Category', e.category),
              DataRowTile('Reference', e.id.toUpperCase()),
              const DataRowTile('Currency', 'INR'),
              DataRowTile('Notes', e.note.isEmpty ? 'No notes' : e.note),
            ],
          ),
        ),
        if (e.isSpend)
          FilledButton(
            onPressed: s.busy ? null : () => editCategory(context, s, e),
            child: const Text('Change category'),
          ),
        const SizedBox(height: 12),
        if (e.isSpend) AskButton('Categorize transaction ${e.id}'),
        if (s.canUndo)
          OutlinedButton(
            onPressed: s.busy
                ? null
                : () =>
                      reportChange(context, s, s.undo(), 'Last change undone'),
            child: const Text('Undo last change'),
          ),
        const SizedBox(height: 20),
        Muted(
          e.isManual
              ? e.kind == 'income'
                    ? 'Income added by you. It updates recorded income totals but does not change sample account balances or net worth.'
                    : 'Expense added by you. It updates spending totals but does not change sample account balances or net worth.'
              : 'Sample transaction. Category changes update spending totals and assistant explanations immediately.',
        ),
      ],
    );
  }
}
