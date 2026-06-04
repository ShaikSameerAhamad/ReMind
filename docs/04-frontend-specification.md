# reMind Frontend Specification Document

Version: 1.0  
Platform: Android-first Flutter  
Brand: reMind  
Tagline: Save smarter. Sync better  
Primary font: Onest

## 1. Frontend Goals

reMind should feel calm in normal use and unmistakable during urgent moments. Saving, reading, task creation, and alarm handling should be fast, tactile, and visually clear. The app should use Material 3 foundations, Android platform conventions, and a focused brand system built around the recall loop icon.

Frontend principles:

- The first screen is the working home hub, not a marketing page.
- Core actions are always within one or two taps.
- Offline and sync states are visible but not alarming.
- Shared tasks and alarms feel lightweight, not enterprise-heavy.
- Critical alarms use high-contrast layouts and strong hierarchy.

## 2. Brand System

### Name and Tagline

| Item | Value |
|---|---|
| Product name | reMind |
| Tagline | Save smarter. Sync better |
| Logo idea | Lowercase `r` inside a recall/return loop |
| Personality | Calm, useful, modern, quietly smart |

### Logo Direction

The app icon should use a lowercase `r` nested inside a circular recall/return loop. The loop represents coming back to saved content and keeping shared tasks synchronized. The icon should work in these contexts:

- Launcher icon on light and dark backgrounds.
- App bar or compact brand mark.
- Splash animation.
- Notification icon, simplified as monochrome.
- Home screen widget header.

### Color Palette

The base palette comes from the provided brand direction.

| Token | Hex | Usage |
|---|---|---|
| Ink | `#10171c` | Primary text, dark surfaces, critical contrast. |
| Sky | `#97cff3` | Primary actions, loop gradient start, links, selected states. |
| Mint | `#a7e8d1` | Secondary accent, success, sync-complete cues, loop gradient end. |
| Cloud | `#f7f7f7` | Light background, cards, app icon background. |

### Extended Functional Palette

| Role | Hex | Usage |
|---|---|---|
| Primary | `#97cff3` | Main action buttons, active tabs, focus rings. |
| Primary on-color | `#10171c` | Text/icons on primary buttons. |
| Secondary | `#a7e8d1` | Sync states, soft highlights, secondary controls. |
| Success | `#28b487` | Completed tasks, streak confirmation, sync success. |
| Warning | `#f5b84b` | Streak at risk, pending sync, due soon. |
| Error | `#e94f4f` | Validation errors, destructive actions. |
| Light background | `#f7f7f7` | Default app background. |
| Light surface | `#ffffff` | Cards, sheets, panels. |
| Dark background | `#10171c` | Dark mode background. |
| Dark surface | `#172128` | Dark mode cards and sheets. |
| Primary text | `#10171c` | Main text in light mode. |
| Secondary text | `#61707b` | Metadata, captions, inactive text. |
| Border | `#dce7ed` | Dividers and input borders. |
| Critical background | `#10171c` | Full-screen alarm state. |
| Critical accent | `#a7e8d1` | Alarm dismiss/snooze controls. |

Material You note: on Android 12+, reMind may adapt tonal surfaces to the user's wallpaper, but brand-critical actions should preserve the Sky/Mint/Ink identity. Dynamic color should influence secondary surfaces, not dilute the logo or main action colors.

## 3. Typography

Use Onest for all app typography. Onest is a modern sans-serif with readable forms for dense productivity UIs and enough warmth for consumer use.

| Style | Font | Size | Weight | Usage |
|---|---|---:|---:|---|
| Display | Onest | 36sp | 800 | Splash, major empty states only. |
| Heading 1 | Onest | 32sp | 700 | Home greeting, page titles. |
| Heading 2 | Onest | 24sp | 700 | Section titles, modal titles. |
| Heading 3 | Onest | 20sp | 650 | Card titles, task detail headings. |
| Body | Onest | 16sp | 400 | Main readable text. |
| Body Strong | Onest | 16sp | 600 | Important labels, task titles. |
| Small | Onest | 13sp | 400 | Metadata, timestamps, helper text. |
| Label | Onest | 12sp | 600 | Chips, tabs, badges. |
| Button | Onest | 15sp | 700 | Button labels. |

