import '../../data/models.dart';

enum AnswerKind {
  category,
  spending,
  portfolio,
  wealth,
  goal,
  credit,
  unsupported,
}

class AssistantAnswer {
  const AssistantAnswer(this.kind, {this.goalId, this.transactionId});
  final AnswerKind kind;
  final String? goalId;
  final String? transactionId;
}

/// Deterministic intent router. Replace this boundary with an agent service later.
/// No network request, external model, or financial action is performed here.
class DemoAssistantService {
  String destination(String prompt, FinancialData data) {
    final q = prompt.toLowerCase().trim();

    if (_isQuestion(q)) {
      return '/assistant?q=${Uri.encodeQueryComponent(prompt.trim())}';
    }

    final holding = data.holdings.where(
      (item) => q.contains(item.name.toLowerCase()),
    );
    if (holding.isNotEmpty) return '/holdings/${holding.first.id}';

    final goal = data.goals.where(
      (item) => q.contains(item.name.toLowerCase()),
    );
    if (goal.isNotEmpty) return '/goals/${goal.first.id}';

    if (_hasAny(q, const ['credit score', 'credit health', 'credit rating'])) {
      return '/credit';
    }
    if (_hasAny(q, const ['liabilit', 'what i owe', 'debt', 'loan'])) {
      return '/balance-sheet/liabilities';
    }
    if (_hasAny(q, const ['asset', 'what i own'])) {
      return '/balance-sheet/assets';
    }
    if (_hasAny(q, const ['net worth', 'wealth'])) return '/wealth';
    if (_hasAny(q, const ['income', 'salary', 'earning', 'paycheck', 'pay '])) {
      return '/income';
    }
    if (_hasAny(q, const [
      'spend',
      'expense',
      'transaction',
      'grocer',
      'dining',
    ])) {
      return '/spending';
    }
    if (_hasAny(q, const ['mutual fund', 'mutual funds'])) {
      return '/investments?type=Mutual%20funds';
    }
    if (_hasAny(q, const ['fixed deposit', 'fd ', ' fd', 'maturity'])) {
      return '/investments?type=Fixed%20deposits';
    }
    if (_hasAny(q, const ['stock', 'share', 'equity'])) {
      return '/investments?type=Stocks';
    }
    if (_hasAny(q, const ['invest', 'portfolio', 'fund'])) {
      return '/investments';
    }
    if (_hasAny(q, const ['goal', 'saving', 'emergency fund'])) {
      return '/goals';
    }
    if (_hasAny(q, const ['credit', 'score', 'utilization'])) return '/credit';
    return '/assistant?q=${Uri.encodeQueryComponent(prompt.trim())}';
  }

  AssistantAnswer answer(String prompt, FinancialData data) {
    final q = prompt.toLowerCase();
    if (q.startsWith('categorize transaction ')) {
      return AssistantAnswer(
        AnswerKind.category,
        transactionId: q.substring('categorize transaction '.length).trim(),
      );
    }
    if (q.contains('goal') ||
        q.contains('emergency') ||
        q.contains('save') ||
        q.contains('saving')) {
      final exact = data.goals.where(
        (g) =>
            q.contains(g.id.toLowerCase()) || q.contains(g.name.toLowerCase()),
      );
      if (exact.isNotEmpty) {
        return AssistantAnswer(AnswerKind.goal, goalId: exact.first.id);
      }
      return const AssistantAnswer(AnswerKind.goal);
    }
    if (q.contains('spend') || q.contains('dining') || q.contains('grocer')) {
      return const AssistantAnswer(AnswerKind.spending);
    }
    if (q.contains('portfolio') ||
        q.contains('invest') ||
        q.contains('fund') ||
        q.contains('deposit')) {
      return const AssistantAnswer(AnswerKind.portfolio);
    }
    if (q.contains('wealth') || q.contains('worth') || q.contains('assets')) {
      return const AssistantAnswer(AnswerKind.wealth);
    }
    if (q.contains('credit')) return const AssistantAnswer(AnswerKind.credit);
    return const AssistantAnswer(AnswerKind.unsupported);
  }

  bool _hasAny(String value, List<String> terms) => terms.any(value.contains);

  bool _isQuestion(String value) =>
      value.endsWith('?') ||
      _hasAny(value, const [
        'what ',
        'why ',
        'how ',
        'when ',
        'which ',
        'explain ',
        'tell me ',
        'help ',
        'meaning',
        'mean ',
        'how much',
      ]);
}

class GoalProposal {
  GoalProposal(Goal goal)
    : goalId = goal.id,
      originalMonthly = goal.monthly,
      originalTarget = goal.target,
      originalSaved = goal.saved,
      originalDeadline = goal.deadline,
      proposedMonthly = goal.requiredMonthly.ceilToDouble();
  final String goalId;
  final double originalMonthly, originalTarget, originalSaved, proposedMonthly;
  final DateTime originalDeadline;
  bool isCurrent(Goal goal) =>
      goal.id == goalId &&
      goal.monthly == originalMonthly &&
      goal.target == originalTarget &&
      goal.saved == originalSaved &&
      goal.deadline == originalDeadline;
}
