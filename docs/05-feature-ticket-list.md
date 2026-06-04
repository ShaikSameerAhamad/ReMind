# reMind Feature Ticket List

Version: 1.0  
Purpose: build-order ticket backlog for MVP development  
Format: each ticket is self-contained and usable as an implementation prompt

## Build Order Summary

1. Foundation, project setup, environments, and CI.
2. Core data models, local storage, sync queue, and Firebase wiring.
3. Authentication and user profile.
4. Save system, metadata enrichment, and smart queues.
5. Home, reader, reminders, and streak basics.
6. Group creation, tasks, shared alarms, and activity.
7. Widgets, gamification polish, and launch readiness.

## Tickets

### FEAT-001: Flutter Project and Firebase Infrastructure

Priority: MUST-HAVE  
Effort: Large, 1-2 weeks  
Feature files: `core/config/`, `core/firebase/`, `core/routing/`, `core/theme/`, `main.dart`, `app.dart`

Description: Scaffold the Flutter app, configure Firebase projects for dev/staging/prod, set up app flavors, and create the baseline app shell.

Acceptance criteria:

- Flutter app runs on Android emulator and physical Android device.
- Dev, staging, and prod flavor configuration exists.
- Firebase Auth, Firestore, Functions, FCM, and Storage are initialized per flavor.
- App uses GoRouter with placeholder routes for auth, home, queue, reader, groups, tasks, and alarms.
- CI runs formatting, static analysis, and tests.

Dependencies: None.

UI screens: Splash placeholder, empty home placeholder.

Backend logic: Firebase project setup, Functions project initialized.

Database changes: None yet.

Integrations: Firebase core, GoRouter, Riverpod.

### FEAT-002: Brand Theme and Design Tokens

Priority: MUST-HAVE  
Effort: Medium, 4-7 days  
Feature files: `core/theme/`, `core/constants/`, asset folders

Description: Implement the reMind brand system with Onest typography, palette, Material 3 theme, dark mode, and placeholder logo/icon assets.

Acceptance criteria:

- App uses Onest for all text.
- Theme tokens include Ink `#10171c`, Sky `#97cff3`, Mint `#a7e8d1`, Cloud `#f7f7f7`.
- Light and dark themes are implemented.
- Material You dynamic color support is available but brand colors remain stable for primary actions.
- Placeholder lowercase `r` recall-loop icon appears in splash and app shell.

Dependencies: FEAT-001.

UI screens: Splash, theme preview route if helpful.

Backend logic: None.

Database changes: None.

Integrations: Google Fonts or bundled Onest font assets.

### FEAT-003: Core Models and Serialization

Priority: MUST-HAVE  
Effort: Medium, 4-7 days  
Feature files: `models/`, `features/*/domain/`, `features/*/data/dto/`

Description: Define domain models and DTOs for users, saved items, reminders, groups, tasks, alarms, streaks, badges, and sync operations.

Acceptance criteria:

- Models are immutable and serializable.
- Firestore DTOs map cleanly to domain entities.
- Required enums exist for item category, task priority, alarm status, user role, sync status, and plan.
- Unit tests cover serialization/deserialization edge cases.

Dependencies: FEAT-001.

UI screens: None.

Backend logic: None.

Database changes: Schema conventions documented in code comments or tests.

Integrations: Freezed/json_serializable if selected.

### FEAT-004: Hive Local Storage Foundation

Priority: MUST-HAVE  
Effort: Large, 1-2 weeks  
Feature files: `core/storage/`, `core/sync/`, feature local data sources

Description: Configure Hive boxes for offline-first storage and create local data source interfaces for saved items, groups, tasks, alarms, and sync queue.

Acceptance criteria:

- Hive initializes before the app opens the home screen.
- Local boxes are partitioned by UID or guest ID.
- Saved items, groups, tasks, alarms, and sync operations can be written and read locally.
- Local writes mark records with sync state.
- Unit tests verify local CRUD behavior.

Dependencies: FEAT-003.

