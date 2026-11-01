import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/formatters.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../../ui/components.dart';

class ExpenseFormPage extends ConsumerStatefulWidget {
  const ExpenseFormPage({super.key});

  @override
  ConsumerState<ExpenseFormPage> createState() => _ExpenseFormPageState();
}

class _ExpenseFormPageState extends ConsumerState<ExpenseFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _merchant = TextEditingController();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  DateTime _date = demoDate;
  String _category = categories.first;
  String _account = 'Everyday account';

  @override
  void dispose() {
    _merchant.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: demoDate,
      helpText: 'Choose expense date',
    );
    if (selected != null && mounted) setState(() => _date = selected);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final store = ref.read(storeProvider);
    final amount = double.parse(_amount.text);
    final saved = await store.addExpense(
      merchant: _merchant.text,
      amount: amount,
      date: _date,
      category: _category,
      account: _account,
      note: _note.text,
    );
    if (!mounted) return;
    if (!saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(store.error ?? 'Could not save this expense.')),
      );
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Expense added')));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(storeProvider);
    return PageFrame(
      title: 'Add expense',
      children: [
        const Muted(
          'Add a personal entry. It updates spending and activity, not the account balances.',
        ),
        const SizedBox(height: 18),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const ValueKey('expense-merchant'),
                controller: _merchant,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 80,
                decoration: const InputDecoration(
                  labelText: 'What did you spend on?',
                  hintText: 'e.g. Lunch',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a name for this expense'
                    : null,
              ),
              TextFormField(
                key: const ValueKey('expense-amount'),
                controller: _amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                ),
                validator: (value) {
                  final raw = value?.trim() ?? '';
                  final parsed = double.tryParse(raw);
                  if (parsed == null || !parsed.isFinite || parsed <= 0) {
                    return 'Enter an amount greater than zero';
                  }
                  if (raw.contains('.') &&
                      raw.length - raw.indexOf('.') - 1 > 2) {
                    return 'Use no more than 2 decimal places';
                  }
                  if (parsed > 1000000000) {
                    return 'Enter an amount below ₹100 crore';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: UnderlineInputBorder(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    key: const ValueKey('expense-category'),
                    value: _category,
                    isExpanded: true,
                    items: [
                      for (final category in categories)
                        DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _category = value);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Paid from',
                  border: UnderlineInputBorder(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    key: const ValueKey('expense-account'),
                    value: _account,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: 'Everyday account',
                        child: Text('Everyday account'),
                      ),
                      DropdownMenuItem(
                        value: 'Credit card',
                        child: Text('Credit card'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _account = value);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  key: const ValueKey('expense-date'),
                  onPressed: _selectDate,
                  icon: const Icon(Icons.calendar_today_outlined, size: 17),
                  label: Text('Date · ${shortDate(_date)}'),
                ),
              ),
              TextFormField(
                key: const ValueKey('expense-note'),
                controller: _note,
                maxLength: 200,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                ),
              ),
              const SizedBox(height: 16),
              const Notice(
                'This personal entry is saved on this device. It will appear in spending and activity, but will not change balances or net worth.',
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                key: const ValueKey('save-expense'),
                onPressed: store.busy ? null : _save,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Save expense'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
