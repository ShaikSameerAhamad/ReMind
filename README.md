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

Firebase Functions live in `functions/` and target Node 20 on Firebase:

```powershell
cd functions
npm install
npm test
npm run build
firebase deploy --only functions
```

Firestore rules and indexes are deployed from the repo root:

```powershell
firebase emulators:exec --only firestore "npm.cmd --prefix functions run test:rules"
firebase deploy --only firestore --project remind-e293e
```

The scheduled shared-alarm processor expects these optional environment values:

- `FUNCTIONS_REGION`, defaults to `asia-south1`
- `ALARM_PROCESS_BATCH_SIZE`, defaults to `100`
- `ALARM_NOTIFICATION_CHANNEL_ID`, defaults to `remind_general`

Release signing is read from `android/key.properties`, which must stay local and must not be committed.