UI screens: None.

Backend logic: None.

Database changes: Local schema only.

Integrations: Hive, path_provider, secure storage for encryption keys if used.

### FEAT-005: Offline Sync Engine

Priority: MUST-HAVE  
Effort: Large, 1-2 weeks  
Feature files: `core/sync/`, `core/platform/workmanager_service.dart`

Description: Build a sync queue that writes locally first, retries cloud writes, handles reconnect, and resolves MVP conflicts with last-write-wins timestamps.

Acceptance criteria:

- All write operations can be enqueued with idempotency keys.
- Sync queue drains on reconnect and app startup.
- Failed writes remain visible with retry state.
- Last-write-wins conflict helper compares `updatedAt`.
- WorkManager background retry is configured.
- Tests cover success, failure, retry, and conflict cases.

Dependencies: FEAT-004.

UI screens: Sync indicator components, offline banner.

Backend logic: Firestore write adapters.

Database changes: Use `updatedAt`, `updatedBy`, `syncStatus` fields.

Integrations: Firestore, WorkManager, connectivity_plus.

### FEAT-006: Authentication, Guest Mode, and Logout

Priority: MUST-HAVE  
Effort: Large, 1-2 weeks  
Feature files: `features/auth/`, `core/storage/secure_token_store.dart`

Description: Implement Google Sign-In, guest mode, auth state management, profile creation, guest migration prompt, and logout cleanup.

Acceptance criteria:

- User can sign in with Google.
- User can continue as guest and save locally.
- Signed-in profile document is created or updated in Firestore.
- Guest data migration path is prompted after sign-in.
- Logout stops listeners, clears session state, and returns to auth screen.
- Auth state is exposed through Riverpod.

Dependencies: FEAT-001, FEAT-004.

UI screens: Onboarding, sign-in screen, guest migration dialog.

Backend logic: User profile upsert.

Database changes: `users/{uid}` profile and preferences.

Integrations: Firebase Auth, Google Sign-In, Firestore.

### FEAT-007: Notification Channels and FCM Token Registration

Priority: MUST-HAVE  
Effort: Medium, 4-7 days  
Feature files: `core/notifications/`, `core/routing/deep_link_parser.dart`

Description: Configure Android notification channels, request notification permission where required, register FCM tokens, and route notification taps to app screens.

Acceptance criteria:

- Notification channels exist for reminders, shared alarms, tasks, invites, and digests.
- FCM token is saved under current user and removed on logout.
- Notification data payload can deep link into queue, task detail, group, or alarm screen.
- Foreground notifications show in-app banners where appropriate.

Dependencies: FEAT-006.

UI screens: Notification permission prompt, in-app banner component.

Backend logic: Token registration write.

Database changes: `users/{uid}.fcmTokens`.

Integrations: Firebase Cloud Messaging.

### FEAT-008: Personal Save System

Priority: MUST-HAVE  
Effort: Large, 1-2 weeks  
Feature files: `features/save/`, `core/platform/share_intent_service.dart`, `core/platform/clipboard_service.dart`

Description: Allow users to save links from URL paste, Android share intent, and clipboard detection with an editable save sheet.

Acceptance criteria:

- User can paste a URL and save it.
- Android share intent opens reMind save sheet.
- Clipboard URL banner appears non-intrusively.
- Save sheet includes title, thumbnail placeholder, source, category chips, tags, and reminder suggestion.
- Item writes to Hive immediately and syncs to Firestore if signed in.
- Invalid URL shows a specific error.

Dependencies: FEAT-005, FEAT-006.

UI screens: Save sheet, URL paste screen, clipboard banner.

Backend logic: Saved item repository.

Database changes: `users/{uid}/items/{itemId}`.

Integrations: Android share intent, clipboard, Firestore, Hive.

### FEAT-009: Metadata Enrichment and Content Extraction

Priority: MUST-HAVE  
Effort: Large, 1-2 weeks  
Feature files: `core/extraction/`, `features/save/data/`, `features/reader/data/`

