# UX and implementation contract

## Navigation paradigms

1. Content-as-navigation: amounts/cards/records open the relevant financial context.
2. Hub-and-spoke: overview → detail → record, with visible Back.
3. Progressive disclosure: overview is concise; exact details remain available.
4. Stable vertical feed: section order does not change in response to insights.
5. Search/command navigation: sections, entities and supported date/category intent.
6. Conversational assistance: explanations reference the same underlying records.
7. Agentic interaction: explicit proposal → review → apply → result → undo.
8. Contextual assistance: one home insight and relevant Ask actions.
9. Direct manipulation: chart segment selection has equivalent labelled rows.

No persistent bottom tabs, hamburger, sidebar, shortcut grid, hidden-only gesture or radial menu. Nested donuts are a visual option, not a substitute for understandable navigation.

## Visual hierarchy

Home shows one dominant wealth chart. Spending is a figure and comparison; investments add a restrained allocation strip; the priority goal has a progress bar; credit is a compact row. Deeper pages give one analytical question prominence. Allocation/performance and category/weekly-trend controls avoid simultaneous competing charts.

Full pages are used for analysis and records. Sheets handle short selections and proposal review. All important actions have a text label or accessible tooltip.

## Palette

| Role | Light palette |
| --- | --- |
| Background | #F7F8FA |
| Surface | #FFFFFF |
| Text | #172B3A |
| Supporting text | #596775 |
| Action / wealth trend | #006B63 |
| Stocks | #365E9D |
| Mutual funds | #7864A8 |
| Fixed deposits | #A66B24 |

Dark background is #101B22, surface #17252D, text #EBF0F2, supporting text #B6C4CD and accent #8BD6CA. Category names and exact amounts always accompany colour. Dark chart-category contrast and colour-vision accessibility need device review before acceptance.

No external fonts or image dependencies. The platform system typeface, tabular financial numerals, consistent INR formatting and right-aligned record values establish hierarchy. Cards use restrained 22px corners and page padding is 22 logical pixels. Content is centred at a maximum width of 680 for larger windows.

## Motion

Native platform page transitions; Cupertino page transitions on iOS. Reduced-motion routes use NoTransitionPage. Sheets and buttons retain standard Flutter feedback. There are no delayed entrances, rolling balances, animated loading theatre, bouncing charts or donut spins. History chart changes are immediate to avoid misrepresenting interpolated financial data. Appearance changes are immediate.

## Privacy and accessibility

- Financial privacy conceals amount components, relevant comparisons, charts, score values and generated assistant amounts.
- Numeric form fields are obscured while privacy is active. Assistant financial proposals require visible values before review.
- Exact chart values have labelled rows; small donut segments are never required targets.
- System text scaling is not disabled. Narrow/large-text overflow remains part of required device QA.
- No user action depends on long press, pinch or swipe.
- Back and search controls have tooltips. Icons supplement labels, not replace financial meaning.
- Conversation is local and transient. User-entered free text is not automatically redacted; it may contain anything the user typed. Do not treat privacy mode as a secure-session lock.

## Intentional implementation choices / limits

- A versioned preference snapshot is used for this small mock demo instead of Drift/SQLite. Production ledger persistence is explicitly out of scope.
- Credit history uses exact-value rows, not another decorative chart.
- Search has an explicit supported grocery/month intent, not a general natural-language query engine.
- Assistant intent matching is deterministic and bounded. It is not an LLM or autonomous financial service.
- Transaction category proposals require the user to choose a category; the app does not guess silently.
- Goal contribution history is viewable. This phase edits contribution plans, not actual deposits or saved balances.
- Sample account activity is clearly labelled incomplete relative to account balance snapshots.
- One data undo is available in the current session, including after navigation; restart does not retain undo history.
- Platform host templates are included. Bootstrap completes SDK-generated files on the user's machine.
- Runtime layout, smoothness, accessibility and platform builds are not claimed as validated here.
