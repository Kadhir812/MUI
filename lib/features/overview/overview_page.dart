import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../assistant/assistant_service.dart';
import '../../ui/charts.dart';
import '../../ui/components.dart';

class OverviewPage extends ConsumerWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(storeProvider);
    final data = store.data;
    final scheme = Theme.of(context).colorScheme;
    final history = data.wealthHistory;
    final previousNetWorth = history.length > 1
        ? history[history.length - 2]
        : data.netWorth;
    final previousIndex = history.length > 1 ? history.length - 2 : 0;
    final netWorthChange = data.netWorth - previousNetWorth;
    final cashChange =
        FinancialData.everyday +
        FinancialData.savings -
        data.cashHistory[previousIndex];
    final portfolioChange =
        data.investmentValue - data.portfolioHistory[previousIndex];
    final spending = data.spendTotal(demoDate.month);
    final categoryChanges =
        categories
            .map(
              (category) => MapEntry(
                category,
                data.spendTotal(demoDate.month, category: category) -
                    data.spendTotal(demoDate.month - 1, category: category),
              ),
            )
            .toList()
          ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));
    final leadingCategoryChange = categoryChanges.first;
    final income = data.incomeTotal(demoDate.month);
    final investmentGain = data.investmentValue - data.invested;
    final goal = data.goals.isEmpty ? null : data.goals.first;
    final recentEntries = [...data.entries]
      ..sort((a, b) => b.date.compareTo(a.date));
    final assistant = DemoAssistantService();

    return PageFrame(
      title: 'still.',
      home: true,
      actions: [
        IconButton(
          tooltip: 'Search your finances',
          onPressed: () => context.push('/search'),
          icon: const Icon(Icons.search_rounded),
        ),
        IconButton(
          tooltip: 'Settings',
          onPressed: () => context.push('/settings'),
          icon: const Icon(Icons.settings_rounded),
        ),
      ],
      bottomBar: _HomeAskBox(
        onSubmit: (prompt) => context.push(assistant.destination(prompt, data)),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          child: Text(
            '${monthName(demoDate.month).toUpperCase()} ${demoDate.year}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        Panel(
          padding: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Net worth',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: store.hidden ? 'Show balances' : 'Hide balances',
                    visualDensity: VisualDensity.compact,
                    onPressed: store.busy
                        ? null
                        : () => store.setHidden(!store.hidden),
                    icon: Icon(
                      store.hidden
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 19,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Amount(data.netWorth, size: 32),
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 8),
                child: Text(
                  store.hidden
                      ? 'Monthly change hidden'
                      : '${netWorthChange >= 0 ? '+' : ''}${store.amount(netWorthChange)} vs September',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: store.hidden
                        ? scheme.onSurfaceVariant
                        : netWorthChange >= 0
                        ? chartGreen
                        : chartRed,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  store.hidden
                      ? 'Your wealth story is hidden.'
                      : 'Cash ${cashChange >= 0 ? 'grew' : 'fell'} and investments ${portfolioChange >= 0 ? 'rose' : 'dipped'} since September.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    height: 1.4,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 16,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Balance snapshot',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      'Tap to explore',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _BalanceMetric(
                      key: const ValueKey('home-assets-summary'),
                      label: 'Assets',
                      value: store.amount(data.assets),
                      onTap: () => context.push('/balance-sheet/assets'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _BalanceMetric(
                      key: const ValueKey('home-liabilities-summary'),
                      label: 'Liabilities',
                      value: store.amount(FinancialData.liabilities),
                      onTap: () => context.push('/balance-sheet/liabilities'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              HistoryChart(
                values: history,
                labels: const ['May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'],
                height: 66,
                compact: true,
                title: 'Net worth',
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => context.push('/wealth'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.only(left: 0, right: 8),
                    minimumSize: const Size(0, 36),
                  ),
                  child: const Text('View wealth details  →'),
                ),
              ),
            ],
          ),
        ),
        Panel(
          padding: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'This month',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/spending'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 36),
                    ),
                    child: const Text('See spending'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: _CashflowTapTarget(
                        key: const ValueKey('home-income-summary'),
                        label: 'Income',
                        amount: income,
                        color: chartGreen,
                        onTap: () => context.push('/income'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CashflowTapTarget(
                        key: const ValueKey('home-spending-summary'),
                        label: 'Spent',
                        amount: spending,
                        color: chartRed,
                        onTap: () => context.push('/spending'),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  store.hidden
                      ? 'Your monthly cash-flow story is hidden.'
                      : income >= spending
                      ? 'Recorded income is ${store.amount(income - spending)} ahead of listed spending.'
                      : 'Listed spending is ${store.amount(spending - income)} ahead of recorded income.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    height: 1.4,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: scheme.primary,
                      size: 19,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Budget status',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Muted('No monthly limit to compare against yet'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Panel(
          padding: 8,
          child: Column(
            children: [
              _SummaryRow(
                icon: Icons.show_chart_rounded,
                title: 'Investments',
                detail: store.hidden
                    ? '${data.holdings.length} holdings'
                    : '${data.holdings.length} holdings · ${investmentGain >= 0 ? 'up' : 'down'} ${store.amount(investmentGain.abs())} overall',
                value: store.amount(data.investmentValue),
                onTap: () => context.push('/investments'),
              ),
              const Divider(height: 1, indent: 54),
              _SummaryRow(
                icon: Icons.flag_outlined,
                title: 'Savings goals',
                detail: goal == null
                    ? 'Create your first goal'
                    : store.hidden
                    ? '${data.goals.length} goals'
                    : '${goal.name} is ${(goal.progress * 100).round()}% funded',
                value: goal == null
                    ? ''
                    : store.hidden
                    ? '•••'
                    : '${(goal.progress * 100).round()}%',
                onTap: () => context.push('/goals'),
              ),
              const Divider(height: 1, indent: 54),
              _SummaryRow(
                icon: Icons.shield_outlined,
                title: 'Credit health',
                detail: 'Updated 28 October',
                value: store.hidden ? '•••' : '782',
                onTap: () => context.push('/credit'),
              ),
            ],
          ),
        ),
        Panel(
          padding: 16,
          onTap: () => context.push(
            '/spending?category=${Uri.encodeComponent(leadingCategoryChange.key)}',
          ),
          child: Row(
            children: [
              Icon(Icons.auto_awesome_outlined, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spending insight',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      store.hidden
                          ? 'Your spending details are hidden'
                          : leadingCategoryChange.value == 0
                          ? 'Category spending stayed level since September.'
                          : '${leadingCategoryChange.key} ${leadingCategoryChange.value > 0 ? 'rose' : 'fell'} ${store.amount(leadingCategoryChange.value.abs())} since September—the biggest change.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
        Panel(
          padding: 8,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 4, 4, 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Recent activity',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/spending'),
                      child: const Text('See all'),
                    ),
                  ],
                ),
              ),
              for (final entry in recentEntries.take(2))
                _ActivityRow(
                  entry: entry,
                  hidden: store.hidden,
                  onTap: () => context.push('/transactions/${entry.id}'),
                ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Muted(
            'Recent entries are activity, not a complete account ledger.',
          ),
        ),
      ],
    );
  }
}

class _HomeAskBox extends StatefulWidget {
  const _HomeAskBox({required this.onSubmit});

  final ValueChanged<String> onSubmit;

  @override
  State<_HomeAskBox> createState() => _HomeAskBoxState();
}

class _HomeAskBoxState extends State<_HomeAskBox> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final prompt = _controller.text.trim();
    if (prompt.isNotEmpty) widget.onSubmit(prompt);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 5, 14, 10),
      child: Material(
        color: scheme.surface,
        elevation: 8,
        shadowColor: scheme.shadow.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(28),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: scheme.outlineVariant),
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.fromLTRB(18, 9, 8, 9),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome_outlined,
                size: 20,
                color: scheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: TextField(
                    key: const ValueKey('home-command-input'),
                    controller: _controller,
                    style: GoogleFonts.plusJakartaSans(fontSize: 15),
                    textAlignVertical: TextAlignVertical.center,
                    textInputAction: TextInputAction.go,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(
                      hintText: 'Ask Still anything',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 2),
                    ),
                  ),
                ),
              ),
              IconButton(
                key: const ValueKey('home-command-send'),
                tooltip: 'Go to matching page',
                padding: EdgeInsets.zero,
                alignment: Alignment.center,
                visualDensity: VisualDensity.standard,
                constraints: const BoxConstraints.tightFor(
                  width: 44,
                  height: 44,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  disabledBackgroundColor: scheme.surfaceContainerHighest,
                  disabledForegroundColor: scheme.onSurfaceVariant,
                ),
                onPressed: _controller.text.trim().isEmpty ? null : _submit,
                icon: const Icon(Icons.arrow_upward_rounded, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CashflowTapTarget extends StatelessWidget {
  const _CashflowTapTarget({
    super.key,
    required this.label,
    required this.amount,
    required this.color,
    required this.onTap,
  });

  final String label;
  final double amount;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'View $label details',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Amount(amount, size: 22),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 28,
                  height: 3,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BalanceMetric extends StatelessWidget {
  const _BalanceMetric({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.title,
    required this.detail,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title, detail, value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
          child: Row(
            children: [
              Icon(icon, size: 20, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (value.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 19,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.entry,
    required this.hidden,
    required this.onTap,
  });

  final Entry entry;
  final bool hidden;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final month = const [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ][entry.date.month - 1];
    final sign = switch (entry.kind) {
      'income' || 'refund' => '+',
      'expense' => '−',
      _ => '',
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: scheme.secondary.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  entry.kind == 'income'
                      ? Icons.south_west_rounded
                      : Icons.north_east_rounded,
                  size: 17,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.merchant,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${entry.isManual ? 'You added · ' : ''}${entry.category} · ${entry.date.day} $month',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                hidden ? '••••' : '$sign${money(entry.amount.abs())}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