Description: Fetch URL metadata, thumbnails, source domain, category suggestion, estimated read time, and readable content when possible.

Acceptance criteria:

- Open Graph title, description, image, and site name are extracted when available.
- Article read time is estimated.
- Simple category detection works by URL/domain/keywords.
- Extraction failure does not block saving.
- Enrichment updates the local item and syncs later.

Dependencies: FEAT-008.

UI screens: Save sheet metadata preview, loading state.

Backend logic: Optional Cloud Function proxy if direct fetch is unreliable.

Database changes: item metadata fields.

Integrations: HTTP client, readability extractor, Firebase Storage for cached thumbnails if used.

### FEAT-010: Smart Queue Engine

Priority: MUST-HAVE  
Effort: Large, 1-2 weeks  
Feature files: `features/queue/domain/`, `features/queue/data/`

Description: Implement queue population and sorting rules for Tonight, Weekend, Forgotten, Continue Reading, Watch Later, Learning, Recently Saved, and All.

Acceptance criteria:

- Queue engine produces deterministic queue membership from saved item fields.
- Tonight, Weekend, Forgotten, Continue Reading, Watch Later, Learning, and Recently Saved are implemented.
- Sorting rules match the product spec.
- Unit tests cover edge cases and stale items.
- Queue results can be computed from local Hive data.

Dependencies: FEAT-008, FEAT-009.

UI screens: None yet beyond provider outputs.

Backend logic: None; on-device logic.

Database changes: Uses item fields already created.

Integrations: Hive.

### FEAT-011: Queue UI Views

Priority: MUST-HAVE  
Effort: Large, 1-2 weeks  
Feature files: `features/queue/presentation/`

Description: Build queue list screens with cards, filters, skeleton loading, pull-to-refresh, swipe actions, and multi-select batch actions.

Acceptance criteria:

- Each queue opens from home or navigation.
- Queue cards show title, source, thumbnail, read time, reminder, and progress.
- Swipe right completes; swipe left archives.
- Long press enters multi-select.
- Pull-to-refresh triggers sync/enrichment refresh.
- Empty states are clear and action-oriented.

Dependencies: FEAT-010.

UI screens: Queue screen, queue card, filter bar, batch action toolbar.

Backend logic: Queue item updates.

Database changes: Item completion/archive fields.

Integrations: Riverpod, Hive, Firestore sync.

### FEAT-012: Home Hub Bento Grid and Quick-Save FAB

Priority: MUST-HAVE  
Effort: Large, 1-2 weeks  
Feature files: `features/home/`, `features/save/presentation/quick_save_fab.dart`

Description: Build the main home hub with responsive bento grid, greeting, queue previews, streak tile, task/alarm quick actions, group activity preview, and expandable FAB.

Acceptance criteria:

- Home renders from cached local data under 500 ms target.
- Phone layout uses 2-column bento grid; tablet uses 3 columns.
- Tiles include Reading Streak, Tonight Queue, Create Task, Set Alarm, Weekend Queue, Group Activity, Forgotten Queue, Recent Badges, Continue Reading.
- FAB expands to URL Paste, Create Task, Set Shared Alarm, and Voice Note placeholder.
- Empty states appear for no saves and no groups.

Dependencies: FEAT-011.

UI screens: Home screen, bento tile components, FAB.

Backend logic: Home dashboard provider composes feature repositories.

Database changes: None new.

Integrations: Riverpod, GoRouter.

### FEAT-013: Reader Screen and Progress Tracking

Priority: MUST-HAVE  
Effort: Large, 1-2 weeks  
Feature files: `features/reader/`

Description: Implement distraction-free reader view with extracted content, fallback browser, progress tracking, customization panel, highlights, and completion.

Acceptance criteria:

- Reader opens saved item content when available.
- Fallback opens in-app browser view if extraction fails.
- Top progress bar updates with scroll progress.
- User can adjust text size, font style, theme, and line spacing.
- Mark Complete updates item state and streak.
- Reader progress syncs locally and to Firestore.

