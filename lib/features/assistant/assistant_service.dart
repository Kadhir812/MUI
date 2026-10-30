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
