import 'transaction_proposal_card.dart';
import '../../core/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../../ui/components.dart';
import 'assistant_service.dart';

class AssistantPage extends ConsumerStatefulWidget {
  const AssistantPage({super.key, this.initialPrompt = ''});
  final String initialPrompt;
  @override
  ConsumerState<AssistantPage> createState() => _AssistantPageState();
}

class _Turn {
  _Turn(this.prompt, this.answer, this.proposal);
  final String prompt;
  final AssistantAnswer answer;
  final GoalProposal? proposal;
  bool applied = false;
}

class _AssistantPageState extends ConsumerState<AssistantPage> {
  final input = TextEditingController();
  final scroll = ScrollController();
  final service = DemoAssistantService();
  final turns = <_Turn>[];
  @override
  void initState() {
    super.initState();
    if (widget.initialPrompt.isNotEmpty) _append(widget.initialPrompt);
  }

  void _append(String prompt) {
    final data = ref.read(storeProvider).data;
    final answer = service.answer(prompt, data);
    final goals = data.goals.where((g) => g.id == answer.goalId);
    turns.add(
      _Turn(prompt, answer, goals.isEmpty ? null : GoalProposal(goals.first)),
    );
  }

  void send([String? preset]) {
    final prompt = (preset ?? input.text).trim();
    if (prompt.isEmpty) return;
    setState(() {
      _append(prompt);
      input.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll.hasClients) scroll.jumpTo(scroll.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    input.dispose();
    scroll.dispose();
    super.dispose();
  }

  Widget response(_Turn turn, FinanceStore s) {
    final d = s.data;
    switch (turn.answer.kind) {
      case AnswerKind.category:
        return TransactionProposalCard(
          transactionId: turn.answer.transactionId ?? '',
        );
      case AnswerKind.spending:
        final delta = d.spendTotal(10) - d.spendTotal(9);
        final changes =
            categories
                .map(
                  (c) => MapEntry(
                    c,
                    d.spendTotal(10, category: c) -
                        d.spendTotal(9, category: c),
                  ),
                )
                .toList()
              ..sort((a, b) => b.value.compareTo(a.value));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Here’s what changed.',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              'October spending is ${s.amount(delta.abs())} ${delta >= 0 ? 'higher' : 'lower'} than September, comparing activity through day 30.',
            ),
            const SizedBox(height: 12),
            for (final c in changes.take(3))
              DataRowTile(
                c.key,
                '${c.value >= 0 ? '+' : '−'}${s.amount(c.value.abs())}',
                onTap: () => context.push(
                  '/spending?category=${Uri.encodeComponent(c.key)}',
                ),
              ),
            const Muted(
              'Source: sample expense transactions. Income and internal transfers excluded. A change in spending is not automatically a problem.',
            ),
            TextButton(
              onPressed: () => context.push('/spending'),
              child: const Text('Inspect all spending →'),
            ),
          ],
        );
      case AnswerKind.portfolio:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your portfolio, in context.',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              'Your ${s.amount(d.invested)} original investment is valued at ${s.amount(d.investmentValue)}. The difference is ${s.amount(d.investmentValue - d.invested)}.',
            ),
            const SizedBox(height: 12),
            const Muted(
              'Source: five sample holdings, valued 30 October. No contributions or withdrawals after 1 May. FD interest is projected separately. This explains the sample; it does not recommend a trade.',
            ),
            TextButton(
              onPressed: () => context.push('/investments'),
              child: const Text('Open allocation & holdings →'),
            ),
          ],
        );
      case AnswerKind.wealth:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'A complete picture.',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            DataRowTile('Assets', s.amount(d.assets)),
            DataRowTile('Liabilities', s.amount(FinancialData.liabilities)),
            DataRowTile('Net worth', s.amount(d.netWorth)),
            const Muted(
              'Savings assigned to goals are already part of assets. They are not counted again. Source: balances and holdings dated 30 October.',
            ),
            TextButton(
              onPressed: () => context.push('/wealth'),
              child: const Text('Inspect the calculation →'),
            ),
          ],
        );
      case AnswerKind.credit:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.hidden
                  ? 'Credit details hidden.'
                  : 'Your illustrative score is 782. The sample shows 12 on-time payments and 24.25% utilization.',
            ),
            const SizedBox(height: 12),
            const Muted(
              'No credit bureau is connected. These factors describe sample data and do not predict a real score change.',
            ),
            TextButton(
              onPressed: () => context.push('/credit'),
              child: const Text('Inspect credit details →'),
            ),
          ],
        );
      case AnswerKind.goal:
        final found = d.goals.where((g) => g.id == turn.answer.goalId);
        if (found.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Which goal should we plan for?'),
              for (final g in d.goals)
                TextButton(
                  onPressed: () => send('Help with goal ${g.id}'),
                  child: Text(g.name),
                ),
              if (d.goals.isEmpty)
                TextButton(
                  onPressed: () => context.push('/goals/new/edit'),
                  child: const Text('Create a goal'),
                ),
            ],
          );
        }
        final goal = found.first, proposal = turn.proposal!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A plan for ${goal.name.toLowerCase()}.',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              'You have ${s.amount(goal.remaining)} remaining and ${goal.monthsLeft} planned monthly contributions before ${shortDate(goal.deadline)}.',
            ),
            DataRowTile('Current monthly plan', s.amount(goal.monthly)),
            DataRowTile(
              'Proposed monthly plan',
              s.amount(proposal.proposedMonthly),
            ),
            const Muted(
              'Assumes no interest or withdrawals, with the first contribution next month. This is the amount needed to hit the target, not a claim that you can afford it.',
            ),
            const SizedBox(height: 16),
            if (turn.applied) ...[
              const Notice('Plan updated. No money was moved.'),
              if (s.canUndo)
                TextButton(
                  onPressed: s.busy
                      ? null
                      : () async {
                          final ok = await s.undo();
                          if (ok && mounted) {
                            setState(() => turn.applied = false);
                          }
                        },
                  child: const Text('Undo last change'),
                ),
            ] else if (!proposal.isCurrent(goal)) ...[
              const Notice(
                'This goal changed after the proposal was created. Refresh the proposal before applying it.',
              ),
              TextButton(
                onPressed: () => send('Help with goal ${goal.id}'),
                child: const Text('Refresh proposal'),
              ),
            ] else if (proposal.proposedMonthly == goal.monthly)
              const Notice(
                'Your current plan already matches the required monthly contribution.',
              )
            else
              FilledButton(
                onPressed: s.busy || s.hidden
                    ? null
                    : () => review(turn, goal, s),
                child: const Text('Review proposed change'),
              ),
            if (s.hidden)
              const Muted(
                'Show balances in Settings before reviewing a financial change.',
              ),
            TextButton(
              onPressed: () => context.push('/goals/${goal.id}'),
              child: const Text('View goal & contribution history →'),
            ),
          ],
        );
      case AnswerKind.unsupported:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This offline demo can explain spending, wealth, investments and credit, or propose a goal plan. It cannot connect accounts or move money.',
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.push('/search'),
              child: const Text('Search financial records instead →'),
            ),
          ],
        );
    }
  }

  Future<void> review(_Turn turn, Goal goal, FinanceStore s) async {
    final p = turn.proposal!;
    final approved = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Review before applying',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(goal.name),
              DataRowTile('Monthly plan · before', s.amount(goal.monthly)),
              DataRowTile('Monthly plan · after', s.amount(p.proposedMonthly)),
              DataRowTile('Target · unchanged', s.amount(goal.target)),
              DataRowTile('Deadline · unchanged', shortDate(goal.deadline)),
              const Notice(
                'Only the local goal plan changes. No payment is scheduled and no money moves. Undo is available.',
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Apply to goal plan'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Keep current plan'),
              ),
            ],
          ),
        ),
      ),
    );
    if (approved != true || !mounted) return;
    final current = s.data.goals.where((g) => g.id == goal.id);
    if (current.isEmpty || !p.isCurrent(current.first)) {
      setState(() {});
      return;
    }
    final ok = await s.saveGoal(
      current.first.copyWith(monthly: p.proposedMonthly),
    );
    if (ok && mounted) setState(() => turn.applied = true);
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(storeProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('A little clarity'),
        actions: [
          IconButton(
            tooltip: 'Clear conversation',
            onPressed: () => setState(turns.clear),
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    controller: scroll,
                    padding: const EdgeInsets.all(22),
                    children: [
                      const Notice(
                        'Demo assistant · Sample data only. Changes require your review.',
                      ),
                      const SizedBox(height: 20),
                      if (s.error != null) Notice(s.error!, warning: true),
                      if (turns.isEmpty) ...[
                        const Text(
                          'What would you like\nto understand?',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        for (final prompt in [
                          'Why did spending increase?',
                          'Explain my portfolio',
                          'Help with my savings goals',
                        ])
                          Panel(
                            onTap: () => send(prompt),
                            child: Row(
                              children: [
                                Expanded(child: Text(prompt)),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                      ],
                      for (final turn in turns) ...[
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            margin: const EdgeInsets.only(top: 16, bottom: 14),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: .1),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Text(
                              turn.prompt.startsWith('Help with goal g')
                                  ? 'Help me plan for this goal'
                                  : turn.prompt,
                            ),
                          ),
                        ),
                        Panel(child: response(turn, s)),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: input,
                          minLines: 1,
                          maxLines: 4,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => send(),
                          decoration: const InputDecoration(
                            labelText: 'Ask about your money',
                            hintText: 'A question or a goal…',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        tooltip: 'Send question',
                        onPressed: () => send(),
                        icon: const Icon(Icons.arrow_upward_rounded),
                      ),
                    ],
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