Dependencies: FEAT-009, FEAT-011.

UI screens: Reader screen, reader settings sheet, highlight toolbar.

Backend logic: Progress update use case.

Database changes: `readingProgress`, `lastOpenedAt`, `highlights`, `isCompleted`.

Integrations: WebView/readability renderer, Hive, Firestore.

### FEAT-014: Personal Reminders

Priority: MUST-HAVE  
Effort: Large, 1-2 weeks  
Feature files: `features/reminder/`, `core/notifications/`, `core/platform/workmanager_service.dart`

Description: Add time-based and basic recurring reminders for saved items, powered by local scheduling and FCM where applicable.

Acceptance criteria:

- User can set Tonight, Tomorrow AM, Weekend, Custom, and recurring reminder.
- Reminder picker uses Material date/time picker.
- Reminder is saved on item and reflected in queues.
- Local notification fires on device.
- Signed-in user reminder syncs to Firestore.
- Missed/offline reminders show clear status.

Dependencies: FEAT-007, FEAT-008.

UI screens: Reminder picker sheet, reminder chips.

Backend logic: Optional scheduled digest support.

Database changes: item `reminder` object.

Integrations: Android notifications, WorkManager, FCM.

### FEAT-015: Reading Streaks

Priority: MUST-HAVE  
Effort: Medium, 4-7 days  
Feature files: `features/gamification/`

Description: Track daily reading completion, current streak, last completion date, and home streak tile.

Acceptance criteria:

- Completing an item increments daily completion.
- Streak increments only once per day.
- Streak resets or enters at-risk state according to configured rule.
- Home streak widget shows count and completion ring.
- Streak state persists locally and syncs for signed-in users.

Dependencies: FEAT-013.

UI screens: Streak tile, completion celebration.

Backend logic: Streak update use case.

Database changes: `users/{uid}.streakCount`, `streakLastDate`, local streak box.

Integrations: Hive, Firestore.

### FEAT-016: Badges and Basic Insights

Priority: SHOULD-HAVE  
Effort: Medium, 4-7 days  
Feature files: `features/gamification/`, `features/insights/`

Description: Implement initial badge system and insights screen showing completed items, streaks, and saved-versus-read trend.

Acceptance criteria:

- Badges exist for first save, first completion, 3-day streak, 7-day streak, first group task complete.
- Earned badge appears in home recent badges tile.
- Insights screen shows weekly counts and streak state.
- Badge logic is unit-tested.

Dependencies: FEAT-015.

UI screens: Badge gallery, insights screen, recent badges tile.

Backend logic: Badge calculation.

Database changes: user badge records.

Integrations: Hive, Firestore.

### FEAT-017: Create Group and Invite Members

Priority: MUST-HAVE  
Effort: Large, 1-2 weeks  
Feature files: `features/groups/`, `functions/src/groups/`

Description: Allow signed-in users to create a group, invite members, join by invite, and view member list with roles.

Acceptance criteria:

- Signed-in user can create a group with a name.
- Creator becomes admin.
- User can invite members by email or invite link.
- Invite notification or link routes recipient to join flow.
- Member list displays role, avatar, and joined state.
- Guest users see upgrade prompt instead of group creation.

Dependencies: FEAT-006, FEAT-007.

UI screens: Groups screen, create group sheet, invite member sheet, member list.

Backend logic: Group repository, invite Cloud Function.

Database changes: `groups/{groupId}`, `users/{uid}.groups`.

Integrations: Firestore, FCM, Cloud Functions, deep links.

### FEAT-018: Shared Task Creation and Assignment

Priority: MUST-HAVE  
Effort: Large, 1-2 weeks  
Feature files: `features/tasks/`, `features/groups/`

Description: Build group task list, task creation, assignment, due dates, priority, and real-time sync.

Acceptance criteria:

- Group members can create tasks.
- Task editor supports title, description, assignee, due date, and priority.
- Task list updates in real time across devices.
- Assigned member receives notification.
- Offline task creation queues and syncs later.
- Empty title validation exists.

