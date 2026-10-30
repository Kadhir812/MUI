# Financial rules and sample data

Reference date: 30 October 2026. Currency: INR. Records are illustrative, not live quotes or real accounts.

## Reconciliation

| Metric | Initial value |
| --- | ---: |
| Everyday account | ₹1,86,500 |
| Savings account | ₹2,10,000 |
| Investments | ₹8,25,200 |
| Total assets | ₹12,21,700 |
| Credit card liability | ₹48,500 |
| Net worth | ₹11,73,200 |
| Invested cost | ₹7,54,000 |
| Investment gain | ₹71,200 |
| October spending | ₹32,549 |
| September spending | ₹28,749 |
| Monthly spending increase | ₹3,800 |
| Dining increase | ₹2,400 |

Portfolio value is the sum of each holding's units × price. FD price is principal. Holding histories sum to the portfolio history. Portfolio plus cash less liabilities produces wealth history. The final history values equal their current summaries.

## Investment method

All sample holdings were acquired on 1 May 2026. There are no subsequent external contributions, withdrawals or trades. Simple return is (current value − invested cost) / invested cost. It is not an annualized return, XIRR or a benchmark-relative return.

The FD is ₹2,00,000 at 7% simple interest for one year, maturing 1 May 2027 at an illustrative gross ₹2,14,000. Interest is excluded from net worth until payout. Tax and penalties are not modelled; the UI states the projection basis.

## Spending

Expense amounts contribute positively; refunds contribute negatively. Income and internal transfers are excluded. August–October records are available. Comparisons are through day 30 for both periods. A category change moves the same record between totals without changing overall expense value.

Charts use the full selected month's spending. Account, activity, category and text filters apply to the transaction list, and that distinction is labelled. Net spending in mixed activity results excludes income/transfers. All seeded records are Completed; the UI states this instead of presenting a meaningless status filter.

Sample account balance snapshots are not presented as a balance computed from the incomplete account activity list.

## Goals

Emergency fund: ₹1,50,000 saved toward ₹3,00,000 by April 2027; current planned contribution ₹18,000/month. Six future contribution months require ₹25,000/month with no interest.

Japan goal: ₹60,000 saved toward ₹1,80,000 by October 2027; ₹10,000/month plan. Contributions reconcile to saved balances. The combined ₹2,10,000 is already included in the savings account.

New goals start with zero saved. Editing cannot change saved balances or transfer funds. Targets must be positive and cannot fall below saved amounts. Monthly amounts are non-negative; deadlines must be after the fixed demo date. Required contribution is remaining / remaining month count, using at least one contribution for a same-month deadline. Assistant proposals round up to the next rupee.

## Credit

782 is an illustrative score on a 300–900 demo range. Utilization = ₹48,500 / ₹2,00,000 = 24.25%. No provider is connected. Labels do not claim a real bureau classification or guarantee score changes.

## Storage and undo

Only local demo preferences, goals and category overrides are persisted. Financial constants are seeded, and derived totals are never saved separately. One last data change can be undone during the session; changing appearance/privacy does not overwrite that undo. Undo preserves current privacy/appearance settings. Write failure restores the previous in-memory snapshot and exposes an error.

This preference-backed snapshot is not suitable for real financial ledger data. The repository boundary is the migration point for a database.
