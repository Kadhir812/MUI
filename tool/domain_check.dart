// Dependency-free financial checks. Run: dart tool/domain_check.dart
import 'package:still_finance/data/models.dart';
import 'package:still_finance/data/seed.dart';
import 'package:still_finance/features/assistant/assistant_service.dart';

int checks = 0;
void verify(bool condition, String label) {
  if (!condition) throw StateError(label);
  checks++;
  print('PASS $label');
}

bool close(double a, double b) => (a - b).abs() < .01;
void main() {
  final d = seedData();
  verify(close(d.investmentValue, 825200), 'Holdings reconcile to portfolio');
  verify(close(d.invested, 754000), 'Original investment reconciles');
  verify(close(d.netWorth, 1173200), 'Net worth is assets less liabilities');
  verify(
    close(d.wealthHistory.last, d.netWorth),
    'Latest wealth chart equals summary',
  );
  verify(
    close(d.portfolioHistory.last, d.investmentValue),
    'Latest portfolio chart equals holdings',
  );
  verify(
    close(d.spendTotal(10), 32549),
    'October spending excludes salary and internal transfer',
  );
  verify(close(d.spendTotal(9), 28749), 'September spending reconciles');
  verify(
    close(
      d.spendTotal(10, category: 'Dining') -
          d.spendTotal(9, category: 'Dining'),
      2400,
    ),
    'Dining insight is derived from records',
  );
  verify(
    close(
      d.categoryTotals(10).values.fold<double>(0, (a, b) => a + b),
      d.spendTotal(10),
    ),
    'Categories reconcile to spending',
  );
  verify(
    close(d.allocatedSavings, FinancialData.savings),
    'Goals allocate existing savings without double counting',
  );
  verify(
    d.goals.every(
      (g) => close(g.contributions.fold<double>(0, (a, b) => a + b), g.saved),
    ),
    'Goal history reconciles to saved amount',
  );
  verify(
    close(d.goals.first.requiredMonthly, 25000),
    'Goal required monthly amount uses remaining contribution months',
  );
  verify(
    d.entries.map((e) => e.id).toSet().length == d.entries.length,
    'Transaction identifiers are unique',
  );
  final before = d.spendTotal(10);
  final e = d.entries.firstWhere(
    (e) => e.date.month == 10 && e.category == 'Dining',
  );
  final i = d.entries.indexOf(e);
  d.entries[i] = e.withCategory('Groceries');
  verify(
    close(d.spendTotal(10), before),
    'Categorization preserves total spending',
  );
  verify(
    close(d.spendTotal(10, category: 'Dining'), 6200 - e.amount),
    'Categorization updates category aggregation',
  );
  d.entries.add(
    Entry(
      id: 'refund-test',
      merchant: 'Refund',
      amount: 100,
      date: DateTime(2026, 10, 20),
      category: 'Groceries',
      kind: 'refund',
    ),
  );
  verify(close(d.spendTotal(10), before - 100), 'Refunds reduce net spending');
  final p = GoalProposal(d.goals.first);
  verify(p.isCurrent(d.goals.first), 'Proposal matches source goal');
  verify(
    !p.isCurrent(d.goals.first.copyWith(monthly: 1)),
    'Changed goal invalidates stale proposal',
  );
  verify(
    DemoAssistantService().answer('Help with my savings goals', d).goalId ==
        null,
    'Ambiguous goal asks user to choose',
  );
  verify(
    DemoAssistantService().answer('Help with goal g1', d).goalId == 'g1',
    'Exact goal intent resolves',
  );
  verify(
    DemoAssistantService().answer('Transfer money', d).kind ==
        AnswerKind.unsupported,
    'Unsupported money movement is not simulated as success',
  );
  verify(
    d.entries.every(
      (e) => (e.amount * 100 - (e.amount * 100).round()).abs() < .0001,
    ),
    'Every transaction has integer paise precision',
  );
  print('$checks financial and intent checks passed.');
}
