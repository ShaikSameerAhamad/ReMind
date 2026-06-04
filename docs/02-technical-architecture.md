# reMind Technical Architecture Document

Version: 1.0  
Platform: Android-first Flutter app  
Backend: Firebase  
Architecture: Feature-first Clean Architecture with offline-first sync

## 1. Architecture Goals

reMind must feel instant, reliable, and Android-native. Users should be able to save, read, create tasks, and schedule alarms even when offline. Cloud sync should happen in the background and never block basic usage.

Primary architecture goals:

- Fast startup and instant local reads.
- Clear separation between UI, business logic, data sources, and platform services.
- Offline-first data writes with transparent sync state.
- Real-time collaboration for groups, tasks, alarms, and activity.
- Firebase-backed MVP that can scale without a large backend team.
- Testable feature modules that can be developed independently.

## 2. Tech Stack With Reasoning

| Layer | Choice | Reasoning |
|---|---|---|
| Mobile framework | Flutter latest stable, Dart 3.x | Fast cross-platform iteration, excellent Android support, strong UI animation system, one codebase for future iOS/web. |
| State management | Riverpod 2.x with code generation | Testable providers, explicit dependency graph, good async handling, supports Clean Architecture boundaries. |
| Navigation | GoRouter | Declarative routing, nested navigation, deep links for notifications and group invites. |
| Backend compute | Firebase Cloud Functions | Serverless MVP backend for notification triggers, scheduled jobs, cleanup, and group invite workflows. |
| Cloud database | Cloud Firestore | Real-time sync, offline persistence, flexible schemas, strong fit for collaborative documents. |
| Local database | Hive | Fast key-value and object storage, simple offline queues, low overhead versus SQLite for MVP. |
| Preferences | SharedPreferences | Lightweight app preferences, onboarding completion, small UI settings. |
| Auth | Firebase Auth + Google Sign-In | Low-friction login, secure token lifecycle, anonymous/guest migration support. |
| Push | Firebase Cloud Messaging | Android notification delivery, topics/tokens, Cloud Functions integration. |
| Background work | WorkManager | Reliable Android background sync and local fallback for reminders/alarms under Doze constraints. |
| Storage | Firebase Storage | Thumbnails, avatars, generated quote cards, cached delivery URLs. |
| Subscriptions | RevenueCat | Simplifies Play Billing, entitlements, trial status, restore purchases. |
| Hosting | Firebase Hosting | Optional landing page, invite links, privacy policy, support pages. |
| Content extraction | flutter_readability or custom extractor | Converts saved URLs into reader-friendly content when possible. |
| Widgets | home_widget + Android Glance | Smart queue, streak, quick save, and task widgets. |

## 3. System Overview

```text
Android App
  |
  |-- Flutter UI screens
  |-- Riverpod providers
  |-- Feature use cases
  |-- Repositories
  |-- Local data sources: Hive, SharedPreferences, secure storage
  |-- Remote data sources: Firestore, Auth, FCM, Storage, Functions
  |-- Platform services: Share Intent, Clipboard, WorkManager, Widgets

Firebase
  |
  |-- Firebase Auth
  |-- Firestore
  |-- Cloud Functions
  |-- Firebase Cloud Messaging
  |-- Firebase Storage
  |-- Firebase Hosting
```

## 4. Clean Architecture Pattern

Each feature follows a feature-first Clean Architecture structure:

- `presentation`: screens, widgets, controllers, view models, UI state.
- `domain`: entities, use cases, repository interfaces, business rules.
- `data`: DTOs, mappers, repository implementations, local and remote data sources.

UI depends on domain interfaces, not Firebase directly. Data implementations can change without rewriting screens.

## 5. Project Structure

