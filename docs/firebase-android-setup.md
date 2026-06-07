# Firebase Android Setup

This repo is wired for Firebase, but it intentionally does not commit real Firebase config files.

## Required Firebase Console Setup

1. Create Firebase projects for development, staging, and production.
2. Add an Android app with package name `com.remind.app`.
3. Enable Firebase Authentication with Google as a provider.
4. Enable Firestore in production mode and apply security rules before public testing.
5. Enable Cloud Messaging for push notifications.
6. Download `google-services.json` from Firebase Console.
7. Place it at `android/app/google-services.json`.
8. Run `flutter build apk --debug` to verify Android resources are generated.

## Repository Behavior

- `android/app/google-services.json` is ignored by Git.
- The Google Services Gradle plugin is applied only when `android/app/google-services.json` exists.
- Local builds continue to work without Firebase config; the app falls back to guest-only local mode.
- Once the file exists, Firebase Auth, Firestore, and FCM use the real project configuration.

## Never Commit

- `google-services.json`
- `GoogleService-Info.plist`
- service account JSON files
- FCM server keys
- signing keystores