Do not scale font size directly with viewport width. Use Material text scaling support and responsive layout constraints.

## 4. Spacing and Layout

| Rule | Value |
|---|---|
| Base unit | 8dp |
| Screen horizontal padding | 16dp phone, 24dp tablet |
| Bento grid gap | 12dp |
| List item gap | 12dp |
| Section gap | 24dp |
| Button height | 48dp minimum |
| Icon button target | 44dp minimum |
| Card radius | 16dp for app cards; 8dp for dense repeated items |
| Sheet top radius | 24dp |
| Input height | 52dp |

Home layout:

- Phone: 2-column bento grid.
- Tablet: 3-column bento grid.
- Landscape: 3-4 columns depending on available width.
- Tiles have fixed aspect ratios so content does not shift during loading or hover/tap states.

## 5. Component Styles

### Buttons

| Type | Appearance | States |
|---|---|---|
| Primary | Filled Sky background, Ink text, 48dp height, 16dp radius. | Press scale 0.96, disabled opacity 0.38, loading spinner. |
| Secondary | Transparent or Cloud surface, 1.5dp Sky border, Ink text. | Focus border Mint, pressed Sky tint. |
| Tertiary | Text only, Ink or Sky label, no container. | Pressed underline/tint, disabled secondary text. |
| Critical | Ink background, Mint or white text, bold border in Mint. | Used for alarm UI and urgent reminders. |
| Destructive | Error background or text depending on risk. | Confirm destructive group or account actions. |

Use icons in buttons when the action is common: save, sync, add, archive, complete, alarm, group, search, settings.

### Inputs

| State | Text Field Style |
|---|---|
| Default | White or dark surface, Border color, 16dp horizontal padding. |
| Focused | 2dp Sky border, subtle Sky glow or fill tint. |
| Error | Error border, helper text in Error, error icon. |
| Disabled | Muted fill, secondary text, no shadow. |
| Filled | Label floats or remains above field for clarity. |

Dropdowns use the same shell as text inputs with a chevron icon. Date/time fields open Material 3 pickers in bottom sheets.

### Cards

| Card | Layout |
|---|---|
| Reading queue card | Thumbnail left or top, title, source, read time, reminder chip, progress indicator. |
| Task card | Checkbox/status, title, assignee avatar, due date chip, priority marker. |
| Alarm card | Alarm time, title, repeat rule, recipient avatars, status chip. |
| Group activity card | Actor avatar, action text, target title, timestamp. |
| Streak card | Large streak number, completion ring, weekly heatmap. |

Cards use minimal elevation in normal state and stronger elevation on long press. Avoid putting cards inside larger decorative cards.

### Modals and Bottom Sheets

Use bottom sheets for save, task creation, alarm creation, invite member, reminder picker, and reader customization.

Animation:

- Sheet slides up with spring easing.
- Scrim fades in.
- Drag handle is visible.
- Keyboard-safe layout scrolls inner content.
- Save/create actions stay pinned at bottom when content is long.

### Notifications and Banners

| Type | Style |
|---|---|
| Toast | Compact floating surface, Ink text, optional icon, 4 seconds max. |
| Offline banner | Persistent top or bottom banner, Warning tint, sync spinner. |
| Sync complete | Small Mint checkmark chip that fades after 2 seconds. |
| Error banner | Error tint, concise action such as Retry. |
| Critical alarm | Full-screen Ink background with large time/title and high-contrast controls. |

### Lists

- Use `ListView.builder` for long lists.
- Preserve scroll position per tab/queue.
- Skeleton loaders must match final card shape.
- Swipe actions: complete to the right, archive or assign to me to the left.
- Multi-select enters from long press with haptic feedback.

### Avatars

- Circular avatars, 32dp in lists, 40dp in detail headers.
- Stacked avatars overlap by 8dp for recipients or active viewers.
- Fallback initials use Sky/Mint pastel fill and Ink text.
- Admin badge is a small shield/star overlay when needed.

## 6. Key Screens