Dependencies: FEAT-017, FEAT-005.

UI screens: Task list screen, task editor sheet, task detail screen.

Backend logic: Task repository, task assigned notification trigger.

Database changes: `groups/{groupId}/tasks/{taskId}`.

Integrations: Firestore real-time listeners, FCM, Cloud Functions.

### FEAT-019: Shared Task Completion, Comments, and Conflict States

Priority: MUST-HAVE  
Effort: Medium, 4-7 days  
Feature files: `features/tasks/`, `functions/src/tasks/`

Description: Add task completion, lightweight comments, task update sync indicators, and last-write-wins conflict messaging.

Acceptance criteria:

- Member can mark task complete.
- Completion writes `completedAt` and `completedBy`.
- Group members receive completion notification where enabled.
- Comments can be added to task detail.
- Concurrent edit shows "This was edited by [User]" state.
- Offline completion syncs on reconnect.

Dependencies: FEAT-018.

UI screens: Task detail screen, comments list, sync state chip.

Backend logic: Task completed trigger, activity event creation.

Database changes: task `comments`, `completedAt`, `completedBy`, `updatedBy`.

Integrations: Firestore, FCM, Cloud Functions.

### FEAT-020: Shared Alarm Creation

Priority: MUST-HAVE  
Effort: Large, 1-2 weeks  
Feature files: `features/alarms/`, `functions/src/alarms/`

Description: Allow group members to create shared alarms with title, message, scheduled time, repeat, group, and recipients.

Acceptance criteria:

- Alarm creator sheet supports required fields.
- Alarm is saved locally and to Firestore.
- Alarm appears in group alarm list.
- Recipients are validated as current group members.
- Repeat options include once, daily, weekly.
- Offline alarm creation queues and syncs with pending state.

Dependencies: FEAT-017, FEAT-007.

UI screens: Alarm creator sheet, group alarm list.

Backend logic: Alarm repository.

Database changes: `groups/{groupId}/alarms/{alarmId}`.

Integrations: Firestore, Hive.

### FEAT-021: Shared Alarm Delivery, Receive UI, and Dismissal

Priority: MUST-HAVE  
Effort: Large, 1-2 weeks  
Feature files: `features/alarms/`, `core/notifications/`, `functions/src/alarms/`

Description: Deliver due alarms through Cloud Functions and FCM, show full-screen alarm UI, and track dismissals by recipient.

Acceptance criteria:

- Cloud Function finds due scheduled alarms.
- FCM sends alarm payload to recipients.
- Client opens full-screen received alarm UI for critical alarm events.
- Recipient can dismiss alarm.
- Dismissal writes to `dismissals.{uid}`.
- Delivery log records success/failure by recipient.
- Missed alarm behavior works after reconnect.

Dependencies: FEAT-020.

UI screens: Alarm received screen, dismiss confirmation state.

Backend logic: Scheduled alarm processor, delivery logging.

Database changes: alarm `dismissals`, `deliveryLog`, `lastTriggeredAt`, `status`.

Integrations: Cloud Functions, FCM, WorkManager.

### FEAT-022: Group Management

Priority: MUST-HAVE  
Effort: Medium, 4-7 days  
Feature files: `features/groups/`

Description: Add group settings, member removal, role display, leave group, and access-removed handling.

Acceptance criteria:

- Admin can remove members.
- Member can leave group.
- Non-admin destructive actions are disabled with clear helper text.
- Removed member currently viewing a group sees "You've been removed" state.
- At least one admin remains in a group.

Dependencies: FEAT-017.

UI screens: Group settings screen, member management sheet, removed access state.

Backend logic: Group permission checks and security rules.

Database changes: `groups/{groupId}.members`.

Integrations: Firestore.

### FEAT-023: Group Activity Feed

Priority: MUST-HAVE  
Effort: Medium, 4-7 days  
Feature files: `features/groups/`, `features/home/`, `functions/src/activity/`

