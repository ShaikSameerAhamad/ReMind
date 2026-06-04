# reMind Native Android Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build reMind as a production-grade native Android app for Play Store release, using the product/security/frontend requirements as the source of truth and translating the original Flutter-oriented architecture into Kotlin/Compose architecture per the latest execution brief.

**Architecture:** The app uses feature-first Clean Architecture with Compose presentation, ViewModels, domain use cases, repository contracts, data implementations, Room local persistence, Firebase remote services, WorkManager sync, and Hilt dependency injection. Every feature follows offline-first behavior: read local first, write local first, enqueue sync, then reconcile with Firestore.

**Tech Stack:** Kotlin, Jetpack Compose, Material 3, Navigation Compose, Hilt, Coroutines, Flow, StateFlow, Retrofit, OkHttp, Room, DataStore, WorkManager, Coil, Kotlin Serialization, Firebase Auth/Firestore/Functions/FCM/Storage, RevenueCat, Android Keystore-backed encrypted storage.

---

## 1. Source Document Analysis

The repository documents define a product called reMind with the tagline "Save smarter. Sync better". The core product is an Android-first read-it-later and coordination app for saved content, smart queues, offline reading, reminders, collaborative tasks, shared alarms, groups, streaks, and activity.

### Business Requirements

- Help users save links instantly and return to them at useful times.
- Support personal reading workflows and shared family/team coordination.
- Provide a genuinely useful free tier.
- Keep the first working surface as the home hub, not a marketing page.
- Support Google Play release, long-term maintainability, and secure production operation.

### User Flows

- Signup or guest mode -> save first article -> view in queue.
- Create family group -> invite members -> assign first task.
- Set shared alarm -> deliver to member device -> dismiss and track dismissal.
- Read item -> complete item -> update streak -> earn/view badges and insights.

### Feature Requirements

- Authentication: Google Sign-In, guest mode, logout, migration prompt.
- Save: URL paste, Android share intent, clipboard detection, metadata enrichment.
- Queues: Tonight, Weekend, Forgotten, Continue Reading, Watch Later, Learning, Recently Saved.
- Reader: extracted content, fallback browser, progress, customization, highlights.
- Reminders: Tonight, Tomorrow AM, Weekend, Custom, recurring.
- Groups: create, invite, member roles, settings, access removal.
- Tasks: create, assign, complete, comments, real-time sync, conflict messaging.
- Alarms: create, send, receive full-screen UI, dismiss, delivery logs.
- Activity: group activity feed and home tile.
- Widgets: queue, quick save, streak, pending tasks.
- Security: Firestore rules, Storage rules, secure token handling, account deletion.

### UI Requirements

- Native Material 3 Compose.
- Onest typography.
- Palette: Ink `#10171c`, Sky `#97cff3`, Mint `#a7e8d1`, Cloud `#f7f7f7`.
- Responsive bento home grid: 2 columns phone, 3 columns tablet, 3-4 landscape.
- Dark theme, dynamic color, accessibility, skeletons, empty/error/offline/loading states.
- Critical alarms use full-screen high-contrast UI.

### Security Requirements

- Firebase Auth with Google Sign-In.
- Guest mode is local-only for personal flows.
- Android Keystore-backed encryption for sensitive local state.
- No hardcoded credentials, API keys, secrets, FCM server keys, or admin credentials.
- Firestore access: personal items scoped to owner; groups scoped to current members; admin-only member management; dismissal writes limited to own field.
- Secure logging: never log tokens, article content, private notes, or notification payloads.

### Architecture Constraints

The existing architecture/tickets mention Flutter, Riverpod, Hive, and GoRouter, but the latest execution brief explicitly mandates native Android with Kotlin, Compose, Hilt, Room, Retrofit, OkHttp, DataStore, and WorkManager. This plan treats product, business, security, data schema, UI, and ticket order as canonical, while translating implementation technology to native Android.

## 2. Native Module Breakdown

```text
app/
  src/main/java/com/remind/app/
    ReMindApplication.kt
    MainActivity.kt

    core/
      analytics/
      common/
      connectivity/
      datastore/
      database/
      designsystem/
      di/
      logging/
      navigation/
      network/
      notifications/
      security/
      sync/
      validation/

    feature/
      auth/
      home/
      save/
      queue/
      reader/
      reminders/
      groups/
      tasks/
      alarms/
      gamification/
      settings/
      widgets/

    domain/
      model/
      repository/
      usecase/
```

## 3. Database Strategy

- Room is the local source of truth.
- Tables are partitioned by `ownerId` or `groupId`.
- Syncable entities include `syncStatus`, `updatedAt`, and `updatedBy`.
- Sync operations are stored in a durable `sync_operations` table with idempotency keys.
- Room migrations are required for every schema change after version 1.
- Firebase Firestore remains the remote collaboration source.

## 4. Networking Strategy

- Retrofit/OkHttp handles third-party HTTP APIs such as metadata extraction proxy, RevenueCat server API, and optional Cloud Function HTTP endpoints.
- Firebase SDKs handle Auth, Firestore, FCM, Functions, and Storage.
- OkHttp includes timeout, retry, auth, redaction, and connectivity interceptors.
- Mobile client never stores server secrets or OpenAI keys.

## 5. Authentication Strategy

- Google Sign-In via Credential Manager/Firebase Auth.
- Guest mode creates a stable local guest identity stored securely.
- Signed-in users get Firestore profile upsert and FCM token registration.
- Logout stops listeners, unregisters FCM token, clears auth session state, and protects local data.

## 6. Security Strategy

