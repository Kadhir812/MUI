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
  final verticalScrollables = find.byWidgetPredicate(
    (widget) =>
        widget is Scrollable && widget.axisDirection == AxisDirection.down,
  );
  testWidgets('interface palette is applied without changing chart colors', (
    tester,
  ) async {
    await start(tester);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final theme = Theme.of(tester.element(find.text('still.')));

    expect(theme.colorScheme.primary, paletteNavy);
    expect(theme.colorScheme.secondary, paletteTeal);
    expect(theme.colorScheme.tertiary, paletteCoral);
    expect(theme.colorScheme.surface, Colors.white);
    expect(theme.colorScheme.surfaceContainerHighest, Colors.white);
    expect(theme.scaffoldBackgroundColor, lightBackground);
    expect(theme.appBarTheme.backgroundColor, lightBackground);
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
      find.text('FINANCIAL SNAPSHOT · 30 Oct 2026 · No accounts connected'),
      findsOneWidget,
    );
    expect(find.text('OCTOBER 2026'), findsOneWidget);
    expect(find.text('Net worth'), findsOneWidget);
    expect(find.text('Balance snapshot'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-assets-summary')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('home-liabilities-summary')),
      findsOneWidget,
    );
    expect(find.text('Income'), findsOneWidget);
    expect(find.text('Spent'), findsOneWidget);
    expect(find.text('Budget status'), findsOneWidget);
    expect(
      find.text('No monthly limit to compare against yet'),
      findsOneWidget,
    );
    expect(find.byType(CustomScrollView), findsOneWidget);
    expect(find.text('01'), findsNothing);
    expect(find.byType(BottomNavigationBar), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(Drawer), findsNothing);
    final homeScroll = verticalScrollables.first;
    await tester.scrollUntilVisible(
      find.text('Investments'),
      200,
      scrollable: homeScroll,
    );
    expect(find.text('Investments'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Savings goals'),
      200,
      scrollable: homeScroll,
    );
    expect(find.text('Savings goals'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Credit health'),
      200,
      scrollable: homeScroll,
    );
    expect(find.text('Credit health'), findsOneWidget);
    await tester.ensureVisible(find.text('View wealth details  →'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View wealth details  →'));
    await tester.pumpAndSettle();
    expect(find.text('Wealth'), findsOneWidget);
    expect(find.text('BALANCE SHEET · 30 OCTOBER 2026'), findsOneWidget);
    final wealthScroll = verticalScrollables.first;
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
  testWidgets('homepage assets and liabilities open matching item lists', (
    tester,
  ) async {
    await start(tester);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.tap(find.byKey(const ValueKey('home-assets-summary')));
    await tester.pumpAndSettle();
    expect(find.text('WHAT YOU OWN · 30 OCTOBER 2026'), findsOneWidget);
    expect(find.text('Everyday account'), findsOneWidget);
    expect(find.text('Savings account'), findsOneWidget);
    expect(find.text('Infosys'), findsOneWidget);
    expect(find.text('Growth Fixed Deposit'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-liabilities-summary')));
    await tester.pumpAndSettle();
    expect(find.text('WHAT YOU OWE · 30 OCTOBER 2026'), findsOneWidget);
    expect(find.text('Credit card'), findsOneWidget);
    expect(find.text('Total liabilities'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'homepage Ask Still navigates commands and opens clarity for questions',
    (tester) async {
      await start(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('home-command-input')),
        200,
        scrollable: verticalScrollables.first,
      );
      final prompt = find.byKey(const ValueKey('home-command-input'));
      await tester.enterText(prompt, 'What is my income?');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('home-command-send')));
      await tester.pumpAndSettle();
      expect(find.text('A little clarity'), findsOneWidget);
      expect(find.text('What is my income?'), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      await tester.enterText(prompt, 'Open my assets');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('home-command-send')));
      await tester.pumpAndSettle();
      expect(find.text('WHAT YOU OWN · 30 OCTOBER 2026'), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      await tester.enterText(prompt, 'Explain my finances');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('home-command-send')));
      await tester.pumpAndSettle();
      expect(find.text('A little clarity'), findsOneWidget);
      expect(find.text('Explain my finances'), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('home-open-chat')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('home summaries open concise insight, activity, and advice', (
    tester,
  ) async {
    await start(tester);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final scrollable = verticalScrollables.first;

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('home-command-input')),
      200,
      scrollable: scrollable,
    );
    expect(find.byKey(const ValueKey('home-command-input')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Spending insight'),
      300,
      scrollable: scrollable,
    );
    expect(
      find.text('Dining rose ₹2,400 since September—the biggest change.'),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.text('Recent activity'),
      300,
      scrollable: scrollable,
    );
    expect(find.text('Recent activity'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });
  testWidgets('income and spending summaries open their own pages', (
    tester,
  ) async {
    await start(tester);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, 100),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-income-summary')));
    await tester.pumpAndSettle();
    expect(find.text('Income'), findsOneWidget);
    expect(find.text('RECORDED INCOME'), findsOneWidget);
    expect(find.byTooltip('Add income'), findsNothing);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-spending-summary')));
    await tester.pumpAndSettle();
    expect(find.text('Spending & activity'), findsOneWidget);
    expect(find.byTooltip('Add expense'), findsNothing);
    expect(find.text('Add expense'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('settings connection previews request the relevant details', (
    tester,
  ) async {
    await start(tester);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Connections & documents'), findsOneWidget);

    await tester.ensureVisible(find.text('Mutual funds'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mutual funds'));
    await tester.pumpAndSettle();
    expect(find.text('Details to prepare'), findsOneWidget);
    expect(find.text('Document to keep ready'), findsOneWidget);
    expect(find.byKey(const ValueKey('connection-pan')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('connection-registered-contact')),
      findsOneWidget,
    );
    expect(
      find.textContaining('Nothing on this screen is sent or saved.'),
      findsOneWidget,
    );
    await tester.enterText(
      find.byKey(const ValueKey('connection-pan')),
      'ABCDE1234F',
    );
    await tester.enterText(
      find.byKey(const ValueKey('connection-registered-contact')),
      'demo@example.com',
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('connection-continue')),
      200,
      scrollable: verticalScrollables.first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('connection-continue')));
    await tester.pumpAndSettle();
    expect(find.text('Preview only'), findsOneWidget);
    expect(find.textContaining('No connection was made.'), findsOneWidget);
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    final settingsScroll = verticalScrollables.first;
    await tester.scrollUntilVisible(
      find.text('Stocks & demat'),
      250,
      scrollable: settingsScroll,
    );
    await tester.tap(find.text('Stocks & demat'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('connection-broker')), findsOneWidget);
    expect(find.byKey(const ValueKey('connection-demat-id')), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    final fixedDepositScroll = verticalScrollables.first;
    await tester.scrollUntilVisible(
      find.text('Fixed deposits'),
      250,
      scrollable: fixedDepositScroll,
    );
    await tester.tap(find.text('Fixed deposits'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('connection-bank')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('connection-deposit-reference')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('adding income updates income history but not sample net worth', (
    tester,
  ) async {
    final store = await start(tester);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final initialIncome = store.data.incomeTotal(10);
    final initialNetWorth = store.data.netWorth;

    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -180),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-income-summary')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('income-add-record')));
    await tester.tap(find.byKey(const ValueKey('income-add-record')));
    await tester.pumpAndSettle();
    expect(find.text('Add income'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('income-source')),
      'Freelance project',
    );
    await tester.enterText(
      find.byKey(const ValueKey('income-amount')),
      '12500.50',
    );
    await tester.enterText(
      find.byKey(const ValueKey('income-note')),
      'Design work',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('save-income')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-income')));
    await tester.pumpAndSettle();

    expect(store.data.incomeTotal(10), initialIncome + 12500.50);
    expect(store.data.spendTotal(10), 32549);
    expect(store.data.netWorth, initialNetWorth);
    expect(find.text('Freelance project'), findsOneWidget);
    expect(find.text('Income added'), findsOneWidget);

    final restored = FinanceStore(store.repository);
    await restored.load();
    expect(restored.data.incomeTotal(10), initialIncome + 12500.50);
    final added = restored.data
        .income(10)
        .firstWhere((entry) => entry.isManual);
    expect(added.merchant, 'Freelance project');
    expect(added.amount, 12500.50);
    expect(added.account, 'Everyday account');
    expect(added.note, 'Design work');
    expect(restored.data.netWorth, initialNetWorth);
    expect(tester.takeException(), isNull);
  });
  testWidgets('home stories stay concise and respect balance privacy', (
    tester,
  ) async {
    await start(tester);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    expect(
      find.text('Cash grew and investments rose since September.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('home-cashflow-story'), skipOffstage: false),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Hide balances'));
    await tester.pumpAndSettle();
    expect(find.text('Your wealth story is hidden.'), findsOneWidget);
    expect(
      find.text('Your monthly cash-flow story is hidden.', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.textContaining('₹52,451'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('home category summaries drill down to their full pages', (
    tester,
  ) async {
    await start(tester);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.scrollUntilVisible(
      find.text('Investments'),
      200,
      scrollable: verticalScrollables.first,
    );
    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, 100),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Investments'));
    await tester.pumpAndSettle();
    expect(find.text('PORTFOLIO VALUE'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Savings goals'));
    await tester.tap(find.text('Savings goals'));
    await tester.pumpAndSettle();
    expect(find.text('Make room for\nwhat matters.'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Credit health'));
    await tester.tap(find.text('Credit health'));
    await tester.pumpAndSettle();
    expect(find.text('CREDIT SCORE'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
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

    final homeScroll = verticalScrollables.first;
    await tester.scrollUntilVisible(
      find.text('See spending'),
      300,
      scrollable: homeScroll,
    );
    await tester.ensureVisible(find.text('See spending'));
    await tester.pumpAndSettle();
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
    await tester.tap(find.text('View wealth details  →'));
    await tester.pumpAndSettle();
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