```text
lib/
  main.dart
  app.dart

  core/
    analytics/
      analytics_service.dart
    config/
      app_environment.dart
      firebase_options_dev.dart
      firebase_options_staging.dart
      firebase_options_prod.dart
    constants/
      app_constants.dart
      route_names.dart
    errors/
      app_exception.dart
      failure.dart
    extraction/
      article_extractor.dart
      metadata_enrichment_service.dart
    firebase/
      firebase_initializer.dart
      firestore_paths.dart
      firebase_error_mapper.dart
    notifications/
      fcm_service.dart
      notification_router.dart
      notification_channels.dart
    platform/
      clipboard_service.dart
      share_intent_service.dart
      workmanager_service.dart
      widget_bridge_service.dart
    routing/
      app_router.dart
      deep_link_parser.dart
    storage/
      hive_initializer.dart
      secure_token_store.dart
      sync_queue_store.dart
    sync/
      sync_engine.dart
      sync_operation.dart
      conflict_resolver.dart
    theme/
      app_colors.dart
      app_typography.dart
      app_theme.dart
      brand_assets.dart
    utils/
      date_time_extensions.dart
      validators.dart
      result.dart

  models/
    item_category.dart
    sync_status.dart
    user_role.dart

  services/
    revenuecat_service.dart
    connectivity_service.dart
    logger_service.dart

  features/
    auth/
      data/
        auth_repository_impl.dart
        firebase_auth_data_source.dart
      domain/
        auth_repository.dart
        app_user.dart
        sign_in_with_google.dart
        continue_as_guest.dart
        sign_out.dart
      presentation/
        onboarding_screen.dart
        sign_in_screen.dart
        auth_controller.dart

    home/
      data/
      domain/
        home_dashboard_model.dart
        load_home_dashboard.dart
      presentation/
        home_screen.dart
        bento_grid.dart
        quick_save_fab.dart

    save/
      data/
        saved_item_repository_impl.dart
        metadata_remote_data_source.dart
        item_local_data_source.dart
      domain/
        saved_item.dart
        save_url.dart
        categorize_saved_item.dart
      presentation/
        save_sheet.dart
        clipboard_banner.dart
        url_paste_screen.dart

    queue/
      data/
      domain/
        smart_queue.dart
        smart_queue_engine.dart
        get_queue_items.dart
      presentation/
        queue_screen.dart
        queue_card.dart
        queue_filter_bar.dart

    reader/
      data/
      domain/
        reader_content.dart
        update_reading_progress.dart
        mark_item_complete.dart
      presentation/
        reader_screen.dart
        reader_settings_sheet.dart
        highlight_toolbar.dart

    reminder/
      data/
      domain/
        reminder.dart
        schedule_reminder.dart
      presentation/
        reminder_picker_sheet.dart

    groups/
      data/
        group_repository_impl.dart
        group_remote_data_source.dart
      domain/
        group.dart
        create_group.dart
        invite_member.dart
        remove_member.dart
      presentation/
        groups_screen.dart
        group_detail_screen.dart
        invite_member_sheet.dart
        member_list.dart

    tasks/
      data/
        task_repository_impl.dart
      domain/
        group_task.dart
        create_task.dart
        assign_task.dart
        complete_task.dart
      presentation/
        task_list_screen.dart
        task_detail_screen.dart
        task_editor_sheet.dart

    alarms/
      data/
        alarm_repository_impl.dart
      domain/
        shared_alarm.dart
        create_shared_alarm.dart
        dismiss_alarm.dart
      presentation/
        alarm_creator_sheet.dart
        alarm_received_screen.dart
        group_alarm_list.dart

    gamification/
      data/
      domain/
        streak.dart
        badge.dart
        update_streak.dart
      presentation/
        streak_widget.dart
        badge_gallery_screen.dart
        insights_screen.dart

    profile/
    settings/
    search/
    widgets/
```

## 6. Offline-First Data Flow

### Read Path

```text
Screen opens -> Repository reads Hive immediately -> UI renders cached state
             -> Repository subscribes to Firestore -> Remote changes mapped to domain
             -> Hive cache updated -> Riverpod state refreshes UI
```

### Write Path

```text
User action -> Validate locally -> Write to Hive with syncStatus=pending
            -> Add operation to sync queue
            -> Try Firestore write
            -> On success: mark synced
            -> On failure: keep pending, retry with WorkManager
```

### Conflict Strategy

MVP uses last-write-wins with `updatedAt` timestamps. For collaborative task conflicts, show a toast or dialog: "This was edited by [User]. Review latest version." Append-only records such as alarm dismissals and highlights should not be overwritten.

## 7. Firestore Database Schema

### Collection: `users/{uid}`

Plain English: stores a user's profile, preferences, subscription state, device tokens, denormalized group references, and personal saved items.

| Field | Type | Notes |
|---|---|---|
| uid | string | Firebase Auth UID. |
| profile | object | `{ name, email, avatarUrl, createdAt }` |
| preferences | object | Reader, notification, queue, theme, reminder defaults. |
| groups | map | `{ groupId: joinedAt }` for fast lookup. |
| streakCount | number | Current reading streak. |
| streakLastDate | timestamp | Last completion date. |
| plan | string | `free`, `pro`, `family`. |
| fcmTokens | map | Device token metadata by token ID. |
| createdAt | timestamp | Account creation. |
| updatedAt | timestamp | Last profile update. |

### Subcollection: `users/{uid}/items/{itemId}`