Description: Create and display recent group activity events for task completion, task creation, alarms, invites, and member joins.

Acceptance criteria:

- Activity events are written by Cloud Functions or trusted repository paths.
- Group detail shows recent activity.
- Home bento tile shows last five relevant events.
- Events are tappable and route to task, alarm, or group detail.
- Feed paginates older events.

Dependencies: FEAT-019, FEAT-021.

UI screens: Group activity feed, home activity tile.

Backend logic: Activity event creation triggers.

Database changes: `groups/{groupId}/activity/{eventId}`.

Integrations: Firestore, Cloud Functions.

### FEAT-024: Firestore Security Rules and Emulator Tests

Priority: MUST-HAVE  
Effort: Large, 1-2 weeks  
Feature files: `firestore.rules`, `storage.rules`, `test/rules/`

Description: Implement Firestore and Storage security rules for users, items, groups, tasks, alarms, activity, and assets.

Acceptance criteria:

- Users can read/write only their own personal items.
- Group members can read group data.
- Removed members cannot read group tasks or alarms.
- Members cannot promote themselves to admin.
- Alarm dismissal updates are limited to current user's dismissal field.
- Storage access matches ownership or group membership.
- Emulator tests cover allow and deny cases.

Dependencies: FEAT-017, FEAT-018, FEAT-020.

UI screens: None.

Backend logic: Security rules.

Database changes: None new.

Integrations: Firebase Emulator Suite.

### FEAT-025: Home Screen Widgets

Priority: SHOULD-HAVE  
Effort: Large, 1-2 weeks  
Feature files: `features/widgets/`, Android native widget files, `core/platform/widget_bridge_service.dart`

Description: Build Android home screen widgets for Smart Queue, Quick Save, Reading Streak, and Pending Tasks.

Acceptance criteria:

- Smart Queue 4x1 widget shows next item and opens reader.
- Quick Save 1x1 widget triggers clipboard save flow.
- Reading Streak 2x2 widget shows streak count and ring.
- Pending Tasks 4x2 widget shows next group task.
- Widgets update after relevant data changes.

Dependencies: FEAT-012, FEAT-015, FEAT-018.

UI screens: Widget configuration if needed.

Backend logic: Widget data bridge from Hive.

Database changes: None.

Integrations: home_widget, Android Glance.

### FEAT-026: Subscription Entitlements

Priority: SHOULD-HAVE  
Effort: Medium, 4-7 days  
Feature files: `services/revenuecat_service.dart`, `features/profile/`, `features/settings/`

Description: Integrate RevenueCat to support Free, Pro, and Family tiers with entitlement checks for group limits and advanced features.

Acceptance criteria:

- App fetches current entitlement.
- Free tier allows one group with up to three members.
- Pro and Family unlock configured limits.
- Restore purchases works.
- Entitlement state syncs to Firestore.

Dependencies: FEAT-006, FEAT-017.

UI screens: Subscription screen, upgrade prompt.

Backend logic: Optional RevenueCat webhook.

Database changes: `users/{uid}.plan`, entitlement metadata.

Integrations: RevenueCat, Cloud Functions webhook.

### FEAT-027: Settings and Notification Preferences

Priority: SHOULD-HAVE  
Effort: Medium, 4-7 days  
Feature files: `features/settings/`, `core/notifications/`

Description: Build settings for notification channels, reader preferences, theme, account, logout, and privacy.

Acceptance criteria:

- User can toggle digest, task assignment, task completion, group activity, reminders, and alarm preferences.
- Reader defaults persist.
- Theme selection persists.
- Logout works from settings.
- Privacy/account deletion entry is visible.

Dependencies: FEAT-006, FEAT-007, FEAT-013.

UI screens: Settings screen, notification preferences, reader defaults.

Backend logic: Preferences repository.

Database changes: `users/{uid}.preferences`.

Integrations: Firestore, SharedPreferences.

### FEAT-028: Account Deletion and Data Cleanup

