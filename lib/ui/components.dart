import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/store.dart';

class PageFrame extends ConsumerWidget {
  const PageFrame({
    super.key,
    required this.title,
    required this.children,
    this.actions,
    this.home = false,
  });

  final String title;
  final List<Widget> children;
  final List<Widget>? actions;
  final bool home;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(storeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: home
            ? null
            : Padding(
                padding: const EdgeInsets.only(left: 8),
                child: IconButton(
                  tooltip: 'Back',
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  onPressed: () =>
                      context.canPop() ? context.pop() : context.go('/'),
                ),
              ),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        actions: actions ??
            [
              IconButton(
                tooltip: 'Search your finances',
                onPressed: () => context.push('/search'),
                icon: const Icon(Icons.search_rounded),
              ),
              const SizedBox(width: 6),
            ],
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: CustomScrollView(
              key: PageStorageKey(title),
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (store.error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Notice(store.error!, warning: true),
                        ),
                      for (var i = 0; i < children.length; i++)
                        StaggeredEntrance(
                          delayMs: (i * 24).clamp(0, 300),
                          child: children[i],
                        ),
                    ]),
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

/// Staggered Entrance Animation for silky smooth page reveals
class StaggeredEntrance extends StatelessWidget {
  const StaggeredEntrance({
    super.key,
    required this.child,
    this.delayMs = 0,
  });

  final Widget child;
  final int delayMs;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + delayMs),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, val, child) {
        return Opacity(
          opacity: val,
          child: Transform.translate(
            offset: Offset(0, (1 - val) * 14),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Modern TradingView-styled Card Panel with micro-elevation, subtle border,
/// and smooth interactive press animations.
class Panel extends StatefulWidget {
  const Panel({
    super.key,
    required this.child,
    this.onTap,
    this.tint,
    this.padding = 20,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color? tint;
  final double padding;

  @override
  State<Panel> createState() => _PanelState();
}

class _PanelState extends State<Panel> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutQuad,
        child: Container(
          decoration: BoxDecoration(
            color: widget.tint ?? scheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF1E2836)
                  : const Color(0xFFE2E8F0),
              width: 1,
            ),
            boxShadow: isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              onHighlightChanged: (h) => setState(() => _pressed = h),
              splashColor: scheme.primary.withValues(alpha: 0.08),
              highlightColor: scheme.primary.withValues(alpha: 0.04),
              child: Padding(
                padding: EdgeInsets.all(widget.padding),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.action, this.onTap});

  final String text;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 12),
    child: Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              action!,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
      ],
    ),
  );
}

class Amount extends ConsumerWidget {
  const Amount(this.value, {super.key, this.size = 32, this.decimals = false});

  final num value;
  final double size;
  final bool decimals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(storeProvider).amount(value, decimals: decimals);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.12),
            end: Offset.zero,
          ).animate(anim),
          child: child,
        ),
      ),
      child: Text(
        text,
        key: ValueKey(text),
        style: GoogleFonts.plusJakartaSans(
          fontSize: size,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class Muted extends StatelessWidget {
  const Muted(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: GoogleFonts.plusJakartaSans(
      fontSize: 13,
      height: 1.5,
      fontWeight: FontWeight.w500,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
  );
}

class Notice extends StatelessWidget {
  const Notice(this.text, {super.key, this.warning = false});

  final String text;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: warning
            ? scheme.errorContainer.withValues(alpha: isDark ? 0.4 : 0.6)
            : scheme.primary.withValues(alpha: isDark ? 0.1 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: warning
              ? scheme.error.withValues(alpha: 0.3)
              : scheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            warning ? Icons.info_outline : Icons.auto_awesome_outlined,
            size: 19,
            color: warning ? scheme.error : scheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                height: 1.45,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DataRowTile extends StatelessWidget {
  const DataRowTile(
    this.label,
    this.value, {
    super.key,
    this.onTap,
    this.subtitle,
    this.color,
  });

  final String label, value;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: [
          if (color != null) ...[
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color!.withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Muted(subtitle!),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ],
        ],
      ),
    ),
  );
}

class AskButton extends StatelessWidget {
  const AskButton(this.prompt, {super.key});

  final String prompt;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: OutlinedButton.icon(
      onPressed: () =>
          context.push('/assistant?q=${Uri.encodeComponent(prompt)}'),
      icon: const Icon(Icons.auto_awesome_outlined, size: 17),
      label: Text(
        'Ask about this',
        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
      ),
    ),
  );
}

/// TradingView-inspired segmented pill bar selector with smooth animated slide indicator
class Choices extends StatelessWidget {
  const Choices({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelect,
  });

  final List<String> items;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131A24) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF1E2836) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: items.map((item) {
            final isChosen = selected == item;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelect(item);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isChosen
                        ? (isDark ? const Color(0xFF1E293B) : Colors.white)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isChosen
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    item,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: isChosen ? FontWeight.w700 : FontWeight.w500,
                      color: isChosen
                          ? scheme.onSurface
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Smooth animated progress bar with gradient glow
class ProgressLine extends StatelessWidget {
  const ProgressLine(this.value, {super.key, this.color});

  final double value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final targetColor = color ?? scheme.primary;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0.0, end: value.clamp(0.0, 1.0)),
      builder: (context, animatedVal, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 9,
            decoration: BoxDecoration(
              color: scheme.onSurface.withValues(alpha: 0.08),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: animatedVal,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          targetColor.withValues(alpha: 0.8),
                          targetColor,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: targetColor.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<void> reportChange(
  BuildContext context,
  FinanceStore store,
  Future<bool> operation,
  String message,
) async {
  final ok = await operation;
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      content: Text(
        ok ? message : store.error ?? 'Change could not be applied.',
        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
      ),
      action: ok && store.canUndo
          ? SnackBarAction(
              label: 'Undo',
              onPressed: () async {
                await store.undo();
              },
            )
          : null,
    ),
  );
}
