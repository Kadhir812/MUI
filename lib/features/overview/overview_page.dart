import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../../ui/charts.dart';
import '../../ui/components.dart';

class OverviewPage extends ConsumerWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(storeProvider);
    final d = s.data;
    final scheme = Theme.of(context).colorScheme;
    final history = d.wealthHistory;
    final previousNetWorth = history.length > 1
        ? history[history.length - 2]
        : d.netWorth;
    final previousIndex = history.length > 1 ? history.length - 2 : 0;
    final previousPortfolio = d.portfolioHistory[previousIndex];
    final portfolioChange = d.investmentValue - previousPortfolio;
    final cashChange =
        FinancialData.everyday +
        FinancialData.savings -
        d.cashHistory[previousIndex];
    final liabilityChange =
        FinancialData.liabilities - d.liabilityHistory[previousIndex];
    final liabilityStory = liabilityChange < 0
        ? 'Paying down card debt added ${s.amount(liabilityChange.abs())}.'
        : liabilityChange > 0
        ? 'More card debt reduced the total by ${s.amount(liabilityChange)}.'
        : 'Card debt was unchanged.';
    final netWorthChange = d.netWorth - previousNetWorth;
    final netWorthChangePercent = previousNetWorth == 0
        ? 0.0
        : netWorthChange / previousNetWorth * 100;
    final spendingChange = d.spendTotal(10) - d.spendTotal(9);
    final categoryChanges =
        categories
            .map(
              (category) => MapEntry(
                category,
                d.spendTotal(10, category: category) -
                    d.spendTotal(9, category: category),
              ),
            )
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    final leadingCategoryChange = spendingChange < 0
        ? categoryChanges.last
        : categoryChanges.first;
    final diningChange =
        d.spendTotal(10, category: 'Dining') -
        d.spendTotal(9, category: 'Dining');
    final investmentGain = d.investmentValue - d.invested;
    final goal = d.goals.isEmpty ? null : d.goals.first;
    final netWorthStory = s.hidden
        ? 'Your balances are hidden while you browse.'
        : netWorthChange >= 0
        ? 'After debts, you would have ${s.amount(netWorthChange)} more than in September. ${_changeSentence('Money in accounts', cashChange, s)} ${_changeSentence('Investments', portfolioChange, s)} $liabilityStory'
        : 'After debts, you would have ${s.amount(netWorthChange.abs())} less than in September. ${_changeSentence('Money in accounts', cashChange, s)} ${_changeSentence('Investments', portfolioChange, s)} $liabilityStory';
    final spendingStory = s.hidden
        ? 'Your spending details are hidden.'
        : spendingChange > 0
        ? 'Spending rose by ${s.amount(spendingChange)} compared with September.'
        : spendingChange < 0
        ? 'Spending fell by ${s.amount(spendingChange.abs())} compared with September.'
        : 'Spending stayed level with September.';
    final investmentStory = s.hidden
        ? 'Your portfolio details are hidden.'
        : 'Across ${d.holdings.length} holdings, portfolio value ${portfolioChange >= 0 ? 'rose' : 'fell'} ${s.amount(portfolioChange.abs())} since September and is ${s.amount(investmentGain.abs())} ${investmentGain >= 0 ? 'above' : 'below'} the amount invested.';
    final spendingHighlight = s.hidden
        ? 'Your category comparison is hidden.'
        : spendingChange > 0 && leadingCategoryChange.value > 0
        ? '${leadingCategoryChange.key} had the largest increase: ${s.amount(leadingCategoryChange.value)} of the ${s.amount(spendingChange)} net rise.'
        : spendingChange < 0 && leadingCategoryChange.value < 0
        ? '${leadingCategoryChange.key} had the largest decrease, while total spending fell ${s.amount(spendingChange.abs())}.'
        : 'Category changes balanced out; total spending was unchanged.';
    final goalStory = goal == null
        ? 'Choose something you are saving for and set a target.'
        : s.hidden
        ? 'Your savings plan and credit details are hidden.'
        : 'You have saved ${(goal.progress * 100).round()}% of your ${goal.name} target. Your plan sets aside ${s.amount(goal.monthly)} each month; about ${s.amount(goal.requiredMonthly)} is needed to reach the target by ${monthName(goal.deadline.month)} ${goal.deadline.year}.';
    final recentEntries = [...d.entries]
      ..sort((a, b) => b.date.compareTo(a.date));

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
          icon: const Icon(Icons.tune_rounded),
        ),
      ],
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR MONEY, THIS MONTH',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.25,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'A simple picture of where things stand.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _StoryChapter(
          number: '01',
          eyebrow: 'THE BIG PICTURE',
          title: 'What you would have left',
          detail: netWorthStory,
        ),
        Panel(
          padding: 18,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LEFT AFTER PAYING WHAT YOU OWE',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Muted(
                          'Money in accounts and investments, minus debts.',
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: s.hidden ? 'Show balances' : 'Hide balances',
                    visualDensity: VisualDensity.compact,
                    onPressed: s.busy ? null : () => s.setHidden(!s.hidden),
                    icon: Icon(
                      s.hidden
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 19,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Amount(d.netWorth, size: 36),
              const SizedBox(height: 5),
              Row(
                children: [
                  Icon(
                    s.hidden
                        ? Icons.trending_flat_rounded
                        : netWorthChange >= 0
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    size: 16,
                    color: s.hidden
                        ? scheme.onSurfaceVariant
                        : netWorthChange >= 0
                        ? chartGreen
                        : chartRed,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      s.hidden
                          ? '••••  ·  vs September'
                          : '${netWorthChange >= 0 ? '+' : ''}${s.amount(netWorthChange)}  (${netWorthChangePercent >= 0 ? '+' : ''}${netWorthChangePercent.toStringAsFixed(1)}%)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: netWorthChange >= 0 ? chartGreen : chartRed,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              HistoryChart(
                values: history,
                labels: const ['May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'],
                height: 112,
                compact: true,
                title: 'Net worth',
                showTimeframes: true,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => context.push('/wealth'),
                  icon: const Icon(Icons.arrow_outward_rounded, size: 16),
                  label: Text(
                    'Explore your wealth  →',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.only(left: 0, right: 8),
                    minimumSize: const Size(0, 38),
                  ),
                ),
              ),
            ],
          ),
        ),

        _StoryChapter(
          number: '02',
          eyebrow: 'THE MONTH BEHIND THE NUMBER',
          title: 'What changed this month',
          detail: '$spendingStory $investmentStory',
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _MetricTile(
                icon: Icons.south_west_rounded,
                label: 'Spent',
                value: d.spendTotal(10),
                detail: s.hidden
                    ? 'Monthly change hidden'
                    : '${spendingChange >= 0 ? '+' : ''}${s.amount(spendingChange)} vs Sep',
                onTap: () => context.push('/spending'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricTile(
                icon: Icons.show_chart_rounded,
                label: 'Investments',
                value: d.investmentValue,
                detail: s.hidden
                    ? 'Portfolio details hidden'
                    : '${d.holdings.length} holdings · ${investmentGain >= 0 ? '+' : ''}${s.amount(investmentGain)}',
                onTap: () => context.push('/investments'),
              ),
            ),
          ],
        ),

        _StoryChapter(
          number: '03',
          eyebrow: 'WHAT YOU’RE BUILDING',
          title: 'Your savings plan',
          detail: goalStory,
          action: 'All goals',
          onTap: () => context.push('/goals'),
        ),
        if (goal != null)
          Panel(
            padding: 16,
            onTap: () => context.push('/goals/${goal.id}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        goal.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (!s.hidden)
                      Text(
                        '${(goal.progress * 100).round()}%',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: scheme.primary,
                        ),
                      ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 19,
                      color: scheme.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (!s.hidden) ProgressLine(goal.progress),
                const SizedBox(height: 8),
                Muted(
                  '${s.amount(goal.saved)} saved of ${s.amount(goal.target)} · ${s.amount(goal.remaining)} to go',
                ),
              ],
            ),
          )
        else
          Panel(
            padding: 16,
            onTap: () => context.push('/goals'),
            child: const Text('Create your first savings goal →'),
          ),
        Panel(
          padding: 16,
          onTap: () => context.push('/credit'),
          child: Row(
            children: [
              Icon(Icons.shield_outlined, color: scheme.primary, size: 21),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Credit health',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Muted('Updated 28 October'),
                  ],
                ),
              ),
              Text(
                s.hidden ? '•••' : '782',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 19,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),

        _StoryChapter(
          number: '04',
          eyebrow: 'A PATTERN TO NOTICE',
          title: 'One change to notice',
          detail: s.hidden
              ? 'Your spending details are hidden.'
              : '$spendingHighlight Eating out cost ${s.amount(diningChange.abs())} ${diningChange >= 0 ? 'more' : 'less'} than in September. Tap to see the purchases.',
        ),
        Panel(
          padding: 16,
          onTap: () => context.push('/spending?category=Dining'),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.auto_awesome_outlined,
                color: scheme.primary,
                size: 19,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.hidden
                          ? 'Your spending details are hidden.'
                          : 'Eating out cost ${s.amount(diningChange.abs())} ${diningChange >= 0 ? 'more' : 'less'} this month.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Muted(
                      'Compared with September. Tap to see the transactions.',
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                size: 17,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
        _StoryChapter(
          number: '05',
          eyebrow: 'THE DETAILS',
          title: 'The latest entries',
          detail: 'Recent purchases, income, and transfers.',
          action: 'See spending',
          onTap: () => context.push('/spending'),
        ),
        Panel(
          padding: 8,
          child: Column(
            children: [
              for (final entry in recentEntries.take(3))
                _ActivityRow(
                  entry: entry,
                  hidden: s.hidden,
                  onTap: () => context.push('/transactions/${entry.id}'),
                ),
            ],
          ),
        ),
        if (recentEntries.any((entry) => entry.isManual))
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Muted('Your added expenses are saved on this device.'),
          ),
        _StoryChapter(
          number: '06',
          eyebrow: 'YOUR NEXT CHAPTER',
          title: 'What would you like help with?',
          detail: 'Ask a question about spending, savings, or investments.',
        ),
        Panel(
          padding: 16,
          onTap: () => context.push('/assistant'),
          child: Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: scheme.primary, size: 19),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ask a money question',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                size: 17,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Muted(
            'Recent entries are sample activity, not a complete account ledger.',
          ),
        ),
      ],
    );
  }
}

String _changeSentence(String subject, double change, FinanceStore store) {
  final direction = change > 0
      ? 'rose'
      : change < 0
      ? 'fell'
      : 'was unchanged';
  return change == 0
      ? '$subject $direction.'
      : '$subject $direction by ${store.amount(change.abs())}.';
}

class _StoryChapter extends StatelessWidget {
  const _StoryChapter({
    required this.number,
    required this.eyebrow,
    required this.title,
    required this.detail,
    this.action,
    this.onTap,
  });

  final String number, eyebrow, title, detail;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 26, bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.secondary.withValues(alpha: 0.26),
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: scheme.onSurfaceVariant,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.35,
                        ),
                      ),
                    ),
                    if (action != null)
                      TextButton(
                        onPressed: onTap,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.only(left: 8),
                          minimumSize: const Size(0, 32),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          action!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    height: 1.45,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
    required this.onTap,
  });

  final IconData icon;
  final String label, detail;
  final double value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Panel(
      padding: 14,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: scheme.primary),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Amount(value, size: 21),
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              height: 1.35,
              fontWeight: FontWeight.w500,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
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
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
