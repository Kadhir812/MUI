import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/formatters.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../../ui/components.dart';

class IncomeFormPage extends ConsumerStatefulWidget {
  const IncomeFormPage({super.key});

  @override
  ConsumerState<IncomeFormPage> createState() => _IncomeFormPageState();
}

class _IncomeFormPageState extends ConsumerState<IncomeFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _source = TextEditingController();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  DateTime _date = demoDate;
  String _account = 'Everyday account';

  @override
  void dispose() {
    _source.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2026, 8),
      lastDate: demoDate,
      helpText: 'Choose income date',
    );
    if (selected != null && mounted) setState(() => _date = selected);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final store = ref.read(storeProvider);
    final saved = await store.addIncome(
      source: _source.text,
      amount: double.parse(_amount.text),
      date: _date,
      account: _account,
      note: _note.text,
    );
    if (!mounted) return;
    if (!saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(store.error ?? 'Could not save this income.')),
      );
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Income added')));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(storeProvider);
    return PageFrame(
      title: 'Add income',
      children: [
        const Muted(
          'Record income for your history and cash-flow view. It will not change account balances or net worth.',
        ),
        const SizedBox(height: 18),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const ValueKey('income-source'),
                controller: _source,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 80,
                decoration: const InputDecoration(
                  labelText: 'Income source',
                  hintText: 'e.g. Salary, freelance work',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter an income source'
                    : null,
              ),
              TextFormField(
                key: const ValueKey('income-amount'),
                controller: _amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Amount received',
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
                  labelText: 'Received into',
                  border: UnderlineInputBorder(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    key: const ValueKey('income-account'),
                    value: _account,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: 'Everyday account',
                        child: Text('Everyday account'),
                      ),
                      DropdownMenuItem(
                        value: 'Savings account',
                        child: Text('Savings account'),
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
                  key: const ValueKey('income-date'),
                  onPressed: _selectDate,
                  icon: const Icon(Icons.calendar_today_outlined, size: 17),
                  label: Text('Date · ${shortDate(_date)}'),
                ),
              ),
              TextFormField(
                key: const ValueKey('income-note'),
                controller: _note,
                maxLength: 200,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
              ),
              const SizedBox(height: 16),
              const Notice(
                'This record is saved on this device and updates income totals. Account balances and net worth are not recalculated from these records.',
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                key: const ValueKey('save-income'),
                onPressed: store.busy ? null : _save,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Save income'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
