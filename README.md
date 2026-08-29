# Gully Cricket

Gully Cricket is a Flutter app for creating and scoring local cricket matches. It supports custom match rules, two-innings scoring, match history, calendar lookup, and score summaries.

## Features

- Create matches with team names and over limits.
- Choose the batting team before starting play.
- Score runs, wickets, wides, and no-balls.
- Configure whether wides and no-balls add one run to the total.
- Resume active matches from the home screen.
- View today's matches with creation time stamps.
- Review completed match summaries by innings.

## Requirements

- Flutter SDK with Dart `^3.13.1` support.
- Android Studio, Xcode, Visual Studio, or another Flutter-supported target toolchain for the platform you run on.
- Project packages listed in `pubspec.yaml`.

## Setup

```bash
flutter clean
flutter pub get
flutter test
flutter run
```

For a new developer or a fresh machine setup, follow [RUN_STEPS.md](RUN_STEPS.md).

## Dependencies

Runtime packages:

- `path`
- `sqflite`

Development packages:

- `flutter_test`
- `flutter_lints`

This is a Flutter/Dart project, so dependencies are installed from `pubspec.yaml` using `flutter pub get`. The `requirement.txt` file is included as a quick human-readable dependency note for this project.
