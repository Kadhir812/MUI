# Verification status

## Completed in the authoring environment

- `flutter test` passes, including income persistence, separate home income/spending navigation, privacy, expense, and category drill-down checks.
- Targeted `flutter analyze` for the income and home implementation passes without issues.
- Full-project analysis runs and reports three existing info-level notices: one asynchronous BuildContext notice in the assistant proposal card and two `print` notices in the domain-check script.
- The app launched in Chrome during development; this is not a native-device acceptance test.

## Not completed

- `integration_test` execution.
- Android APK build or emulator/device run.
- iOS simulator/device build, signing or run.
- Screenshots, golden comparisons, screen-reader QA, frame timing and large-text visual QA.

Passing widget tests is not a substitute for native builds or accessibility/device acceptance.

## Local verification sequence

1. `python3 tool/bootstrap.py` (Windows: `python`).
2. `flutter analyze` — fix all errors/warnings before acceptance.
3. `flutter test` — run included repository/widget tests.
4. `flutter test integration_test/app_flow_test.dart -d <device-id>`.
5. `flutter run -d <ios-simulator-id>` on macOS.
6. `flutter run -d <android-device-id>`.
7. Commit the generated dependency lockfile after successful resolution.

## Required device acceptance checks

- iPhone small and standard widths; Android small and standard widths.
- Large accessibility text, landscape, keyboard open and sheet scrolling.
- VoiceOver and TalkBack navigation, reading order, chart alternatives and labels.
- Light/dark contrast, especially thin chart marks.
- Native back gesture/system Back and restored filters/scroll.
- Goal proposal cannot apply without review; stale proposal cannot overwrite a changed goal.
- Category edit updates totals and undo restores them.
- Relaunch retains preferences, goal edits, categories, and manually added income/expense records.
- Privacy conceals values across all screens and charts.
- Manually added income updates income and cash-flow summaries without implying that illustrative balances or net worth have been reconciled.
- Reduced-motion behaviour of page transitions and platform sheets.
- No overflow, clipped monetary values, blocked taps or dropped frames in common journeys.

## Release boundary

This is a local demonstration. Do not label it production banking software, connect real accounts, or use preference storage for real financial records. Add production identity, secure storage, auditability, real data valuation and appropriately validated agent permissions before such expansion.