| Screen | Purpose | Primary Components |
|---|---|---|
| Splash | Brand entry and initialization. | Animated loop icon, tagline. |
| Onboarding | Explain saving, queues, sync. | 3 slides, skip, progress. |
| Auth | Google Sign-In and guest mode. | Primary auth button, guest link. |
| Home | Daily operating surface. | Bento grid, FAB, queue previews, group activity. |
| Save sheet | Capture link quickly. | Metadata preview, category chips, reminder suggestion. |
| Queue | Browse smart queue. | Collapsing header, cards, filters, batch actions. |
| Reader | Consume saved content. | Clean content, progress bar, reader settings. |
| Groups | Manage workspaces. | Group list, create group, activity summary. |
| Task list | Coordinate work. | Task cards, assignees, due chips, create task FAB. |
| Alarm creator | Schedule shared alarms. | Time picker, group selector, recipients. |
| Alarm received | Critical full-screen alarm. | Large title/time, dismiss/snooze actions. |
| Insights | Show progress. | Streak, badges, weekly story. |

## 7. API and Integration Specifications

### 7.1 Firebase Authentication

Purpose: user login, guest upgrade, auth session management.

| Item | Specification |
|---|---|
| SDK | Firebase Auth Flutter SDK |
| Auth | Google OAuth credential exchanged through Firebase Auth |
| Request | Google provider token or anonymous/guest migration flow |
| Response | Firebase user, UID, ID token managed by SDK |
| Errors | User cancelled, network failure, account disabled, provider failure |

Example client flow:

```json
{
  "provider": "google.com",
  "result": {
    "uid": "abc123",
    "email": "user@example.com",
    "displayName": "User Name"
  }
}
```

### 7.2 Firebase Firestore

Purpose: cloud database, real-time sync, collaborative tasks, groups, alarms.

| Operation | Method | Endpoint Shape |
|---|---|---|
| Create saved item | POST | `/databases/default/documents/users/{uid}/items` |
| Read saved items | GET | `/databases/default/documents/users/{uid}/items` |
| Update saved item | PATCH | `/databases/default/documents/users/{uid}/items/{itemId}` |
| Delete saved item | DELETE | `/databases/default/documents/users/{uid}/items/{itemId}` |
| Create group task | POST | `/databases/default/documents/groups/{groupId}/tasks` |
| Update alarm | PATCH | `/databases/default/documents/groups/{groupId}/alarms/{alarmId}` |

Example saved item payload:

```json
{
  "title": "How to design offline-first apps",
  "url": "https://example.com/offline-first",
  "category": "article",
  "tags": ["architecture"],
  "readTimeMinutes": 8,
  "isCompleted": false,
  "isArchived": false,
  "updatedAt": "serverTimestamp"
}
```

Error responses:

- Permission denied: show access or login message.
- Unavailable: write locally, retry.
- Invalid argument: show validation error and log developer issue.

### 7.3 Firebase Cloud Messaging

Purpose: reminders, shared alarms, task assignment, group activity, invites.

Server sends:

```json
{
  "token": "recipient-fcm-token",
  "notification": {
    "title": "Team standup",
    "body": "Alex set a shared alarm"
  },
  "data": {
    "type": "shared_alarm",
    "groupId": "group_123",
    "alarmId": "alarm_456",
    "deepLink": "remind://groups/group_123/alarms/alarm_456"
  }
}
```

Client behavior:

- Foreground: show in-app banner or full-screen alarm when critical.
- Background: Android notification opens deep link.
- Failed token: Cloud Function removes invalid token after repeated failures.

### 7.4 Firebase Storage

Purpose: article thumbnails, user avatars, generated quote cards.

| Operation | Method | Endpoint Shape |
|---|---|---|
| Upload | POST/PUT | `/bucket/{path}` through Firebase Storage SDK |
| Download | GET | HTTPS download URL from SDK |
| Delete | DELETE | `/bucket/{path}` |

Example paths:

```text
users/{uid}/avatars/profile.jpg
users/{uid}/items/{itemId}/thumbnail.jpg
groups/{groupId}/assets/{assetId}.jpg
```

### 7.5 Firebase Cloud Functions

Purpose: server-side triggers, scheduled jobs, secure notification fan-out.

| Trigger | Input | Output |
|---|---|---|
| Daily digest at 8 AM | User preferences and item/task counts | FCM notification with deep link. |
| Shared alarm schedule | Due alarm document | FCM to all recipients and delivery log. |
| Cleanup archived items | Archived item older than retention window | Delete Firestore record and Storage assets. |
| Group invite | Invite document or callable request | Invite notification/link. |
| RevenueCat webhook | Entitlement event | Update user plan. |

