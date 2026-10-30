import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/store.dart';
import '../../core/theme.dart';
import '../../ui/components.dart';
import '../../ui/charts.dart';

class OverviewPage extends ConsumerWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(storeProvider), d = s.data;
    final increase =
        d.wealthHistory.last - d.wealthHistory[d.wealthHistory.length - 2];
    final diningChange =
        d.spendTotal(10, category: 'Dining') -
        d.spendTotal(9, category: 'Dining');
    final goal = d.goals.isEmpty ? null : d.goals.first;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

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
          padding: const EdgeInsets.only(top: 6, bottom: 18),
          child: Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: isDark ? neonTeal : teal,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? neonTeal : teal).withValues(alpha: 0.6),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'YOUR MONEY, CLEARLY  ·  DEMO',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Net Worth Hero Section
        Panel(
          padding: 22,
          tint: isDark ? const Color(0xFF131A24) : Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Your net worth',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: s.hidden ? 'Show balances' : 'Hide balances',
                    onPressed: s.busy ? null : () => s.setHidden(!s.hidden),
                    icon: Icon(
                      s.hidden
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => context.push('/wealth'),
                child: Amount(d.netWorth, size: 38),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: (isDark ? neonTeal : chartGreen).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        s.hidden
                            ? '••••••'
                            : '+${s.amount(increase)} since September',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? neonTeal : chartGreen,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              HistoryChart(
                values: d.wealthHistory,
                labels: const ['May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'],
                height: 140,
                compact: true,
                title: 'Net worth',
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => context.push('/wealth'),
                  icon: const Icon(Icons.show_chart_rounded, size: 17),
                  label: Text(
                    'Explore your wealth  →',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 4),

        // AI Insight Banner
        Panel(
          tint: scheme.primary.withValues(alpha: isDark ? 0.08 : 0.05),
          onTap: () => context.push('/spending?category=Dining'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome_outlined,
                    color: scheme.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'A little clarity',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
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
              const SizedBox(height: 12),
              Text(
                s.hidden
                    ? 'Your dining insight is hidden.'
                    : 'Dining is ${s.amount(diningChange.abs())} ${diningChange >= 0 ? 'higher' : 'lower'} this month.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 6),
              const Muted(
                'October vs September, through day 30. Explore the transactions behind it.',
              ),
            ],
          ),
        ),

        // Assistant Quick Query
        Panel(
          onTap: () => context.push('/assistant'),
          padding: 16,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.auto_awesome_rounded, size: 18, color: scheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Ask about your money…',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),

        const SectionTitle('Your month'),

        // Spending Card
        Panel(
          onTap: () => context.push('/spending'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _CardHeading('Spending', 'October'),
              const SizedBox(height: 12),
              Amount(d.spendTotal(10)),
              const SizedBox(height: 6),
              Muted(
                '${s.amount(d.spendTotal(10) - d.spendTotal(9))} more than September',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'View categories & transactions',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 15, color: scheme.primary),
                ],
              ),
            ],
          ),
        ),

        // Investments Card
        Panel(
          onTap: () => context.push('/investments'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _CardHeading('Investments', '3 asset classes'),
              const SizedBox(height: 12),
              Amount(d.investmentValue),
              const SizedBox(height: 6),
              Muted(
                s.hidden
                    ? 'Return hidden'
                    : '+${s.amount(d.investmentValue - d.invested)} · ${(100 * (d.investmentValue / d.invested - 1)).toStringAsFixed(1)}% since purchase',
              ),
              const SizedBox(height: 16),
              if (!s.hidden)
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Row(
                    children: [
                      for (var i = 0; i < 3; i++)
                        Expanded(
                          flex: (d.holdings
                                  .where(
                                    (h) =>
                                        h.type ==
                                        [
                                          'Stocks',
                                          'Mutual funds',
                                          'Fixed deposits',
                                        ][i],
                                  )
                                  .fold<double>(0, (a, h) => a + h.value) /
                              1000)
                              .round()
                              .clamp(1, 10000),
                          child: Container(
                            height: 8,
                            color: assetColors[i],
                          ),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 10),
              const Muted('Stocks · Mutual funds · Fixed deposits'),
            ],
          ),
        ),

        SectionTitle(
          'Looking ahead',
          action: 'All goals',
          onTap: () => context.push('/goals'),
        ),

        // Goals Card
        if (goal != null)
          Panel(
            onTap: () => context.push('/goals/${goal.id}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardHeading(goal.name, 'Priority goal'),
                const SizedBox(height: 14),
                Text(
                  '${s.amount(goal.saved)} of ${s.amount(goal.target)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                if (!s.hidden) ProgressLine(goal.progress),
                const SizedBox(height: 12),
                Muted('${s.amount(goal.remaining)} to go · View plan →'),
              ],
            ),
          )
        else
          Panel(
            onTap: () => context.push('/goals'),
            child: Text(
              'Create your first savings goal →',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
          ),

        // Credit Health Card
        Panel(
          onTap: () => context.push('/credit'),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.shield_outlined, size: 22, color: scheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Credit health',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
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
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),
        const Muted(
          'A calm view of sample finances. As of 30 October 2026. No bank accounts are connected.',
        ),
      ],
    );
  }
}

class _CardHeading extends StatelessWidget {
  const _CardHeading(this.title, this.detail);

  final String title, detail;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          detail,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      const SizedBox(width: 4),
      Icon(
        Icons.chevron_right_rounded,
        size: 18,
        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
      ),
    ],
  );
}
