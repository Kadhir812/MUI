import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/formatters.dart';
import '../core/theme.dart';
import '../data/models.dart';
import '../data/store.dart';
import 'components.dart';

/// TradingView-inspired interactive chart featuring smooth cubic curves,
/// glow effects, interactive crosshairs, dynamic scrub badges, and grid lines.
class HistoryChart extends ConsumerStatefulWidget {
  const HistoryChart({
    super.key,
    required this.values,
    required this.labels,
    this.height = 200,
    this.compact = false,
    this.title = 'Value history',
  });

  final List<double> values;
  final List<String> labels;
  final double height;
  final bool compact;
  final String title;

  @override
  ConsumerState<HistoryChart> createState() => _HistoryChartState();
}

class _HistoryChartState extends ConsumerState<HistoryChart> {
  int? _scrubIndex;
  double? _scrubNormalizedX;

  void _onScrub(Offset localPosition, double width) {
    if (widget.values.isEmpty || width <= 0) return;
    final clampedX = localPosition.dx.clamp(0.0, width);
    final count = widget.values.length;
    final index = ((clampedX / width) * (count - 1)).round().clamp(0, count - 1);
    if (_scrubIndex != index) {
      HapticFeedback.selectionClick();
    }
    setState(() {
      _scrubIndex = index;
      _scrubNormalizedX = clampedX / width;
    });
  }