### 7.6 Google ML Kit (Optional Phase 2+)

Purpose: on-device entity extraction for natural time parsing such as "tomorrow 2pm".

| Item | Specification |
|---|---|
| Endpoint | On-device ML Kit library, no network endpoint required |
| Request | Raw text input from reminder field |
| Response | Structured date/time candidates |
| Errors | Unsupported language, no entity found |

### 7.7 RevenueCat

Purpose: subscription management for Pro and Family tiers.

| Operation | Method | Endpoint |
|---|---|---|
| Check subscriber | GET | `/v1/subscribers/{app_user_id}` |
| Restore/sync purchases | POST | `/v1/subscribers/{app_user_id}` |

Example entitlement response:

```json
{
  "isProSubscriber": true,
  "entitlements": ["pro", "family"],
  "expiresAt": "2026-07-04T00:00:00Z"
}
```

### 7.8 OpenAI API (Optional Phase 2+)

Purpose: optional article summaries or key takeaways after privacy review and explicit user consent.

Recommended current endpoint: OpenAI Responses API, `POST https://api.openai.com/v1/responses`. The official API reference describes this endpoint as the advanced interface for generating model responses with text and image inputs and optional tools.

Request example:

```json
{
  "model": "gpt-5.1",
  "instructions": "Summarize saved articles in a concise, privacy-conscious style.",
  "input": "Article text selected by the user for summarization."
}
```

Response shape:

```json
{
  "id": "resp_abc123",
  "output_text": "A concise summary appears here."
}
```

Security requirements:

- Do not call OpenAI from the mobile client with a raw API key.
- Route requests through a Cloud Function.
- Require explicit user action before sending article content.
- Store generated summaries separately with `generatedAt`, `model`, and consent metadata.

Reference: OpenAI Responses API docs at `https://platform.openai.com/docs/api-reference/responses/create`.

## 8. State Management Pattern

### Provider Organization

Use Riverpod providers by feature:

```text
features/save/presentation/save_controller.dart
features/queue/presentation/queue_providers.dart
features/groups/presentation/group_providers.dart
features/tasks/presentation/task_controller.dart
features/alarms/presentation/alarm_controller.dart
```

Provider types:

- `Provider`: pure services and repositories.
- `FutureProvider`: one-time async loads.
- `StreamProvider`: Firestore listeners and connectivity.
- `NotifierProvider` or `AsyncNotifierProvider`: screens with commands and state transitions.
- `StateProvider`: small local UI state only when a controller would be unnecessary.

### Async State

Every async screen should handle:

| State | UI |
|---|---|
| Loading from empty | Skeleton matching final layout. |
| Loading with cache | Show cached content plus small sync indicator. |
| Loaded | Full content. |
| Error recoverable | Keep cached content and show retry banner. |
| Error blocking | Empty/error state with retry and support link. |

### Global State

| State | Owner |
|---|---|
| Current auth user | `authStateProvider` |
| Current app environment | `appEnvironmentProvider` |
| Current active group | `activeGroupProvider` |
| Connectivity | `connectivityProvider` |
| Notification route intent | `notificationRouterProvider` |
| Subscription entitlement | `entitlementProvider` |

### Local UI State

Form inputs, toggles, tab selection, and temporary bottom-sheet state should stay local to widgets or screen controllers. Persist only user preferences that should survive app restarts.

## 9. Accessibility

- Minimum 44dp touch targets.
- Semantic labels on every icon button.
- All alarm actions readable by screen readers.
- Respect reduce-motion settings.
- Text contrast meets WCAG AA in normal states and AAA where practical in critical states.
- Do not rely on color alone for task priority, sync state, or errors.

## 10. Motion

| Interaction | Motion |
|---|---|
| Button press | Scale to 0.96 with spring. |
| Card tap | Slight scale and elevation change. |
| Save action | Sheet compresses, item flies to queue tile. |
| FAB expand | Spring expansion with staggered actions. |
| Task complete | Checkbox morph and small completion flash. |
| Alarm ringing | High-contrast full-screen pulse, respects reduce motion. |
| Page transition | Slide and fade through GoRouter custom transition. |

Use haptics for save, complete, long press, alarm dismiss, and critical alerts.
