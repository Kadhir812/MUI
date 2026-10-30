import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:still_finance/app.dart';
import 'package:still_finance/core/theme.dart';
import 'package:still_finance/data/store.dart';

Future<FinanceStore> start(
  WidgetTester tester, {
  bool hidden = false,
  Size size = const Size(390, 844),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  final store = FinanceStore(MemoryRepository());
  store.hidden = hidden;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [storeProvider.overrideWith((ref) => store)],
      child: const StillApp(),
    ),
  );
  await tester.pumpAndSettle();
  return store;
}

void main() {
  tearDown(() {});
  testWidgets('interface palette is applied without changing chart colors', (
    tester,
  ) async {
    await start(tester);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final theme = Theme.of(tester.element(find.text('still.')));

    expect(theme.colorScheme.primary, paletteRose);
    expect(theme.colorScheme.secondary, paletteBlue);
    expect(theme.colorScheme.tertiary, paletteCoral);
    expect(theme.colorScheme.surface, Colors.white);
    expect(theme.colorScheme.surfaceContainerHighest, paletteCream);
    expect(theme.scaffoldBackgroundColor, Colors.white);
    expect(theme.appBarTheme.backgroundColor, Colors.white);
    final nightTheme = appTheme(true);
    expect(nightTheme.brightness, Brightness.dark);
    expect(nightTheme.scaffoldBackgroundColor, nightBackground);
    expect(nightTheme.colorScheme.surface, nightSurface);
    expect(nightTheme.colorScheme.surfaceContainerHighest, nightSurfaceRaised);
    expect(nightTheme.colorScheme.onSurface, nightText);
    expect(
      nightTheme.colorScheme.onSurface.computeLuminance(),
      greaterThan(nightTheme.colorScheme.surface.computeLuminance()),
    );
    expect(chartGreen, const Color(0xFF089981));
    expect(chartRed, const Color(0xFFF23645));
    expect(chartGridLight, const Color(0xFFE2E8F0));
    expect(chartGridDark, const Color(0xFF1E293B));
    expect(assetColors, const [
      Color(0xFF3B82F6),
      Color(0xFF8B5CF6),
      Color(0xFFF59E0B),
    ]);
  });
  testWidgets('home is menuless and wealth drill-down returns correctly', (
    tester,
  ) async {
    await start(tester);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    expect(find.text('still.'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-add-expense')), findsNothing);
    expect(
      find.text('SAMPLE DATA · 30 Oct 2026 · No accounts connected'),
      findsOneWidget,
    );
    expect(find.text('YOUR MONEY, THIS MONTH'), findsOneWidget);
    expect(
      find.text('A simple picture of where things stand.'),
      findsOneWidget,
    );
    expect(find.text('What you would have left'), findsOneWidget);
    expect(
      find.textContaining('After debts, you would have ₹38,100 more'),
      findsOneWidget,
    );
    expect(find.byType(BottomNavigationBar), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(Drawer), findsNothing);
    await tester.ensureVisible(find.text('Explore your wealth  →'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Explore your wealth  →'));
    await tester.pumpAndSettle();
    expect(find.text('Wealth'), findsOneWidget);
    expect(find.text('BALANCE SHEET · 30 OCTOBER 2026'), findsOneWidget);
    final wealthScroll = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('Total assets'),
      250,
      scrollable: wealthScroll,
    );
    expect(find.text('Total assets'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Total owed'),
      250,
      scrollable: wealthScroll,
    );
    expect(find.text('Total owed'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Change since 30 September'),
      250,
      scrollable: wealthScroll,
    );
    expect(find.text('Change since 30 September'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('+₹38,100'),
      250,
      scrollable: wealthScroll,
    );
    expect(find.text('+₹38,100'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.textContaining('recent transactions do not calculate them'),
      250,
      scrollable: wealthScroll,
    );
    expect(
      find.textContaining('recent transactions do not calculate them'),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('still.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('home story explains changes and ends with a next question', (
    tester,
  ) async {
    await start(tester);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final scrollable = find.byType(Scrollable).first;

    await tester.scrollUntilVisible(
      find.textContaining('Dining had the largest increase'),
      300,
      scrollable: scrollable,
    );
    expect(
      find.textContaining('Dining had the largest increase'),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.textContaining('about ₹25,000 is needed'),
      300,
      scrollable: scrollable,
    );
    expect(find.textContaining('about ₹25,000 is needed'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('What would you like help with?'),
      300,
      scrollable: scrollable,
    );
    expect(find.text('What would you like help with?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('adding an expense updates spending and persists locally', (
    tester,
  ) async {
    final store = await start(tester);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final initialSpend = store.data.spendTotal(10);
    final initialNetWorth = store.data.netWorth;

    final homeScroll = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('See spending'),
      300,
      scrollable: homeScroll,
    );
    await tester.tap(find.text('See spending'));
    await tester.pumpAndSettle();
    expect(find.text('Spending & activity'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('spending-add-expense')));
    await tester.pumpAndSettle();
    expect(find.text('Add expense'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('expense-merchant')),
      'Lunch with friends',
    );
    await tester.enterText(
      find.byKey(const ValueKey('expense-amount')),
      '125.50',
    );
    await tester.tap(find.byKey(const ValueKey('expense-category')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dining').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('expense-note')),
      'Team lunch',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('save-expense')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-expense')));
    await tester.pumpAndSettle();

    final manualEntries = store.data.entries
        .where((entry) => entry.isManual)
        .toList();
    expect(manualEntries, hasLength(1));
    expect(manualEntries.single.merchant, 'Lunch with friends');
    expect(manualEntries.single.amount, 125.50);
    expect(manualEntries.single.category, 'Dining');
    expect(manualEntries.single.account, 'Everyday account');
    expect(manualEntries.single.note, 'Team lunch');
    expect(store.data.spendTotal(10), initialSpend + 125.50);
    expect(store.data.netWorth, initialNetWorth);

    final restored = FinanceStore(store.repository);
    await restored.load();
    final restoredEntry = restored.data.entries.singleWhere(
      (entry) => entry.isManual,
    );
    expect(restoredEntry.merchant, 'Lunch with friends');
    expect(restoredEntry.amount, 125.50);
    expect(restoredEntry.category, 'Dining');
    expect(restored.data.netWorth, initialNetWorth);
    expect(tester.takeException(), isNull);
  });
  testWidgets('privacy hides the hero amount and chart', (tester) async {
    await start(tester, hidden: true);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    expect(find.text('₹11,73,200'), findsNothing);
    expect(find.text('Chart hidden for privacy'), findsOneWidget);
    expect(find.textContaining('of the way to'), findsNothing);
  });
  testWidgets('net worth chart switches timeframes without inventing history', (
    tester,
  ) async {
    await start(tester);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    expect(find.text('1D'), findsOneWidget);
    expect(find.text('1W'), findsOneWidget);
    expect(find.text('1M'), findsOneWidget);
    expect(find.text('1Y'), findsOneWidget);
    await tester.tap(find.text('1D'));
    await tester.pumpAndSettle();
    expect(
      find.text('Only monthly snapshots are available for this range.'),
      findsOneWidget,
    );
    await tester.tap(find.text('1Y'));
    await tester.pumpAndSettle();
    expect(find.text('Monthly snapshots · May–Oct 2026'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('investments allocation and performance views render', (
    tester,
  ) async {
    await start(tester);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Investments'), findsOneWidget);
    await tester.tap(find.text('Investments').first);
    await tester.pumpAndSettle();
    expect(find.text('Show holdings ring'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.drag(
      find.byType(CustomScrollView).last,
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.drag(find.byType(CustomScrollView).last, const Offset(0, 400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Performance'));
    await tester.pumpAndSettle();
    expect(find.text('Detailed price points'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('search interprets last month groceries', (tester) async {
    await start(tester);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.tap(find.byTooltip('Search your finances'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'last month groceries');
    await tester.pumpAndSettle();
    expect(find.text('September'), findsOneWidget);
    await tester.tap(find.text('Groceries'));
    await tester.pumpAndSettle();
    expect(find.text('Spending & activity'), findsOneWidget);
    expect(find.textContaining('not a complete bank history'), findsOneWidget);
    expect(
      find.textContaining('do not reconcile account balances'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('overview handles a narrow viewport', (tester) async {
    await start(tester, size: const Size(320, 740));
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    expect(tester.takeException(), isNull);
  });
}