| Field | Type | Notes |
|---|---|---|
| title | string | Editable saved item title. |
| url | string | Original URL. |
| sourceDomain | string | Domain for display and filtering. |
| thumbnailUrl | string | Firebase Storage or remote thumbnail. |
| category | string | `article`, `video`, `product`, `social`, `recipe`, `learning`, `note`. |
| tags | array<string> | User tags. |
| description | string | Metadata summary. |
| extractedContent | string | HTML or text content for reader. |
| readTimeMinutes | number | Estimated read time. |
| savedAt | timestamp | Initial save time. |
| reminder | object | `{ type, scheduledAt, behaviorBlock, repeatRule }` |
| isCompleted | bool | Read or completed. |
| isArchived | bool | Archived state. |
| readingProgress | number | 0.0 to 1.0. |
| lastOpenedAt | timestamp | Reader tracking. |
| highlights | array<object> | `{ id, text, note, position, color, updatedAt }` |
| offlineCached | bool | Whether full content exists locally. |
| sharedSpaceId | string|null | Link to shared space if shared. |
| createdAt | timestamp | Creation. |
| updatedAt | timestamp | Last update. |

### Collection: `groups/{groupId}`

Plain English: a collaborative workspace for a family, team, couple, or roommate group.

| Field | Type | Notes |
|---|---|---|
| name | string | Display name. |
| createdBy | string | Admin creator UID. |
| members | map | `{ uid: { role, joinedAt, displayName, avatarUrl } }` |
| inviteCodes | map | Active invite metadata, optional. |
| createdAt | timestamp | Creation. |
| updatedAt | timestamp | Last group setting update. |
| lastActivityAt | timestamp | Feed sorting. |
| archivedAt | timestamp|null | Soft delete marker. |

### Subcollection: `groups/{groupId}/tasks/{taskId}`

| Field | Type | Notes |
|---|---|---|
| title | string | Required. |
| description | string | Optional details. |
| assignedTo | string|null | UID of member. |
| createdBy | string | UID. |
| dueDate | timestamp|null | Optional. |
| isCompleted | bool | Completion state. |
| completedAt | timestamp|null | Completion time. |
| completedBy | string|null | UID. |
| comments | array<object> | `{ uid, displayName, text, timestamp }` |
| priority | string | `low`, `medium`, `high`. |
| syncStatus | string | `synced`, `pending`, `failed`. |
| createdAt | timestamp | Creation. |
| updatedAt | timestamp | Conflict timestamp. |

### Subcollection: `groups/{groupId}/alarms/{alarmId}`

| Field | Type | Notes |
|---|---|---|
| title | string | Required. |
| message | string | Optional message. |
| createdBy | string | UID. |
| scheduledAt | timestamp | Exact scheduled time. |
| localTimeZone | string | IANA timezone at creation. |
| repeat | string | `once`, `daily`, `weekly`, `custom`. |
| repeatDays | array<number> | 0-6 for weekly rules. |
| recipients | array<string> | Member UIDs. |
| status | string | `scheduled`, `sent`, `completed`, `cancelled`. |
| dismissals | map | `{ uid: timestamp }` |
| deliveryLog | array<object> | `{ uid, tokenId, status, timestamp, errorCode }` |
| createdAt | timestamp | Creation. |
| updatedAt | timestamp | Last update. |
| lastTriggeredAt | timestamp|null | Last alarm trigger. |

### Collection: `sharedSpaces/{sharedSpaceId}`

| Field | Type | Notes |
|---|---|---|
| name | string | Shared reading space name. |
| ownerUid | string | Creator. |
| groupId | string|null | Optional group relationship. |
| members | array<string> | User IDs. |
| itemIds | array<string> | References to shared saved items. |
| reactions | map | Lightweight reactions by item. |
| createdAt | timestamp | Creation. |
| updatedAt | timestamp | Last change. |

### Collection: `activityEvents/{eventId}` or `groups/{groupId}/activity/{eventId}`

| Field | Type | Notes |
|---|---|---|
| groupId | string | Parent group. |
| actorUid | string | User who acted. |
| type | string | `task_created`, `task_completed`, `alarm_set`, `member_joined`. |
| targetId | string | Task, alarm, or member ID. |
| text | string | Renderable event summary. |
| createdAt | timestamp | Feed ordering. |

## 8. Environment Variables and Config

Use Flutter flavors and separate Firebase projects for dev, staging, and production.

### `.env.local` / environment config

```text
APP_ENV=dev
FIREBASE_API_KEY=
FIREBASE_AUTH_DOMAIN=
FIREBASE_PROJECT_ID=
FIREBASE_STORAGE_BUCKET=
FIREBASE_MESSAGING_SENDER_ID=
FIREBASE_APP_ID=
FIREBASE_FUNCTIONS_REGION=asia-south1
REVENUECAT_ANDROID_API_KEY=
OPENAI_API_KEY_PHASE2=
SENTRY_DSN=
APP_INVITE_BASE_URL=
```