Priority: MUST-HAVE  
Effort: Medium, 4-7 days  
Feature files: `features/settings/`, `functions/src/account/`

Description: Implement account deletion flow that removes personal data, FCM tokens, and user membership while preserving shared group history appropriately.

Acceptance criteria:

- User can request account deletion with confirmation.
- Personal saved items and profile are deleted.
- FCM tokens are removed.
- User is removed from all groups.
- Sole-admin edge case is handled before deletion.
- Shared task history shows anonymized deleted user if preserved.

Dependencies: FEAT-022, FEAT-024.

UI screens: Delete account confirmation, deletion progress.

Backend logic: Account cleanup Cloud Function.

Database changes: Removes user data and updates group membership.

Integrations: Firebase Auth, Firestore, Storage, Cloud Functions.

### FEAT-029: QA, Performance, and Launch Instrumentation

Priority: MUST-HAVE  
Effort: Large, 1-2 weeks  
Feature files: `core/analytics/`, `test/`, `integration_test/`

Description: Add analytics events, crash reporting, performance traces, integration tests, and launch readiness checks.

Acceptance criteria:

- Analytics events exist for signup, first save, queue open, item complete, group create, task create, alarm create, alarm dismiss.
- Crash reporting is configured.
- Integration tests cover signup, save first article, create group, assign task, set shared alarm.
- Startup, home render, and save completion timings are measured.
- Release checklist exists.

Dependencies: FEAT-001 through FEAT-024.

UI screens: None.

Backend logic: Analytics and logging.

Database changes: None.

Integrations: Firebase Analytics, Crashlytics, Performance Monitoring or selected equivalents.

### FEAT-030: Play Store Launch Assets and ASO Prep

Priority: SHOULD-HAVE  
Effort: Medium, 4-7 days  
Feature files: `docs/launch/`, asset folders

Description: Prepare app title, short description, screenshots plan, feature graphic direction, privacy policy link, and beta launch checklist.

Acceptance criteria:

- App title and short description are finalized.
- Screenshot list covers home, save flow, reader, groups, tasks, alarms, widgets, insights.
- Feature graphic direction is documented.
- Privacy policy and terms URLs exist.
- Internal testing release checklist is complete.

Dependencies: FEAT-012, FEAT-013, FEAT-018, FEAT-021.

UI screens: Screenshots from built app.

Backend logic: None.

Database changes: None.

Integrations: Google Play Console.

## Recommended MVP Cut Line

If timeline pressure appears, keep these features for the first private beta:

- FEAT-001 through FEAT-015.
- FEAT-017 through FEAT-024.
- FEAT-027 through FEAT-029.

Move these to beta 2 if needed:

- FEAT-016 Badges and Basic Insights beyond the minimal streak tile.
- FEAT-025 Home Screen Widgets.
- FEAT-026 Subscription Entitlements if launch is free beta.
- FEAT-030 full ASO assets until public release.

## Dependency Map

```text
FEAT-001 -> FEAT-002 -> FEAT-003 -> FEAT-004 -> FEAT-005
FEAT-005 -> FEAT-006 -> FEAT-007
FEAT-005 + FEAT-006 -> FEAT-008 -> FEAT-009 -> FEAT-010 -> FEAT-011 -> FEAT-012
FEAT-009 + FEAT-011 -> FEAT-013 -> FEAT-015 -> FEAT-016
FEAT-007 + FEAT-006 -> FEAT-017 -> FEAT-018 -> FEAT-019 -> FEAT-023
FEAT-017 + FEAT-007 -> FEAT-020 -> FEAT-021 -> FEAT-023
FEAT-017 -> FEAT-022 -> FEAT-024 -> FEAT-028
FEAT-012 + FEAT-015 + FEAT-018 -> FEAT-025
FEAT-006 + FEAT-017 -> FEAT-026
FEAT-006 + FEAT-007 + FEAT-013 -> FEAT-027
FEAT-001..FEAT-024 -> FEAT-029
```