- Android Keystore creates/holds encryption material.
- EncryptedSharedPreferences or equivalent stores sensitive local keys where needed.
- DataStore stores non-sensitive preferences.
- Room stores app data and avoids raw auth tokens.
- Logs are redacted through a safe logger facade.
- Firestore and Storage security rules are implemented and emulator-tested.

## 7. Navigation Strategy

- Navigation Compose owns top-level route graph.
- Routes are typed constants with argument validation.
- Notification deep links route into queue, task detail, group detail, alarm received, or invite join.
- Auth state gates protected destinations.

## 8. State Management Strategy

- ViewModels expose immutable `StateFlow<UiState>`.
- UI sends events to ViewModels.
- Use cases handle business logic and validation.
- Repositories expose `Flow` from Room and sync with remote data sources.
- Compose screens are stateless where practical.

## 9. Dependency Injection Plan

- Hilt modules are split by concern: database, network, Firebase, repositories, use cases, dispatchers, security, notifications.
- Constructor injection is preferred.
- Interfaces live in domain, implementations live in data/core.
- Tests use fake implementations only in test source sets, never in production flows.

## 10. Testing Strategy

- Unit tests first for domain models, validators, queue engine, sync policy, conflict resolver, and permission helpers.
- Room DAO tests for database behavior.
- Repository tests with controlled local/remote test doubles.
- Compose UI tests for critical journeys.
- Firebase Emulator tests for Firestore and Storage rules.
- Instrumentation tests for navigation, auth gating, share intent, alarm screen, and offline state.

## 11. CI/CD Strategy

- Use Gradle tasks for formatting/lint, unit tests, instrumentation tests, static analysis, and release builds.
- Build variants: dev, staging, production.
- Secrets are read from local properties, CI environment variables, or Firebase config files excluded from git.
- Release signing config references external keystore properties only.
- R8/proguard enabled for release.
- Crash reporting and analytics integration points are wired but secrets/config remain environment-provided.

## 12. Phase 1 Execution Plan

### Task 1: Native Android Foundation

**Files:**
- Create: `settings.gradle.kts`
- Create: `build.gradle.kts`
- Create: `gradle.properties`
- Create: `app/build.gradle.kts`
- Create: `app/src/main/AndroidManifest.xml`
- Create: `app/src/main/java/com/remind/app/ReMindApplication.kt`
- Create: `app/src/main/java/com/remind/app/MainActivity.kt`
- Create: `app/src/main/java/com/remind/app/core/designsystem/*`
- Create: `app/src/main/java/com/remind/app/core/navigation/*`
- Test: `app/src/test/java/com/remind/app/core/designsystem/ReMindColorTest.kt`

- [ ] Write failing unit tests for brand color tokens and route constants.
- [ ] Run tests and verify they fail because production code does not exist.
- [ ] Create Gradle Android app structure with Kotlin/Compose/Hilt/Room/Firebase dependencies.
- [ ] Implement design tokens, typography names, theme, application class, main activity, and route constants.
- [ ] Run tests and verify they pass.

### Task 2: Domain Model Foundation

**Files:**
- Create: `app/src/main/java/com/remind/app/domain/model/*.kt`
- Create: `app/src/test/java/com/remind/app/domain/model/*.kt`

- [ ] Write failing tests for saved item validation, group role permissions, task completion, alarm dismissal, and sync status behavior.
- [ ] Implement immutable domain models and enums.
- [ ] Run tests and verify domain behavior.

### Task 3: Validation and Security Utilities

**Files:**
- Create: `app/src/main/java/com/remind/app/core/validation/*.kt`
- Create: `app/src/main/java/com/remind/app/core/security/*.kt`
- Test: `app/src/test/java/com/remind/app/core/validation/*.kt`

- [ ] Write failing tests for URL validation, task title validation, group name validation, alarm recipient validation, and log redaction.
- [ ] Implement validators and safe logger redaction.
- [ ] Run tests and verify behavior.

### Task 4: Room Schema Foundation

**Files:**
- Create: `app/src/main/java/com/remind/app/core/database/ReMindDatabase.kt`
- Create: `app/src/main/java/com/remind/app/core/database/entity/*.kt`
- Create: `app/src/main/java/com/remind/app/core/database/dao/*.kt`
- Test: `app/src/androidTest/java/com/remind/app/core/database/*.kt`

- [ ] Write DAO tests for inserting saved items and sync operations.
- [ ] Implement Room entities, DAOs, database, and migration placeholder-free version 1 schema.
- [ ] Run database tests where Android instrumentation is available.

### Task 5: App Shell UI

**Files:**
- Create: `app/src/main/java/com/remind/app/feature/home/HomeRoute.kt`
- Create: `app/src/main/java/com/remind/app/feature/auth/AuthRoute.kt`
- Create: `app/src/main/java/com/remind/app/feature/save/SaveRoute.kt`
- Create: `app/src/main/java/com/remind/app/feature/queue/QueueRoute.kt`
- Create: `app/src/main/java/com/remind/app/feature/alarms/AlarmReceivedRoute.kt`

- [ ] Write Compose UI tests for top-level route rendering and accessibility labels.
- [ ] Implement polished empty-state screens using real reMind copy, not lorem ipsum or fake data.
- [ ] Wire Navigation Compose and theme.
- [ ] Run UI tests where Android instrumentation is available.

## 13. Verification Checklist

- The app uses native Android, not Flutter.
- No dummy production services or fake production data are introduced.
- Empty states are real product states, not sample content.
- Secrets and Firebase config files are not committed.
- Domain behavior has unit tests before production implementation.
- Build configuration is compatible with Play Store release hardening.