  void _onScrubEnd() {
    setState(() {
      _scrubIndex = null;
      _scrubNormalizedX = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(storeProvider);
    if (store.hidden) {
      return SizedBox(
        height: widget.height,
        child: const Center(child: Muted('Chart hidden for privacy')),
      );
    }

    if (widget.values.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(child: Muted('No data available')),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine performance color (green if positive overall return, red if down)
    final firstVal = widget.values.first;
    final lastVal = widget.values.last;
    final isBull = lastVal >= firstVal;
    final chartAccent = isBull ? (isDark ? neonTeal : chartGreen) : chartRed;

    // Current displayed values (scrubbed or latest)
    final activeIndex = _scrubIndex ?? (widget.values.length - 1);
    final activeVal = widget.values[activeIndex];
    final activeLabel = widget.labels.length > activeIndex ? widget.labels[activeIndex] : '';
    final deltaFromStart = activeVal - firstVal;
    final deltaPct = firstVal == 0 ? 0.0 : (deltaFromStart / firstVal) * 100;
    final isDeltaPos = deltaFromStart >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!widget.compact) ...[
          // TradingView Top Bar readout (wrap for narrow screens)
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Text(
                money(activeVal),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                  fontFeatures: const [ui.FontFeature.tabularFigures()],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: (isDeltaPos ? chartGreen : chartRed).withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${isDeltaPos ? '+' : ''}${money(deltaFromStart)} (${isDeltaPos ? '+' : ''}${deltaPct.toStringAsFixed(1)}%)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDeltaPos ? (isDark ? neonTeal : chartGreen) : chartRed,
                    fontFeatures: const [ui.FontFeature.tabularFigures()],
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Text(
                  _scrubIndex != null ? activeLabel : 'Overall',
                  key: ValueKey(activeLabel),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],

        // Interactive Canvas
        LayoutBuilder(
          builder: (context, constraints) {
            final chartWidth = constraints.maxWidth;
            final chartHeight = widget.height;

            return GestureDetector(
              onHorizontalDragDown: (d) => _onScrub(d.localPosition, chartWidth),
              onHorizontalDragUpdate: (d) => _onScrub(d.localPosition, chartWidth),
              onHorizontalDragEnd: (_) => _onScrubEnd(),
              onHorizontalDragCancel: () => _onScrubEnd(),
              onTapDown: (d) => _onScrub(d.localPosition, chartWidth),
              onTapUp: (_) => _onScrubEnd(),
              child: MouseRegion(
                onHover: (e) => _onScrub(e.localPosition, chartWidth),
                onExit: (_) => _onScrubEnd(),
                cursor: SystemMouseCursors.precise,
                child: SizedBox(
                  width: chartWidth,
                  height: chartHeight,
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 650),
                    curve: Curves.easeOutCubic,
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    builder: (context, progress, _) {
                      return CustomPaint(
                        size: Size(chartWidth, chartHeight),
                        painter: _TradingViewChartPainter(
                          values: widget.values,
                          accentColor: chartAccent,
                          isDark: isDark,
                          progress: progress,
                          scrubNormalizedX: _scrubNormalizedX,
                          scrubIndex: _scrubIndex,
                          compact: widget.compact,
                          gridColor: Theme.of(context).colorScheme.outlineVariant,
                          surfaceColor: Theme.of(context).colorScheme.surface,
                          textColor: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 8),

        // X-Axis Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < widget.labels.length; i++)
              if (widget.compact && (i != 0 && i != widget.labels.length - 1))
                const SizedBox.shrink()
              else
                Text(
                  widget.labels[i],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: (_scrubIndex == i)
                        ? chartAccent
                        : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
          ],
        ),

        if (!widget.compact) ...[
          const SizedBox(height: 12),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(
              'Detailed price points',
              style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            children: [
              for (var i = 0; i < widget.values.length; i++)
                DataRowTile(widget.labels[i], money(widget.values[i])),
            ],
          ),
        ] else
          Semantics(
            label: '${widget.title}. ${widget.labels.first}: ${money(widget.values.first)}. ${widget.labels.last}: ${money(widget.values.last)}.',
            child: const SizedBox.shrink(),
          ),
      ],
    );
  }
}

class _TradingViewChartPainter extends CustomPainter {
  _TradingViewChartPainter({
    required this.values,
    required this.accentColor,
    required this.isDark,
    required this.progress,
    required this.scrubNormalizedX,
    required this.scrubIndex,
    required this.compact,
    required this.gridColor,
    required this.surfaceColor,
    required this.textColor,
  });

  final List<double> values;
  final Color accentColor;
  final bool isDark;
  final double progress;
  final double? scrubNormalizedX;
  final int? scrubIndex;
  final bool compact;
  final Color gridColor;
  final Color surfaceColor;
  final Color textColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final min = values.reduce(math.min);
    final max = values.reduce(math.max);
    final span = max - min;
    final pad = math.max(span * 0.22, 1000.0);
    final minY = min - pad;
    final maxY = max + pad;
    final yRange = (maxY - minY) <= 0 ? 1.0 : (maxY - minY);

    final w = size.width;
    final h = size.height;

    // Draw horizontal dashed grid lines & price markers (unless compact)
    if (!compact) {
      final gridPaint = Paint()
        ..color = gridColor.withValues(alpha: isDark ? 0.25 : 0.4)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke;

      const gridSteps = 3;
      for (var s = 1; s <= gridSteps; s++) {
        final ratio = s / (gridSteps + 1);
        final y = h * ratio;
        _drawDashedLine(canvas, Offset(0, y), Offset(w, y), gridPaint, dashLength: 4, dashSpace: 4);

        // Price label on right side
        final priceLevel = maxY - ratio * yRange;
        final spanText = TextSpan(
          text: money(priceLevel),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: textColor.withValues(alpha: 0.5),
            fontFeatures: const [ui.FontFeature.tabularFigures()],
          ),
        );
        final tp = TextPainter(text: spanText, textDirection: TextDirection.ltr)..layout();
        tp.paint(canvas, Offset(w - tp.width - 4, y - tp.height - 2));
      }
    }

    // Convert data to pixel coordinates
    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = (i / (values.length - 1)) * w;
      final targetY = h - ((values[i] - minY) / yRange) * h;
      // Animate progress up from baseline
      final animatedY = h - (h - targetY) * progress;
      points.add(Offset(x, animatedY));
    }

    // Build smooth cubic bezier curve
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (var i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i < points.length - 2 ? points[i + 2] : p2;

      // Catmull-Rom to Cubic Bezier conversion
      final cp1x = p1.dx + (p2.dx - p0.dx) / 6.0;
      final cp1y = p1.dy + (p2.dy - p0.dy) / 6.0;
      final cp2x = p2.dx - (p3.dx - p1.dx) / 6.0;
      final cp2y = p2.dy - (p3.dy - p1.dy) / 6.0;

      path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
    }

    // Gradient fill under the curve
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, h)
      ..lineTo(points.first.dx, h)
      ..close();

    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(0, h),
        [
          accentColor.withValues(alpha: isDark ? 0.35 : 0.22),
          accentColor.withValues(alpha: 0.0),
        ],
      );
    canvas.drawPath(fillPath, fillPaint);

    // Subtle volume bars along the baseline (TradingView signature)
    if (!compact) {
      final barWidth = (w / values.length) * 0.35;
      final barPaint = Paint()..style = PaintingStyle.fill;
      for (var i = 0; i < values.length; i++) {
        final barHeight = ((values[i] - minY) / yRange) * (h * 0.25) * progress;
        final bx = points[i].dx - barWidth / 2;
        final by = h - barHeight;
        barPaint.color = accentColor.withValues(alpha: isDark ? 0.12 : 0.08);
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(bx, by, barWidth, barHeight), const Radius.circular(2)),
          barPaint,
        );
      }
    }

    // Glow line (underneath main stroke)
    final glowPaint = Paint()
      ..color = accentColor.withValues(alpha: isDark ? 0.3 : 0.2)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, glowPaint);

