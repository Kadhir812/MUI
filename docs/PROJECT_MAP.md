# Code and file identification

## Entry and infrastructure

| File | Responsibility | Edit it when… |
| --- | --- | --- |
| `lib/main.dart` | Initializes storage and Riverpod; launches the app | Changing startup dependencies |
| `lib/app.dart` | Owns MaterialApp, router lifetime and appearance | Changing app-level behaviour |
| `lib/core/router.dart` | All destinations, parameters and reduced-motion pages | Adding/changing a screen route |
| `lib/core/theme.dart` | Light/dark palettes, controls and platform transitions | Adjusting colour, typography or shared styling |
| `lib/core/formatters.dart` | INR, date and month presentation | Changing display conventions |
| `lib/data/models.dart` | Entry, Holding, Goal, FinancialData; derived calculations | Changing the financial domain |
| `lib/data/seed.dart` | One coherent illustrative dataset | Changing sample accounts, holdings or records |
| `lib/data/store.dart` | State, persistence boundary, edits, rollback and undo | Adding a data mutation or storage adapter |
| `lib/ui/components.dart` | PageFrame, panels, rows, amounts, notices and controls | Changing reusable presentation |
| `lib/ui/charts.dart` | History charts, accessible exact values, allocation rings | Changing chart behaviour |

## Feature folders — each screen has a named file

| Folder/file under `lib/features/` | Screen or responsibility |
| --- | --- |
| `overview/overview_page.dart` | Menuless home, hero and contextual overview |
| `wealth/wealth_page.dart` | Net worth history and calculation |
| `wealth/balance_sheet_page.dart` | Focused itemized asset or liability list |
| `wealth/account_page.dart` | Account balance and sample activity |
| `investments/investments_page.dart` | Allocation, performance and holdings list |
| `investments/holding_page.dart` | Stock, mutual fund or FD record |
| `spending/spending_page.dart` | Spending analysis, filtered transaction list |
| `spending/transaction_page.dart` | Exact transaction and direct category editing |
| `income/income_page.dart` | Monthly recorded-income summary and income history |
| `income/income_form_page.dart` | Validated add-income form |
| `goals/goals_page.dart` | All savings goals |
| `goals/goal_detail_page.dart` | Goal progress, projection and contributions |
| `goals/goal_editor_page.dart` | Validated create/edit form with review |
| `credit/credit_page.dart` | Credit scale, factors and history |
| `search/search_page.dart` | Direct navigation and record search |
| `assistant/assistant_service.dart` | Deterministic homepage destinations, assistant intents and stale-goal proposal guard |
| `assistant/assistant_page.dart` | Conversation, evidence and reviewed goal proposals |
| `assistant/transaction_proposal_card.dart` | Explicit category proposal and review |
| `settings/settings_page.dart` | Appearance, privacy, undo and reset |
| `settings/connection_request_page.dart` | UI-only mutual-fund, stock/demat and FD detail previews |

## Routes

| Route | Screen |
| --- | --- |
| `/` | Overview |
| `/wealth` | Wealth |
| `/balance-sheet/assets`, `/balance-sheet/liabilities` | Asset or liability detail list |
| `/accounts/everyday`, `/accounts/savings`, `/accounts/credit` | Account |
| `/investments?type=Mutual%20funds` | Optional selected allocation |
| `/holdings/h1` … `/holdings/h5` | Holding |
| `/spending?month=9&category=Groceries` | Filtered spending |
| `/transactions/:id` | Transaction |
| `/income` | Monthly income history |
| `/income/new` | Add income |
| `/goals` | Goals |
| `/goals/:id` | Goal detail |
| `/goals/new/edit`, `/goals/:id/edit` | Create/edit goal |
| `/credit` | Credit health |
| `/search` | Search |
| `/assistant?q=...` | Optional contextual question |
| `/settings` | Preferences |
| `/connections/mutual-funds`, `/connections/stocks`, `/connections/fixed-deposits` | UI-only detail/document previews; no provider connection |

## Native files

- `ios/Runner/Info.plist`: display name and iOS application configuration.
- `ios/Runner/AppDelegate.swift`: standard Flutter iOS host.
- `ios/Runner.xcodeproj`: Xcode project; select your development team for devices.
- `ios/Podfile`: CocoaPods integration.
- `android/app/src/main/AndroidManifest.xml`: Android app label and host configuration.
- `android/app/src/main/kotlin/com/kadhir/stillfinance/MainActivity.kt`: standard Flutter Android host.
- `android/app/build.gradle.kts`: application ID and Android build configuration.
- `web/index.html`: optional browser host.
- `tool/bootstrap.py`: completes missing native generated files using the local SDK.

## Tests and documentation

- `tool/domain_check.dart`: executable dependency-free financial/intent checks.
- `test/finance_store_test.dart`: persistence, undo, rollback and invalid-data tests.
- `test/app_test.dart`: UI navigation, privacy, search and narrow-screen tests.
- `integration_test/app_flow_test.dart`: complete reviewed goal action and undo.
- `docs/DATA_RULES.md`: definitions and financial assumptions.
- `docs/UX_SPEC.md`: visual/interaction contract and intentional limitations.
- `docs/VERIFICATION.md`: passed checks, unrun checks and release checklist.

## Data flow

Widgets observe `FinanceStore` through Riverpod. The store owns one `FinancialData` object. Summaries and charts use derived totals, and assistant explanations read that same object. Mutations go through store methods, which save a versioned snapshot and roll back on failure. Widgets never maintain their own authoritative financial totals.
