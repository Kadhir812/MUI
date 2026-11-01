import '../features/wealth/account_page.dart';
import '../features/investments/holding_page.dart';
import '../features/goals/goal_detail_page.dart';
import '../features/goals/goal_editor_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/overview/overview_page.dart';
import '../features/wealth/wealth_page.dart';
import '../features/wealth/balance_sheet_page.dart';
import '../features/investments/investments_page.dart';
import '../features/spending/spending_page.dart';
import '../features/spending/transaction_page.dart';
import '../features/spending/expense_form_page.dart';
import '../features/income/income_page.dart';
import '../features/income/income_form_page.dart';
import '../features/goals/goals_page.dart';
import '../features/credit/credit_page.dart';
import '../features/assistant/assistant_page.dart';
import '../features/search/search_page.dart';
import '../features/settings/settings_page.dart';
import '../features/settings/connection_request_page.dart';
import '../ui/components.dart';

Page<void> platformPage(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
    return NoTransitionPage<void>(key: state.pageKey, child: child);
  }
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final transition = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: transition,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.025, 0),
            end: Offset.zero,
          ).animate(transition),
          child: child,
        ),
      );
    },
  );
}

GoRouter makeRouter() => GoRouter(
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (c, s) => platformPage(c, s, const OverviewPage()),
    ),
    GoRoute(
      path: '/wealth',
      pageBuilder: (c, s) => platformPage(c, s, const WealthPage()),
    ),
    GoRoute(
      path: '/balance-sheet/:section',
      pageBuilder: (c, s) => platformPage(
        c,
        s,
        BalanceSheetPage(section: s.pathParameters['section']!),
      ),
    ),
    GoRoute(
      path: '/accounts/:id',
      pageBuilder: (c, s) =>
          platformPage(c, s, AccountPage(id: s.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/investments',
      pageBuilder: (c, s) => platformPage(
        c,
        s,
        InvestmentsPage(initialType: s.uri.queryParameters['type']),
      ),
    ),
    GoRoute(
      path: '/holdings/:id',
      pageBuilder: (c, s) =>
          platformPage(c, s, HoldingPage(id: s.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/spending',
      pageBuilder: (c, s) => platformPage(
        c,
        s,
        SpendingPage(
          initialCategory: s.uri.queryParameters['category'],
          initialMonth:
              int.tryParse(
                s.uri.queryParameters['month'] ?? '',
              )?.clamp(8, 10).toInt() ??
              10,
        ),
      ),
    ),
    GoRoute(
      path: '/income',
      pageBuilder: (c, s) => platformPage(
        c,
        s,
        IncomePage(
          initialMonth:
              int.tryParse(
                s.uri.queryParameters['month'] ?? '',
              )?.clamp(8, 10).toInt() ??
              10,
        ),
      ),
    ),
    GoRoute(
      path: '/income/new',
      pageBuilder: (c, s) => platformPage(c, s, const IncomeFormPage()),
    ),
    GoRoute(
      path: '/expenses/new',
      pageBuilder: (c, s) => platformPage(c, s, const ExpenseFormPage()),
    ),
    GoRoute(
      path: '/transactions/:id',
      pageBuilder: (c, s) =>
          platformPage(c, s, TransactionPage(id: s.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/goals',
      pageBuilder: (c, s) => platformPage(c, s, const GoalsPage()),
    ),
    GoRoute(
      path: '/goals/:id/edit',
      pageBuilder: (c, s) =>
          platformPage(c, s, GoalEditor(id: s.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/goals/:id',
      pageBuilder: (c, s) =>
          platformPage(c, s, GoalPage(id: s.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/credit',
      pageBuilder: (c, s) => platformPage(c, s, const CreditPage()),
    ),
    GoRoute(
      path: '/assistant',
      pageBuilder: (c, s) => platformPage(
        c,
        s,
        AssistantPage(initialPrompt: s.uri.queryParameters['q'] ?? ''),
      ),
    ),
    GoRoute(
      path: '/search',
      pageBuilder: (c, s) => platformPage(c, s, const SearchPage()),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (c, s) => platformPage(c, s, const SettingsPage()),
    ),
    GoRoute(
      path: '/connections/:type',
      pageBuilder: (c, s) => platformPage(
        c,
        s,
        ConnectionRequestPage(type: s.pathParameters['type']!),
      ),
    ),
  ],
  errorBuilder: (c, s) => const PageFrame(
    title: 'Page not found',
    children: [
      Notice(
        'This destination is unavailable. Use Back to return to your overview.',
      ),
    ],
  ),
);