    // Core curve stroke
    final strokePaint = Paint()
      ..color = accentColor
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);

    // Interactive Crosshair & Scrubbing Element
    if (scrubNormalizedX != null && scrubIndex != null) {
      final activePoint = points[scrubIndex!];
      final scrubX = activePoint.dx;
      final scrubY = activePoint.dy;

      // Vertical crosshair dashed line
      final crosshairPaint = Paint()
        ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.35)
        ..strokeWidth = 1.0;
      _drawDashedLine(canvas, Offset(scrubX, 0), Offset(scrubX, h), crosshairPaint, dashLength: 4, dashSpace: 4);

      // Horizontal price crosshair line
      if (!compact) {
        _drawDashedLine(canvas, Offset(0, scrubY), Offset(w, scrubY), crosshairPaint, dashLength: 4, dashSpace: 4);

        // Price badge on the right axis
        final badgeText = money(values[scrubIndex!]);
        final tp = TextPainter(
          text: TextSpan(
            text: badgeText,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              fontFeatures: const [ui.FontFeature.tabularFigures()],
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final badgeRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(w - tp.width - 12, scrubY - tp.height / 2 - 4, tp.width + 12, tp.height + 8),
          const Radius.circular(6),
        );
        canvas.drawRRect(badgeRect, Paint()..color = accentColor);
        tp.paint(canvas, Offset(w - tp.width - 6, scrubY - tp.height / 2));
      }

      // Outer beacon aura
      canvas.drawCircle(
        Offset(scrubX, scrubY),
        8.0,
        Paint()..color = accentColor.withValues(alpha: 0.28),
      );

      // Inner white beacon dot with accent border
      canvas.drawCircle(Offset(scrubX, scrubY), 4.5, Paint()..color = Colors.white);
      canvas.drawCircle(
        Offset(scrubX, scrubY),
        4.5,
        Paint()
          ..color = accentColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    } else {
      // Resting beacon on the latest data point
      final lastPoint = points.last;
      canvas.drawCircle(
        lastPoint,
        6.0,
        Paint()..color = accentColor.withValues(alpha: 0.25),
      );
      canvas.drawCircle(lastPoint, 3.5, Paint()..color = accentColor);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint, {double dashLength = 4, dashSpace = 4}) {
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    if (distance <= 0) return;

    final unitX = dx / distance;
    final unitY = dy / distance;
    var currentDist = 0.0;

    while (currentDist < distance) {
      final start = Offset(p1.dx + unitX * currentDist, p1.dy + unitY * currentDist);
      final nextDist = math.min(currentDist + dashLength, distance);
      final end = Offset(p1.dx + unitX * nextDist, p1.dy + unitY * nextDist);
      canvas.drawLine(start, end, paint);
      currentDist += dashLength + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _TradingViewChartPainter old) {
    return old.progress != progress ||
        old.scrubNormalizedX != scrubNormalizedX ||
        old.scrubIndex != scrubIndex ||
        old.values != values ||
        old.accentColor != accentColor ||
        old.isDark != isDark;
  }
}

/// Polished TradingView-inspired Donut Allocation Ring with glowing active arcs,
/// hover highlight, animated central readout, and interactive touch breakdown.
class AllocationRing extends ConsumerStatefulWidget {
  const AllocationRing({
    super.key,
    required this.holdings,
    required this.selected,
    required this.onSelect,
    this.nested = false,
  });

  final List<Holding> holdings;
  final String? selected;
  final ValueChanged<String?> onSelect;
  final bool nested;

  @override
  ConsumerState<AllocationRing> createState() => _AllocationRingState();
}

class _AllocationRingState extends ConsumerState<AllocationRing> {
  @override
  Widget build(BuildContext context) {
    final store = ref.watch(storeProvider);
    const types = ['Stocks', 'Mutual funds', 'Fixed deposits'];

    final totals = types
        .map(
          (t) => widget.holdings
              .where((h) => h.type == t)
              .fold<double>(0, (s, h) => s + h.value),
        )
        .toList();

    final total = totals.fold<double>(0, (s, v) => s + v);

    if (store.hidden) {
      return const SizedBox(
        height: 240,
        child: Center(child: Muted('Allocation hidden for privacy')),
      );
    }

    final selectedValue = widget.selected == null ? total : totals[types.indexOf(widget.selected!)];
    final selectedPct = total > 0 ? (selectedValue / total) * 100 : 0.0;

    return Column(
      children: [
        SizedBox(
          height: 270,
          child: Center(
            child: SizedBox(
              width: 270,
              height: 270,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onTapUp: (d) {
                      final x = d.localPosition.dx - 135;
                      final y = d.localPosition.dy - 135;
                      final distance = math.sqrt(x * x + y * y);
                      if (distance < 75 || distance > 135) return;
                      var angle = (math.atan2(y, x) + math.pi / 2) % (2 * math.pi);
                      var end = 0.0;
                      for (var i = 0; i < types.length; i++) {
                        end += totals[i] / total * math.pi * 2;
                        if (angle <= end) {
                          widget.onSelect(types[i] == widget.selected ? null : types[i]);
                          HapticFeedback.selectionClick();
                          break;
                        }
                      }
                    },
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      builder: (context, anim, _) {
                        return CustomPaint(
                          size: const Size(270, 270),
                          painter: _ModernRingPainter(
                            totals: totals,
                            holdings: widget.holdings,
                            selected: widget.selected,
                            nested: widget.nested,
                            animProgress: anim,
                            isDark: Theme.of(context).brightness == Brightness.dark,
                          ),
                        );
                      },
                    ),
                  ),

                  // Center Readout
                  IgnorePointer(
                    child: SizedBox(
                      width: 150,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              widget.selected ?? 'Portfolio',
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            money(selectedValue),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.6,
                              fontFeatures: const [ui.FontFeature.tabularFigures()],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${selectedPct.toStringAsFixed(1)}% of total',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < types.length; i++) ...[
          DataRowTile(
            types[i],
            money(totals[i]),
            subtitle: '${(totals[i] / total * 100).toStringAsFixed(1)}% of portfolio${widget.selected == types[i] ? ' · Selected' : ''}',
            color: assetColors[i],
            onTap: () {
              widget.onSelect(types[i] == widget.selected ? null : types[i]);
              HapticFeedback.selectionClick();
            },
          ),
        ],
      ],
    );
  }
}

class _ModernRingPainter extends CustomPainter {
  _ModernRingPainter({
    required this.totals,
    required this.holdings,
    required this.selected,
    required this.nested,
    required this.animProgress,
    required this.isDark,
  });

  final List<double> totals;
  final List<Holding> holdings;
  final String? selected;
  final bool nested;
  final double animProgress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final total = totals.fold<double>(0, (s, n) => s + n);
    if (total <= 0) return;

    const types = ['Stocks', 'Mutual funds', 'Fixed deposits'];
    final center = Offset(size.width / 2, size.height / 2);
    var startAngle = -math.pi / 2;

    for (var i = 0; i < totals.length; i++) {
      final sweepAngle = (totals[i] / total) * (math.pi * 2) * animProgress;
      final isSelected = selected == null || selected == types[i];
      final isExactMatch = selected == types[i];

      // Segment thickness pops on selection
      final strokeWidth = isExactMatch ? (nested ? 22.0 : 32.0) : (nested ? 16.0 : 26.0);
      final radius = nested ? 95.0 : 108.0;

      // Glow on selected arc
      if (isExactMatch) {
        final glowPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth + 8
          ..color = assetColors[i].withValues(alpha: isDark ? 0.35 : 0.22)
          ..strokeCap = StrokeCap.round;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle + 0.03,
          math.max(0.01, sweepAngle - 0.06),
          false,
          glowPaint,
        );
      }

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = assetColors[i].withValues(alpha: isSelected ? 1.0 : 0.2)
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + 0.03,
        math.max(0.01, sweepAngle - 0.06),
        false,
        paint,
      );

      // Nested outer sub-holdings ring
      if (nested) {
        var outerStart = startAngle;
        final items = holdings.where((h) => h.type == types[i]).toList();
        for (var j = 0; j < items.length; j++) {
          final outerSweep = (items[j].value / total) * (math.pi * 2) * animProgress;
          final outerPaint = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 10.0
            ..color = assetColors[i].withValues(
              alpha: isSelected ? math.min(1.0, 0.45 + j * 0.18) : 0.12,
            )
            ..strokeCap = StrokeCap.round;

          canvas.drawArc(
            Rect.fromCircle(center: center, radius: 124.0),
            outerStart + 0.02,
            math.max(0.01, outerSweep - 0.04),
            false,
            outerPaint,
          );
          outerStart += outerSweep;
        }
      }

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _ModernRingPainter old) {
    return old.selected != selected ||
        old.nested != nested ||
        old.animProgress != animProgress ||
        old.totals != totals;
  }
}
