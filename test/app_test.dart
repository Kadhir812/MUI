import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:still_finance/app.dart';
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
  testWidgets('home is menuless and wealth drill-down returns correctly', (
    tester,
  ) async {
    await start(tester);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    expect(find.text('still.'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(Drawer), findsNothing);
    await tester.tap(find.text('Explore your wealth  →'));
    await tester.pumpAndSettle();
    expect(find.text('Your wealth'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('still.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('privacy hides the hero amount and chart', (tester) async {
    await start(tester, hidden: true);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    expect(find.text('₹11,73,200'), findsNothing);
    expect(find.text('Chart hidden for privacy'), findsOneWidget);
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
    expect(tester.takeException(), isNull);
  });
  testWidgets('overview handles a narrow viewport', (tester) async {
    await start(tester, size: const Size(320, 740));
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    expect(tester.takeException(), isNull);
  });
}