Never hardcode:

- Firebase API keys or project IDs in shared source beyond generated flavor config.
- RevenueCat keys.
- OpenAI or third-party API keys.
- Signing certificates or keystore passwords.
- FCM server keys.
- Admin SDK credentials.

Recommended environments:

| Environment | Firebase Project | Use |
|---|---|---|
| dev | `remind-dev` | Local development, fake data, relaxed quotas. |
| staging | `remind-staging` | Beta builds, QA, production-like rules. |
| prod | `remind-prod` | Live users and billing. |

## 9. Cloud Functions

| Function | Trigger | Responsibility |
|---|---|---|
| `onGroupInviteCreated` | Firestore create | Send invite notification or email link. |
| `onTaskAssigned` | Firestore create/update | Notify assigned member. |
| `onTaskCompleted` | Firestore update | Notify group members and write activity event. |
| `scheduleDailyDigest` | Scheduled pub/sub | Send daily reading and task digests. |
| `processSharedAlarms` | Scheduled every minute | Find due alarms and send FCM to recipients. |
| `onAlarmDismissed` | Firestore update | Update completion state and activity event. |
| `cleanupArchivedItems` | Scheduled daily | Delete old archived records and storage assets. |
| `syncRevenueCatWebhook` | HTTPS webhook | Update entitlement state in Firestore. |

## 10. Performance Considerations

### Startup and Rendering

- Initialize Firebase, Hive, and critical providers before app shell.
- Lazy-load non-critical features such as badge gallery and insights.
- Use `const` widgets wherever possible.
- Use `RepaintBoundary` around animated bento tiles and reader progress bar.
- Avoid large synchronous metadata extraction on the main isolate.

### Firestore Indexes

Create indexes for:

| Query | Index |
|---|---|
| User items by `isArchived`, `savedAt desc` | `users/{uid}/items`: `isArchived`, `savedAt` |
| User items by `category`, `savedAt desc` | `category`, `savedAt` |
| Continue Reading queue | `readingProgress`, `lastOpenedAt` |
| Forgotten queue | `isCompleted`, `savedAt` |
| Group tasks by completion and due date | `groups/{groupId}/tasks`: `isCompleted`, `dueDate` |
| Group activity by date | `groups/{groupId}/activity`: `createdAt desc` |
| Due alarms | collection group `alarms`: `status`, `scheduledAt` |

### Caching Strategy

Hive caches:

- Current user profile and preferences.
- Saved items and extracted reader content.
- Queue membership snapshots.
- Groups, tasks, alarms, and members.
- Activity feed recent events.
- Sync operation queue.
- Reader progress and highlights.

SharedPreferences stores:

- Onboarding completion.
- Last selected theme.
- Last active group ID.
- Lightweight UI toggles.

Secure storage stores:

- Sensitive local encryption keys.
- Any non-Firebase tokens required by integrations.

### Pagination

| Surface | Page Size | Strategy |
|---|---|---|
| Saved items | 20 | Infinite scroll with Firestore cursors. |
| Queue lists | 20 | Query by queue rules, cache local snapshot. |
| Group tasks | 20 | Active tasks first, completed paginated separately. |
| Activity feed | 30 | Recent events cached, older events loaded on scroll. |
| Highlights | Per item | Loaded with item until size requires subcollection. |

## 11. Reliability Targets

| Area | Target |
|---|---|
| Cold startup | Under 2 seconds |
| Home render from cache | Under 500 ms |
| Queue open from cache | Under 300 ms |
| Save local completion | Under 1 second |
| Reader open from cached content | Under 800 ms |
| Task create local completion | Under 800 ms |
| Alarm create local completion | Under 600 ms |

## 12. Testing Strategy

| Test Type | Scope |
|---|---|
| Unit tests | Queue sorting, reminder parsing, conflict resolution, permission helpers. |
| Repository tests | Hive and Firestore repository behavior with fake data sources. |
| Widget tests | Save sheet, queue cards, task editor, alarm received screen. |
| Integration tests | Signup, save URL, create group, assign task, create alarm. |
| Firebase emulator tests | Security rules, Cloud Functions triggers, Firestore schema behavior. |
| Performance tests | Startup, home render, long queue scroll, group task updates. |

## 13. Build and Release

- Use Flutter flavors: `dev`, `staging`, `prod`.
- CI should run formatting, static analysis, unit tests, widget tests, and Firebase rules tests.
- Staging builds go to internal testers.
- Production builds require Play Console release notes, privacy checklist, and crash-free threshold.
