import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:still_finance/app.dart';
import 'package:still_finance/data/store.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('goal proposal changes only after review and supports undo', (
    tester,
  ) async {
    final store = FinanceStore(MemoryRepository());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [storeProvider.overrideWith((ref) => store)],
        child: const StillApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('home-command-input')),
      250,
      scrollable: find
          .byWidgetPredicate(
            (widget) =>
                widget is Scrollable &&
                widget.axisDirection == AxisDirection.down,
          )
          .first,
    );
    await tester.enterText(
      find.byKey(const ValueKey('home-command-input')),
      'Help with goal g1',
    );
    await tester.tap(find.byTooltip('Send question'));
    await tester.pumpAndSettle();
    expect(store.data.goals.first.monthly, 18000);
    await tester.ensureVisible(find.text('Review proposed change'));
    await tester.tap(find.text('Review proposed change'));
    await tester.pumpAndSettle();
    expect(store.data.goals.first.monthly, 18000);
    await tester.tap(find.text('Apply to goal plan'));
    await tester.pumpAndSettle();
    expect(store.data.goals.first.monthly, 25000);
    await tester.ensureVisible(find.text('Undo last change'));
    await tester.tap(find.text('Undo last change'));
    await tester.pumpAndSettle();
    expect(store.data.goals.first.monthly, 18000);
  });
}
