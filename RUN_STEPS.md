# Run Steps

Use these steps when setting up or running Gully Cricket on a new machine.

## 1. Install Required Tools

- Install Flutter SDK.
- Install Android Studio.
- Install the Android SDK and an Android emulator, or connect a physical Android phone.
- Run this command to check your setup:

```bash
flutter doctor
```

Fix any Android Studio, Android SDK, or device issues shown by `flutter doctor`.

## 2. Open the Project

Open this folder in VS Code or Android Studio:

```text
cricket_app
```

## 3. Clean and Download Packages

Run these commands from the project root:

```bash
flutter clean
flutter pub get
```

## 4. Start a Device

Use one of these options:

- Start an Android emulator from Android Studio.
- Connect an Android phone with USB debugging enabled.

Confirm Flutter can see the device:

```bash
flutter devices
```

## 5. Run the App

```bash
flutter run
```

## 6. Build a Small APK

For a smaller release APK used for phone testing:

```bash
flutter build apk --release --split-per-abi
```

For most modern Android phones, use the ARM64 APK:

```text
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

You can create a friendly renamed copy with:

```powershell
Copy-Item -Path "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk" -Destination "build\app\outputs\flutter-apk\gully-cricket-release.apk" -Force
```

Use this file for sharing or installing:

```text
build/app/outputs/flutter-apk/gully-cricket-release.apk
```

## Common Commands

```bash
flutter clean
flutter pub get
flutter test
flutter run
flutter build apk --release --split-per-abi
```
