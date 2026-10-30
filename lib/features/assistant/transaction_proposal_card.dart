import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../../ui/components.dart';

/// An explicit category choice, reviewed before mutation. No category is inferred.
class TransactionProposalCard extends ConsumerStatefulWidget {
  const TransactionProposalCard({super.key, required this.transactionId});
  final String transactionId;
  @override
  ConsumerState<TransactionProposalCard> createState() =>
      _TransactionProposalCardState();
}

class _TransactionProposalCardState
    extends ConsumerState<TransactionProposalCard> {
  String? selected;
  bool applied = false;
  @override
  Widget build(BuildContext context) {
    final s = ref.watch(storeProvider);
    final found = s.data.entries.where(
      (e) => e.id == widget.transactionId && e.isSpend,
    );
    if (found.isEmpty) {
      return const Notice(
        'Select a spending transaction from its detail page to change its category.',
      );
    }
    final entry = found.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Choose how to categorize it.',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        DataRowTile(
          entry.merchant,
          s.amount(entry.amount, decimals: true),
          subtitle: 'Reference ${entry.id}',
        ),
        DataRowTile('Current category', entry.category),
        DropdownButtonFormField<String>(
          value: selected,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Proposed category'),
          items: categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) => setState(() {
            selected = v;
            applied = false;
          }),
        ),
        const SizedBox(height: 16),
        const Muted(
          'This changes the category and related spending summaries. The transaction amount and account remain unchanged.',
        ),
        const SizedBox(height: 16),
        if (applied) const Notice('Category updated. No money moved.'),
        FilledButton(
          onPressed:
              selected == null ||
                  selected == entry.category ||
                  s.busy ||
                  s.hidden
              ? null
              : () async {
                  final before = entry.category, after = selected!;
                  final approved = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Review category change'),
                      content: Text(
                        '${entry.merchant}\n${s.amount(entry.amount, decimals: true)}\n\n$before → $after\n\nYou can undo this change.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Apply category'),
                        ),
                      ],
                    ),
                  );
                  if (approved != true || !mounted) return;
                  final latest = s.data.entries.where((e) => e.id == entry.id);
                  if (latest.isEmpty || latest.first.category != before) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'This transaction changed. Review its current category again.',
                        ),
                      ),
                    );
                    return;
                  }
                  final ok = await s.categorize(entry.id, after);
                  if (mounted && ok) setState(() => applied = true);
                },
          child: const Text('Review category change'),
        ),
        if (s.hidden)
          const Muted(
            'Show balances in Settings before reviewing this change.',
          ),
        if (applied && s.canUndo)
          TextButton(
            onPressed: s.busy
                ? null
                : () async {
                    final ok = await s.undo();
                    if (mounted && ok) setState(() => applied = false);
                  },
            child: const Text('Undo last change'),
          ),
      ],
    );
  }
}
