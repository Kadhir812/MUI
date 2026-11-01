# UX and implementation contract

## Navigation paradigms

1. Content-as-navigation: amounts/cards/records open the relevant financial context.
2. Hub-and-spoke: overview → detail → record, with visible Back.
3. Progressive disclosure: overview is concise; exact details remain available.
4. Stable vertical feed: section order does not change in response to insights.
5. Search/command navigation: a homepage prompt routes common finance keywords; exact search remains available.
6. Conversational assistance: explanations reference the same underlying records.
7. Agentic interaction: explicit proposal → review → apply → result → undo.
8. Contextual assistance: one home insight and relevant Ask actions.
9. Direct manipulation: chart segment selection has equivalent labelled rows.

No persistent bottom tabs, hamburger, sidebar, shortcut grid, hidden-only gesture or radial menu. Nested donuts are a visual option, not a substitute for understandable navigation.

## Visual hierarchy

Home is a compact, tappable financial snapshot: net worth and its trend, a clear “assets − liabilities = net worth” explanation with tappable asset/liability totals, this-month income and spending, and an explicit budget status appear first. Asset and liability totals open focused itemized lists. One- or two-line, data-backed captions connect wealth and cash-flow totals; financial values are hidden with privacy mode. The current demo has no saved monthly budget, so the summary says there is no monthly limit to compare against rather than inventing a budget status. Investments, savings goals, and credit health are concise rows that open their complete detail pages. One short spending insight, recent activity, and the money assistant follow; long numbered story sections stay off the home screen.

Income and spending figures are separate tap targets. Income opens a monthly income history with a clearly labelled Add income action; spending opens spending analysis with an Add expense action in page content. Manually entered income updates recorded income and cash-flow summaries only. Because account snapshots are fixed illustrative data rather than a reconciled ledger, the UI explicitly says that added records do not change balances or net worth.

Deeper pages give one analytical question prominence. Allocation/performance and category/weekly-trend controls avoid simultaneous competing charts. Home summaries navigate to full analyses and records, preserving progressive disclosure without a drawer or persistent navigation menu.

Spending category analysis includes a compact spider chart for comparing the relative shape of category spend. The chart is paired with labelled, tappable category rows, so exact values and filtering do not depend on reading the visualization. The year overview includes all twelve months, a yearly trend, and a compact monthly summary inside the same analysis panel; months without activity remain visible as zero.

The home header uses a settings gear rather than a filter-style control. Income and expense creation stays in each page's content, not the header. Settings includes UI-only connection previews for mutual funds, stocks/demat, and fixed deposits. They show typical identifiers and documents to prepare, but do not connect to providers, upload documents, or transmit/store entered values; the preview explicitly tells users not to enter real financial identifiers.

The homepage “Ask Still” composer is the single conversational entry point and sits at the bottom of the feed. Direct commands such as “open income” or “show my investments” use local keyword routing to open matching destinations. Data and explanation questions such as “what is my income?” or “explain my assets” open the existing “A little clarity” page with the question ready. The header Search control remains available for exact holdings, goals, transactions, and date/category search. Routing is deterministic demo logic behind `DemoAssistantService`, so it can later be replaced by an AI-backed intent service without changing the homepage interaction; no AI request is currently made.

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
- Homepage command routing and assistant intent matching are deterministic and bounded. They are not an LLM or autonomous financial service.
- Transaction category proposals require the user to choose a category; the app does not guess silently.
- Goal contribution history is viewable. This phase edits contribution plans, not actual deposits or saved balances.
- Sample account activity is clearly labelled incomplete relative to account balance snapshots.
- One data undo is available in the current session, including after navigation; restart does not retain undo history.
- Platform host templates are included. Bootstrap completes SDK-generated files on the user's machine.
- Runtime layout, smoothness, accessibility and platform builds are not claimed as validated here.
