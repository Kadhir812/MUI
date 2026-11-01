# Android build and device troubleshooting

This documents the Android run issues encountered in this workspace and how they were worked around. The commands below use PowerShell and should be run from the project root (`C:\still_finance`).

## Gradle / Flutter Android build failure

Running the usual command:

```powershell
flutter run -d ZA222Z57SP
```

failed while applying `dev.flutter.flutter-gradle-plugin`. Flutter reported that the project's Kotlin Gradle Plugin version, `2.1.0`, was below the minimum supported version, `2.2.20`. The configured versions are in `android\settings.gradle.kts`:

- Android Gradle Plugin: `8.11.1`
- Kotlin Gradle Plugin: `2.1.0`
- Gradle wrapper: `8.14.0` (`android\gradle\wrapper\gradle-wrapper.properties`)

Flutter also printed warnings that support for Gradle 8.14.0 and AGP 8.11.1 will be dropped in a future Flutter version. Those warnings were not the immediate build failure; the Kotlin version check was.

### Workaround used

Flutter provides a flag to skip the Android build dependency-version validation:

```powershell
flutter run -d ZA222Z57SP --android-skip-build-dependency-validation
```

This successfully built and installed the debug APK on the connected Motorola edge 60. It bypasses Flutter's version check; it does **not** upgrade Kotlin or certify that the current Gradle/AGP/Kotlin combination is supported long-term.

### Recommended permanent fix

Upgrade the Kotlin Gradle Plugin declared in `android\settings.gradle.kts` to a version supported by the installed Flutter SDK (the error required at least `2.2.20`), then run the normal command:

```powershell
flutter run -d <android-device-id>
```

Review Flutter's Android compatibility suggestions before changing Gradle or AGP versions:

```powershell
flutter analyze --suggestions
```

The version bypass is useful for local verification, not a substitute for aligning the project toolchain.

## Finding and using ADB on Windows

The `adb` command was initially not on PowerShell's `PATH`:

```text
adb : The term 'adb' is not recognized...
```

ADB was installed at the standard Android SDK location. Locate and invoke it with an explicit path:

```powershell
$adb = Join-Path $env:LOCALAPPDATA 'Android\Sdk\platform-tools\adb.exe'
Test-Path $adb
& $adb devices
```

To make `adb` available as a command in future PowerShell windows, add the SDK's `platform-tools` directory to the user `PATH`, or continue using `$adb` as shown here.

### Identify the connected device and installed package

```powershell
flutter devices
& $adb devices
& $adb shell pm list packages | Select-String 'still|finance'
```

The device used for verification was `ZA222Z57SP`; the installed application package was `com.kadhir.stillfinance`.

### Open the installed app and capture its screen

```powershell
& $adb shell monkey -p com.kadhir.stillfinance 1
Start-Sleep -Seconds 5
& $adb shell screencap -p /sdcard/income-debug.png
& $adb pull /sdcard/income-debug.png "$env:TEMP\income-debug.png"
```

The pulled PNG can be opened from `%TEMP%`. To inspect screen density and dimensions when taps need to be sent by physical-pixel coordinates:

```powershell
& $adb shell wm size
& $adb shell wm density
```

For example, after confirming the app is in the foreground, a tap can be sent with:

```powershell
& $adb shell input tap <x> <y>
```

The notification shade can obscure the app. A Back key event dismisses it; it may also leave the app, in which case reopen the app with the `monkey` command above:

```powershell
& $adb shell input keyevent 4
```

An attempted `uiautomator dump` returned `ERROR: could not get idle state` and did not produce the requested XML on this device. Screen capture plus `input tap` was used instead to verify navigation.

## Verification result

With the dependency validation bypass, the app was installed and opened on the Android device. Tapping the homepage Income summary opened the Income page. The Dart runtime reported no errors, and these focused tests passed:

```powershell
flutter test test/app_test.dart test/finance_store_test.dart
```
