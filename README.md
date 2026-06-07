# reMind

Save smarter. Sync better.

reMind is an Android-first Flutter application for saving links, resurfacing them through smart queues, reading offline, and coordinating shared tasks and alarms with family or teams.

## Development

The documents in `docs/` are the source of truth for product, architecture, security, frontend, and ticket scope.

Required local tools:

- Flutter stable
- Android Studio and Android SDK
- Firebase CLI
- FlutterFire CLI

Useful commands:

```powershell
flutter pub get
flutter test
flutter run
flutter build appbundle --release
```

Release signing is read from `android/key.properties`, which must stay local and must not be committed.
