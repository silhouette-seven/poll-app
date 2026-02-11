# Poll App

## Setup Instructions

1.  **Dependencies**:
    Run `flutter pub get` to install dependencies.

2.  **Firebase Configuration**:
    This app uses Firebase. You must configure it for your project:
    ```bash
    flutterfire configure
    ```
    This will generate `lib/firebase_options.dart`.

3.  **Run the App**:
    ```bash
    flutter run
    ```

## Troubleshooting
- **Build Errors**: Ensure you have the latest Flutter SDK and compatible dependencies.
- **NDK Issues**: If on Windows/Android, ensure your `android/app/build.gradle.kts` specifies a valid `ndkVersion` (e.g., `27.0.12077973` or whatever is installed).
- **Riverpod Error**: If you see `scheduleNewFrame` error, run `flutter pub upgrade` or ensure `flutter_riverpod` is version `^2.6.1`.

## Features
- Create Polls
- View Polls
- Vote (one vote per poll per device)
- Offline support via Hive
