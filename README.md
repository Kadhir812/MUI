# Still — your money, clearly

An iOS-first Flutter financial-management demo with menuless navigation, complete record drill-downs, restrained charts, and a local assistant that proposes reviewable changes.

**Start here:** [Project map](docs/PROJECT_MAP.md) · [UX specification](docs/UX_SPEC.md) · [Data rules](docs/DATA_RULES.md) · [Verification status](docs/VERIFICATION.md)

## What is implemented

- Overview, wealth and account detail.
- Investment allocation, optional nested holdings ring, performance, stocks/MF/FD detail.
- Spending categories, weekly trend, search, month/account/activity filters, transaction detail and category editing.
- Goal list, creation, detail, contribution history, editing, reviewed proposals and undo.
- Credit scale, illustrative factors and exact score history.
- Search for sections, holdings, goals and transactions; “last month groceries” intent.
- Local assistant explanations grounded in the shared dataset, goal planning, and contextual transaction categorization.
- Dark appearance, financial-value privacy, local persistence, one-level undo, and demo reset.
- Platform-aware page navigation, visible Back controls, labelled chart alternatives, and reduced-motion page routing.

No sign-in, API keys, banking integration, real AI service, trading, transfer or payment is implemented. All data is illustrative and dated **30 October 2026**. The assistant is deliberately labelled as a simulation.

## Verification status — read before running

The Dart domain checks passed and all Dart source files were parsed/formatted successfully. Native scaffold XML/plists/JSON and local imports were checked.

**Flutter dependency resolution, full static analysis, compilation, widget/integration tests, and device visual QA were not completed in the authoring environment.** Flutter setup was stopped by an automatic security review after it attempted to contact the cloud instance metadata endpoint. It was not retried or bypassed.

This is implemented source, not a certified or device-verified build. See `docs/VERIFICATION.md` for exact checks and remaining work. The archive does not include an APK or IPA.

## Requirements

- Flutter 3.35.7 / Dart 3.9 or a compatible newer stable SDK. The source and native templates target 3.35.7; dependency constraints are in `pubspec.yaml` and have not been resolved here.
- Python 3 for the one-time bootstrap helper.
- Android: Android Studio/Android SDK, a device or emulator, and the JDK required by your Flutter toolchain.
- iOS: a Mac with Xcode, iOS simulator/device and CocoaPods. Physical devices require your development team/signing configuration.

## First run

Extract the archive and open the **still_finance** directory in VS Code or Android Studio.

```sh
python3 tool/bootstrap.py
flutter analyze
flutter test
flutter devices
flutter run -d <device-id>
```

On Windows, use `python tool/bootstrap.py`. Run iOS on macOS; Windows can run the Android version.

The bootstrap helper asks your installed Flutter SDK to create a temporary native project, copies only missing platform files (such as the Gradle wrapper), then runs `flutter pub get`. It does **not** replace your Dart files, seed data, pubspec, or existing native files. Generated SDK-specific files and downloaded dependencies are deliberately not bundled. Dependency resolution will create `pubspec.lock`; commit it after successful verification.

If Python is unavailable, generate the missing SDK files directly from the project root:

```sh
flutter create --platforms=ios,android,web --org=com.kadhir --project-name=still_finance --no-pub .
flutter pub get
```

Back up customized native files before using `flutter create` on an existing modified project. The Python helper is the safer default because it copies only missing native files.

### iOS

```sh
open -a Simulator
flutter devices
flutter run -d <ios-simulator-id>
```

For a device, open `ios/Runner.xcworkspace` after dependencies are installed and select your signing team. The demo bundle ID is `com.kadhir.stillfinance`; replace it before distribution. Do not distribute the sample under debug signing.

### Android

Start an emulator from Android Studio, or attach a device with debugging enabled:

```sh
flutter devices
flutter run -d <android-device-id>
```

### Optional browser convenience

```sh
flutter run -d chrome
```

The web target is for convenient review. iOS and Android remain the intended products. No web deployment is included.

## Tests

```sh
dart tool/domain_check.dart
flutter test
flutter test integration_test/app_flow_test.dart -d <device-id>
```

`tool/domain_check.dart` has no external dependencies and tests financial reconciliation and intent/proposal rules. Flutter tests cover persistence, rollback, privacy, navigation, search and the reviewed goal flow. Those Flutter tests are included but not executed here.

## A useful walkthrough

1. Open **Explore your wealth** and inspect assets and liabilities.
2. Back → Investments → select Mutual funds → open a fund.
3. Switch Allocation / Performance; toggle the optional holdings ring.
4. Spending → select Dining → inspect a transaction → change category → Undo.
5. Search “last month groceries” and inspect the visible September/category filters.
6. Goals → Emergency fund → Review a suggested plan → Review proposed change → Apply → Undo.
7. A transaction’s **Ask about this** opens a reviewed category change.
8. Settings → dark appearance or hide financial values; restart to verify persistence.

## Storage and extension boundary

For this small offline demonstration, editable categories, goals and preferences are stored as one versioned JSON snapshot using `SharedPreferencesAsync`. Undo is in memory for the current session. This is a deliberate reduction from the initially proposed database layer: it does not pretend to be durable storage for real financial records.

`SnapshotRepository` isolates persistence. Replace it with a transactional database repository before handling real records; no widget should call a database directly. Replace `DemoAssistantService` with a real service only after adding appropriate identity, permissions, validation, and audit controls. Preserve the review-before-apply UI.

Native project templates are adapted from Flutter under the license in `docs/FLUTTER_TEMPLATE_LICENSE.txt`. Platform icons are a simple original bar mark generated for this app. No external images or fonts are required.
