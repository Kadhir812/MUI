import '../../core/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../../ui/components.dart';

class GoalEditor extends ConsumerStatefulWidget {
  const GoalEditor({super.key, required this.id});
  final String id;
  @override
  ConsumerState<GoalEditor> createState() => _GoalEditorState();
}

class _GoalEditorState extends ConsumerState<GoalEditor> {
  final form = GlobalKey<FormState>();
  late TextEditingController name, target, monthly;
  late DateTime deadline;
  Goal? original;
  @override
  void initState() {
    super.initState();
    final found = ref
        .read(storeProvider)
        .data
        .goals
        .where((g) => g.id == widget.id);
    original = found.isEmpty ? null : found.first;
    name = TextEditingController(text: original?.name ?? '');
    target = TextEditingController(
      text: original?.target.toStringAsFixed(0) ?? '',
    );
    monthly = TextEditingController(
      text: original?.monthly.toStringAsFixed(0) ?? '',
    );
    deadline = original?.deadline ?? DateTime(2027, 10, 30);
  }

  @override
  void dispose() {
    name.dispose();
    target.dispose();
    monthly.dispose();
    super.dispose();
  }

  String? numberError(String? value, {bool isTarget = false}) {
    final n = double.tryParse(value ?? '');
    if (n == null || !n.isFinite || n < 0 || isTarget && n == 0) {
      return 'Enter a valid ${isTarget ? 'positive' : 'non-negative'} amount';
    }
    if (isTarget && n < (original?.saved ?? 0)) {
      return 'Target cannot be below the amount already saved';
    }
    if (n > 1000000000) return 'Use an amount below ₹100 crore for this demo';
    return null;
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    final store = ref.read(storeProvider);
    final goal = Goal(
      id: original?.id ?? 'g-${DateTime.now().microsecondsSinceEpoch}',
      name: name.text.trim(),
      target: double.parse(target.text),
      saved: original?.saved ?? 0,
      deadline: deadline,
      monthly: double.parse(monthly.text),
      contributions: original?.contributions ?? [],
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Review goal plan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goal.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                'Target: ${store.amount(goal.target)}\nMonthly plan: ${store.amount(goal.monthly)}\nDeadline: ${shortDate(goal.deadline)}',
              ),
              const SizedBox(height: 12),
              const Text('No funds are transferred. You can undo this change.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save plan'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final ok = await store.saveGoal(goal);
    if (!mounted) return;
    if (ok) {
      context.pop();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(store.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(storeProvider);
    return PageFrame(
      title: original == null ? 'New goal' : 'Edit goal',
      children: [
        if (s.hidden)
          const Notice(
            'Balances are hidden. Amount fields are concealed while you edit.',
          ),
        Form(
          key: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: name,
                maxLength: 60,
                decoration: const InputDecoration(labelText: 'Goal name'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Give your goal a name'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: target,
                obscureText: s.hidden,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Target amount (₹)',
                ),
                validator: (v) => numberError(v, isTarget: true),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: monthly,
                obscureText: s.hidden,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Planned monthly contribution (₹)',
                ),
                validator: numberError,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: deadline,
                    firstDate: demoDate.add(const Duration(days: 1)),
                    lastDate: DateTime(2040),
                  );
                  if (date != null && mounted) setState(() => deadline = date);
                },
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text('Deadline · ${shortDate(deadline)}'),
              ),
              const SizedBox(height: 20),
              const Notice(
                'This creates a savings plan only. New goals start with zero saved; existing saved balances are preserved.',
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: s.busy ? null : save,
                child: const Text('Review changes'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
