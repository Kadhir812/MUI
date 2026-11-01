import 'package:flutter_test/flutter_test.dart';
import 'package:still_finance/data/store.dart';

class FailingRepository extends MemoryRepository {
  bool fail = false;
  @override
  Future<void> write(String snapshot) async {
    if (fail) throw StateError('Simulated disk error');
    await super.write(snapshot);
  }
}

void main() {
  test(
    'category edits persist and undo restores their financial effect',
    () async {
      final repo = MemoryRepository();
      final store = FinanceStore(repo);
      final id = store.data.entries
          .firstWhere((e) => e.category == 'Dining' && e.date.month == 10)
          .id;
      final old = store.data.spendTotal(10, category: 'Dining');
      expect(await store.categorize(id, 'Groceries'), isTrue);
      expect(store.data.spendTotal(10, category: 'Dining'), lessThan(old));
      final restored = FinanceStore(repo);
      await restored.load();
      expect(
        restored.data.entries.firstWhere((e) => e.id == id).category,
        'Groceries',
      );
      expect(await store.undo(), isTrue);
      expect(store.data.spendTotal(10, category: 'Dining'), closeTo(old, .01));
    },
  );
  test('write failure rolls back data and does not claim success', () async {
    final repo = FailingRepository();
    final store = FinanceStore(repo);
    final goal = store.data.goals.first;
    repo.fail = true;
    expect(await store.saveGoal(goal.copyWith(monthly: 25000)), isFalse);
    expect(store.data.goals.first.monthly, goal.monthly);
    expect(store.error, isNotNull);
    expect(store.busy, isFalse);
  });
  test(
    'income records persist and affect income totals, not sample balances',
    () async {
      final repository = MemoryRepository();
      final store = FinanceStore(repository);
      final startingIncome = store.data.incomeTotal(10);
      final startingSpending = store.data.spendTotal(10);
      final startingNetWorth = store.data.netWorth;

      expect(
        await store.addIncome(
          source: 'Freelance work',
          amount: 12500.50,
          date: DateTime(2026, 10, 30),
          account: 'Savings account',
          note: 'Design project',
        ),
        isTrue,
      );
      expect(store.data.incomeTotal(10), startingIncome + 12500.50);
      expect(store.data.spendTotal(10), startingSpending);
      expect(store.data.netWorth, startingNetWorth);

      final restored = FinanceStore(repository);
      await restored.load();
      final income = restored.data
          .income(10)
          .firstWhere((entry) => entry.isManual);
      expect(income.merchant, 'Freelance work');
      expect(income.amount, 12500.50);
      expect(income.account, 'Savings account');
      expect(income.note, 'Design project');
    },
  );
  test('invalid income is rejected without changing totals', () async {
    final store = FinanceStore(MemoryRepository());
    final total = store.data.incomeTotal(10);

    expect(
      await store.addIncome(
        source: ' ',
        amount: -1,
        date: DateTime(2026, 10, 30),
        account: 'Everyday account',
      ),
      isFalse,
    );
    expect(store.data.incomeTotal(10), total);
    expect(store.error, isNotNull);
  });
  test('undo preserves appearance and privacy preferences', () async {
    final store = FinanceStore(MemoryRepository());
    final goal = store.data.goals.first;
    await store.saveGoal(goal.copyWith(monthly: 25000));
    await store.setDark(true);
    await store.setHidden(true);
    await store.undo();
    expect(store.data.goals.first.monthly, goal.monthly);
    expect(store.dark, isTrue);
    expect(store.hidden, isTrue);
  });
  test('invalid target is rejected and original goal is retained', () async {
    final store = FinanceStore(MemoryRepository());
    final goal = store.data.goals.first;
    expect(
      await store.saveGoal(goal.copyWith(target: goal.saved - 1)),
      isFalse,
    );
    expect(store.data.goals.first.target, goal.target);
  });
  test('corrupt snapshots produce a visible recoverable state', () async {
    final repo = MemoryRepository()..value = '{broken';
    final store = FinanceStore(repo);
    await store.load();
    expect(store.error, isNotNull);
    expect(store.data.goals, isNotEmpty);
    expect(await store.reset(), isTrue);
  });
}
