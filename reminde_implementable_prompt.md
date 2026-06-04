# Reminde — Implementable Product Prompt
**Version 3.0 | Read-It-Later + Collaborative Tasks + Shared Alarms (Full MVP)**

---

## WHAT CHANGED (v2.0 → v3.0)

**ADDED (Full Collaboration Features):**
- ✅ **Remote Shared Alarms** — Set alarms that ring on team member's phones (cross-device FCM)
- ✅ **Collaborative Group Tasks** — Create shared task lists, sync with family/team in real-time
- ✅ **Family/Team Coordination** — Group management, permissions, shared workspaces
- ✅ **New Shared Collections** — Alarms collection, Tasks collection, Groups collection in Firestore
- ✅ **Group Management UI** — Create groups, invite members, manage roles

**Timeline Impact:** Phase 1 extended from **6 weeks → 9-10 weeks** (due to collaborative backend complexity).

---

## WHAT CHANGED (v1.0 → v2.0)

**REMOVED (Too Complex / Not Implementable for MVP):**
- ❌ On-device TensorFlow Lite models (text summarization, key-takeaway extraction) — requires custom ML training
- ❌ Geofencing/location-based reminders — battery-draining, high false-positive rates, <5% user adoption
- ❌ Camera QR/OCR link extraction — flaky in production, requires complex post-processing
- ❌ Bionic Reading Mode — nice-to-have, adds complexity without user value
- ❌ TTS narration — complex audio focus management, not essential for MVP
- ❌ Android Auto integration — requires physical hardware testing, ~1% user base
- ❌ Wear OS companion app — separate platform, BLE sync complexity, <2% user base
- ❌ Live Folder (Pixel) — device-specific, minimal impact
- ❌ Public profiles & Discovery Feed — requires content moderation infrastructure
- ❌ Full CRDT sync protocol — complex multi-device conflict resolution; simple timestamps suffice for MVP
- ❌ Price Drop Alerts — web scraping legal issues, fragile across updates
- ❌ Export integrations (Notion, Obsidian, Readwise) — each requires separate API maintenance

**SIMPLIFIED:**
- ✅ Content categorization: Simple regex + keyword matching (not ML)
- ✅ Reminders: Time-based, behavior-based, and recurring only (no geofencing, no event-based)
- ✅ Reader AI: Web search only (no complex explanations or translations)
- ✅ Shared Spaces: Collaborative reading, but no public discovery
- ✅ Sync: Last-write-wins timestamps instead of full CRDT
- ✅ Natural Language Parsing: Simple regex only (not ML entity extraction)

**KEPT (Core MVP):**
- ✅ Authentication (Firebase + Google Sign-In)
- ✅ Save system (URL, clipboard, share intent)
- ✅ Smart Queues with sorting logic
- ✅ Offline-first architecture (Hive + Firestore)
- ✅ Reader experience with customization
- ✅ Reading streaks & badges
- ✅ Home screen widgets
- ✅ Shareable quote cards
- ✅ Material 3 design with dynamic colors
- ✅ Push notifications

**Result:** MVP scope reduced from ~24 weeks to **16 weeks** (still high-quality product, launches faster, lower technical risk).

---

## ROLE & MISSION

You are building **Reminde**, a next-generation read-it-later + collaborative task management Android application. The core mission: **solve save-and-forget behavior** AND **enable seamless family/team coordination**.

Reminde solves two problems:
1. **Personal:** Users save content but never return (solved via smart queues, reminders, streaks)
2. **Collaborative:** Families/teams struggle to coordinate tasks, alarms, and shared information (solved via shared task lists, cross-device alarms, group workspaces)

The application combines on-device AI, dynamic queuing, context-aware reminders, **collaborative features, family coordination**, gamification, and Material You design into a single cohesive product. Build it as an **Android-first Flutter application** following Clean Architecture with Riverpod state management.

---

## CONTEXT & MARKET OPPORTUNITY

- **Pocket (Mozilla)** shut down July 8, 2025 → 17 million users displaced
- **Omnivore** (500k users) was killed in November 2024 after ElevenLabs acqui-hire
- **Matter** (best active competitor) is iOS-only — no native Android app exists
- **Instapaper, Raindrop.io, Readwise Reader, Wallabag** all have significant gaps
- This is the single largest market entry opportunity in read-it-later history

**Target users (Personal):** Android power users, displaced Pocket/Omnivore users, productivity enthusiasts, students, knowledge workers.

**Target users (Collaboration):** Families (household coordination), small teams (project coordination), roommates (shared chores), couples (shared goals).

---

## TECHNOLOGY STACK (MVP)

| Layer | Technology |
|---|---|
| Framework | Flutter (latest stable) |
| State Management | Riverpod with code generation (`riverpod_generator`) |
| Navigation | GoRouter (nested nav, deep links) |
| Authentication | Firebase Auth (Google Sign-In + Guest mode) |
| Backend | Firebase Cloud Functions (serverless) |
| Cloud Database | Firebase Firestore (real-time sync + offline persistence) |
| Push Notifications | Firebase Cloud Messaging (FCM) |
| File Storage | Firebase Storage (thumbnails, CDN delivery) |
| Local Database | Hive + SharedPreferences (offline-first, instant startup) |
| Background Tasks | Android WorkManager (battery-optimized, Doze-compatible) |
| Animations | Lottie (`lottie` package), Flutter animations, spring physics |
| Video Embeds | `youtube_player_flutter` |
| Widgets | `home_widget` + Android Glance |
| Content Extraction | `flutter_readability` or custom HTML extractor |

**Note:** TensorFlow Lite, ML Kit, and Text-to-Speech are deferred to Phase 2 (Phase 1 uses simple regex/keyword categorization).

---

## PROJECT ARCHITECTURE (Clean Architecture, Feature-First)

```
lib/
├── core/
│   ├── firebase/          # Firebase service wrappers
│   ├── notifications/     # FCM notification management
│   ├── extraction/        # Content/article extraction services
│   ├── sync/              # CRDT sync logic + WorkManager bridge
│   ├── theme/             # Material You dynamic color + design tokens
│   ├── utils/             # Extension methods, animation presets, helpers
│   └── constants/         # App-wide constants
│
├── features/
│   ├── auth/
│   │   ├── data/          # Firebase Auth repo
│   │   ├── domain/        # Auth use cases
│   │   └── presentation/  # Login screen, onboarding
│   ├── home/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/  # Hero home screen, queue carousel, pending tasks/alarms
│   ├── save/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/  # Save sheet, clipboard detection
│   ├── queue/
│   │   ├── data/
│   │   ├── domain/        # Smart Queue Engine use cases
│   │   └── presentation/  # Queue views, list, batch actions
│   ├── reader/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/  # Immersive reader, focus mode
│   ├── reminder/
│   │   ├── data/
│   │   ├── domain/        # Time/behavior/recurring reminders
│   │   └── presentation/  # Reminder picker
│   ├── tasks/                 # NEW FEATURE
│   │   ├── data/          # Tasks repository, Firestore queries
│   │   ├── domain/        # Task creation, completion, assignment use cases
│   │   └── presentation/  # Task list views, task editor, collaborative sync UI
│   ├── alarms/                # NEW FEATURE
│   │   ├── data/          # Alarms repository, FCM delivery
│   │   ├── domain/        # Shared alarm scheduling, cross-device trigger
│   │   └── presentation/  # Alarm creator, team alarm view, received alarms
│   ├── groups/                # NEW FEATURE
│   │   ├── data/          # Groups repository, member management
│   │   ├── domain/        # Group creation, invites, role management
│   │   └── presentation/  # Group settings, member list, invite UI
│   ├── social/
│   │   ├── data/
│   │   ├── domain/        # Shared Spaces use cases
│   │   └── presentation/  # Shared spaces UI, quote cards
│   ├── gamification/
│   │   ├── data/
│   │   ├── domain/        # Streak tracking, badge logic, insights
│   │   └── presentation/  # Streak widget, badge gallery, insight stories
│   ├── search/
│   ├── insights/
│   ├── profile/
│   └── settings/
```

---

## FEATURE SPECIFICATIONS

### 1. ONBOARDING & AUTHENTICATION

**Splash Screen:**
- Animated Lottie logo: half-open bookmark shape morphing into a glowing orb
- Tagline: *"Save now. Actually come back later."*
- Spring physics animation

**Onboarding (3 screens):**
- Screen 1: Intelligent saving (Lottie: link flying into a smart inbox)
- Screen 2: Smart queuing (Lottie: cards self-organizing by time-of-day)
- Screen 3: Joyful reading (Lottie: book opening with glowing particles)
- Spring-animated progress indicator, skip button always visible

**Auth Screen:**
- Primary: Google Sign-In (large, animated button)
- Secondary: "Continue as Guest" → full offline mode, seamless account migration later
- Glassmorphism card styling with frosted background
- Haptic feedback on every tap

---

### 2. HOME: THE INTELLIGENT HERO SURFACE (BENTO GRID LAYOUT)

**Visual Design:**
- Full-width animated gradient background (custom Flutter painter with floating particles)
- Gradient shifts hue by time-of-day: dawn (warm amber) → day (cool blue) → dusk (deep orange) → night (deep indigo)
- No traditional top app bar

**Dynamic Greeting:**
- `"Good evening, [Name]"` 
- Contextual headline that morphs every few seconds (smooth text crossfade):
  - `"You have 3 articles waiting for tonight"`
  - `"Weekend learning queue is ready"`
  - `"3 long-forgotten articles miss you"`

**Bento Grid Home Hub (Instead of Carousel):**
- **Grid Layout:** Adaptive 2-column grid on phones, 3-column on tablets (using Flutter's `GridView`)
- **Grid Items (in suggested order):**
  1. **Reading Streak Widget** (2×2 size) — Prominent streak count + daily completion ring + heatmap for last 30 days
  2. **Tonight Queue** (2×1 size) — Next article title + thumbnail + estimated read time + tap to open
  3. **Create Task Tile** (1×1 size) — Quick action button to create new task in default group
  4. **Set Alarm Tile** (1×1 size) — Quick action button to set shared alarm
  5. **Weekend Queue** (2×1 size) — Weekend reading items preview
  6. **Group Activity Feed** (2×2 size) — Last 5 group events scrollable + tappable
  7. **Forgotten Queue** (2×1 size) — Items rescued this week counter + tap to open
  8. **Recent Badges** (2×1 size) — New badges earned this week, shareable
  9. **Continue Reading Queue** (1×1 size) — Progress ring + next article to resume

- **Bento Spacing:** 12dp gaps between tiles, 16dp edge padding
- **Tile Styling:** Each tile uses Material 3 base cards with soft shadows + generous border radius (16dp)
- **Tap Interactions:** Tile taps navigate to relevant screen (queue, group, etc.)

**Floating Quick-Save FAB:**
- Expandable speed-dial (Material 3 FAB)
- Options: URL Paste, Create Task, Set Shared Alarm, Voice Note
- On save: FAB morphs into a ✓ tick with haptic bump + flight animation to relevant grid tile
- On task create: "Task added to [Group Name]" toast
- FAB positioned bottom-right, floats above grid content

---

### 3. ADVANCED SAVE SYSTEM

**Save Entry Points:**

| Method | Behavior |
|---|---|
| Android Share Intent | Opens glassmorphism bottom sheet with auto-extracted metadata |
| Clipboard Detection | Non-intrusive banner when clipboard contains URL → one-tap save |
| FAB → URL Paste | Direct URL input with metadata fetch preview |

**Save Bottom Sheet (glassmorphism):**
- Auto-filled: title (editable), thumbnail, source icon/favicon
- Category suggestion chips (auto-detected): Article, Video, Product, Recipe, Learning, Social Post
- Tag input with autocomplete from user's existing tags
- Intelligent reminder suggestion: suggests optimal time based on content type + user behavior history
- Save button → shrink animation + haptic bump + item flight path to queue

**Background Content Enrichment (runs in isolate, non-blocking):**
- Articles: Open Graph fetch, estimated read time calculation
- Videos: oEmbed thumbnail + duration retrieval
- Products: Price + image extraction (Amazon, Flipkart)
- All enrichment tagged with `offlineCached: true` once complete

---

### 4. SMART QUEUE ENGINE

The core intelligence layer. Queues are **dynamic**, **self-organizing**, and **continuously re-sorted**.

| Queue | Population Rule | Re-sort Logic |
|---|---|---|
| Tonight | Evening reminder OR saved after 6pm | Sort by reminder time |
| Weekend | Saturday/Sunday flag | Re-sort Friday evening |
| Forgotten | Saved >7 days, never opened | Oldest first; weekly nudge |
| Continue Reading | Progress 30–99% | Sort by last opened |
| Watch Later | YouTube/Vimeo URLs | Sort by video duration |
| Buy Later | Product URLs (Amazon/Flipkart) | Sort by price drop alert priority |
| Learning | Tagged as learning/course | Sort by reminder schedule |
| Recently Saved | All items, last 48h | Auto-age out after 48h |

**All sorting runs on-device — no cloud computation.**

**Queue View UI:**
- Collapsing parallax header
- Shimmer skeleton loading states (exact card-shaped)
- Pull-to-refresh
- Swipe actions: complete (right), archive (left) with elastic resistance + snap
- Long press: lifts card with increased shadow + haptic → enters multi-select mode
- Batch actions: Archive All, Remind All, Mark All Complete

**Daily Digest Notification (FCM):**
- User-configurable time (default: 8am)
- Message: `"You have 4 articles and 2 videos to enjoy today"`
- Deep link → opens most relevant queue directly

---

### 5. CONTEXT-AWARE REMINDER ENGINE

**Three Reminder Types:**

**5a. Time-Based**
- Presets: Tonight, Tomorrow AM, Weekend, Custom
- Custom: Material 3 date + time picker (bottom sheet)
- Confirmation chip with parsed time + haptic feedback

**5b. Behavior-Based (Soft Scheduling)**
- User defines time blocks: "After work" (weekdays 6–8pm), "Gym time", "Evening study"
- App learns patterns from open behavior over 14 days and adjusts suggestions

**5c. Simple Recurring Reminders**
- User can set weekly recurring reminders
- E.g., "Every Saturday 10am" or "Every evening at 6pm"
- Powered by WorkManager + FCM scheduling

---

### 6. IMMERSIVE READER EXPERIENCE

**Reader View:**
- Full-screen, distraction-free
- Content fetched via readability extractor → clean HTML rendered in WebView with custom CSS
- Fallback: in-app browser if extraction fails
- Estimated read time badge (top right)
- Live animated reading progress bar (thin line at top)

**Customization Panel (bottom sheet):**
- Text size slider
- Font selector: Serif (Georgia) / Sans-serif (custom)
- Theme: Light / Dark / Sepia
- Line spacing toggle

**Annotations:**
- Drag-to-select text → highlight
- Highlight colors: yellow, blue, pink, green
- Attach note to any highlight
- All highlights saved locally (Hive) and synced to Firestore

**Advanced Reader Modes:**
- **Focus Reader Mode (RSVP):** Words displayed one-by-one in screen center at adjustable WPM

**Video Content:**
- YouTube/Vimeo embeds via `youtube_player_flutter`
- Minimal controls
- Picture-in-picture support

**Reader Completion:**
- Confetti burst animation on article completion
- "Mark as Complete" bottom button animates to ✓
- Triggers streak increment

**In-Reader Utilities:**
- Web search selected text
- Generate shareable quote card (gradient background, auto-Reminde watermark)

---

### 7. COLLABORATIVE FEATURES: TASKS, ALARMS & FAMILY COORDINATION

**7a. Collaborative Task Lists**

**Create a Group (New Feature):**
- Tap "+" button → "Create Group"
- Enter group name: "Family Chores", "Project Beta", "Roommate Tasks"
- Invite members: email input + "Send Invite" button
- Invitees receive FCM notification: "[User] invited you to Family Chores"
- Deep link: tapping notification joins group instantly
- Group created with simple role: Admin (creator) / Member

**Group Task List View:**
- Shows all shared tasks for the group
- Columns: Task title, Assigned To, Due Date, Status (Pending/Complete)
- Swipe actions: Complete (right) / Assign to Me (left)
- Tap task → opens task detail:
  - Title, description, due date, assigned member
  - Comments thread (lightweight)
  - Mark complete button
- Add new task: FAB → "New Task" → input title/description/assign to member/due date
- Real-time sync: if another member completes a task, status updates instantly on all devices

**Task Notifications:**
- When task assigned to you: `"[User] assigned you 'Buy groceries' in Family Chores"`
- When task marked complete: `"[User] completed 'Buy groceries'"`
- Daily digest for pending tasks: Sunday 8am `"You have 3 tasks waiting in Family Chores"`

**Data Model:**
```
groups/{groupId}/
  ├── name: string
  ├── createdBy: uid
  ├── members: { uid: role } (role: "admin" | "member")
  ├── createdAt: timestamp
  └── tasks/{taskId}/
        title: string
        description: string
        assignedTo: uid
        createdBy: uid
        dueDate: timestamp
        isCompleted: bool
        completedAt: timestamp
        completedBy: uid
        comments: [{ uid, text, timestamp }]
        createdAt: timestamp
        updatedAt: timestamp
```

---

**7b. Shared Alarms (Remote Alarm Delivery)**

**Create a Shared Alarm:**
- Long-press home screen or tap "Set Alarm" from group view
- Bottom sheet: "Create Shared Alarm"
- Inputs:
  - Title: "Team standup" / "Mom's medication"
  - Time: Material 3 time picker
  - Group: Dropdown select which group to send to
  - Repeat: Once / Daily / Weekly / Custom
  - Message: Optional text to display on alarm
- Submit → Alarm created in Firestore

**Alarm Received on Team Member Devices:**
- Alarm rings on recipient's device (even if phone is locked)
- Full-screen alarm UI:
  - Alarm title: "Team standup"
  - Who set it: "[User] wants everyone together"
  - Dismiss / Snooze buttons
  - Haptic + audio alert (respects phone volume/DND)
- Recipient taps "Dismiss" → updates Firestore (acknowledged)
- Receiver can tap "Acknowledge All" → marks alarm as dismissed for everyone

**Alarm History:**
- Group view shows recent alarms: "Team standup - 9am daily - Last sent 10min ago"
- Can see who dismissed it: "[User1] ✓ dismissed, [User2] ⏱ snoozed"

**Data Model:**
```
groups/{groupId}/alarms/{alarmId}/
  ├── title: string
  ├── message: string
  ├── createdBy: uid
  ├── scheduledTime: timestamp (ISO 8601 or HH:MM)
  ├── repeat: enum ["once", "daily", "weekly", "custom"]
  ├── repeatDays: int[] (0-6 for weekly)
  ├── recipients: uid[]
  ├── status: enum ["scheduled", "sent", "completed"]
  ├── dismissals: { uid: timestamp } (tracks who dismissed)
  ├── createdAt: timestamp
  └── lastTriggeredAt: timestamp
```

**Backend Logic (Cloud Function):**
- WorkManager-triggered Cloud Function runs daily at 5am
- Queries all alarms with today's scheduled time
- For each alarm, sends FCM notification to all group members
- Updates `lastTriggeredAt` timestamp

---

**7c. Family/Team Coordination Hub**

**New Tab: "Groups" (Bottom navigation)**
- Shows all groups user is member of
- Each group card displays:
  - Group name
  - Member count + avatars
  - Pending tasks count
  - Next scheduled alarm (if any)
  - Tap to open full group workspace

**Group Workspace View (Tabbed):**
- **Tab 1: Tasks** — shared task list (as described above)
- **Tab 2: Alarms** — alarm history + create new alarm
- **Tab 3: Members** — list of group members + invite button
- **Tab 4: Settings** — (Admin only) group name edit, member removal, group deletion

**Member Management:**
- Admin can remove members: tap member → "Remove from group"
- Admin can change member role (Member → Admin) — future feature
- Invite members: tap "+" → email input → send FCM invite link
- Member removal: deleted member loses access instantly (real-time)

**Group Sharing:**
- Invite link: `reminde://join-group/{groupId}/{inviteToken}`
- Copying invite link: `"Invite link copied to clipboard"`
- Share button: sends via WhatsApp, Email, etc.

**Notifications Dashboard (New):**
- Home screen section: "Group Activity"
- Shows last 5 events: "[User] completed 'Buy groceries'", "[User] set alarm 'Meeting at 2pm'"
- Each event is timestamped and tappable (opens relevant group)

**Data Model for Groups:**
```
groups/{groupId}/
  ├── name: string
  ├── createdBy: uid
  ├── members: { uid: role }  # role: "admin" | "member"
  ├── createdAt: timestamp
  ├── updatedAt: timestamp
  └── lastActivityAt: timestamp

users/{uid}/groups/
  ├── groupId: timestamp (for sorting)
  # Denormalized for faster queries
```

---

### 8. COLLABORATIVE FEATURES: TASKS, ALARMS & FAMILY COORDINATION

**8a. Collaborative Task Lists**

**Create a Group (New Feature):**
- Tap "+" button → "Create Group"
- Enter group name: "Family Chores", "Project Beta", "Roommate Tasks"
- Invite members: email input + "Send Invite" button
- Invitees receive FCM notification: "[User] invited you to Family Chores"
- Deep link: tapping notification joins group instantly
- Group created with simple role: Admin (creator) / Member

**Group Task List View:**
- Shows all shared tasks for the group
- Columns: Task title, Assigned To, Due Date, Status (Pending/Complete)
- Swipe actions: Complete (right) / Assign to Me (left)
- Tap task → opens task detail:
  - Title, description, due date, assigned member
  - Comments thread (lightweight)
  - Mark complete button
- Add new task: FAB → "New Task" → input title/description/assign to member/due date
- Real-time sync: if another member completes a task, status updates instantly on all devices

**Task Notifications:**
- When task assigned to you: `"[User] assigned you 'Buy groceries' in Family Chores"`
- When task marked complete: `"[User] completed 'Buy groceries'"`
- Daily digest for pending tasks: Sunday 8am `"You have 3 tasks waiting in Family Chores"`

**Data Model:**
```
groups/{groupId}/
  ├── name: string
  ├── createdBy: uid
  ├── members: { uid: role } (role: "admin" | "member")
  ├── createdAt: timestamp
  └── tasks/{taskId}/
        title: string
        description: string
        assignedTo: uid
        createdBy: uid
        dueDate: timestamp
        isCompleted: bool
        completedAt: timestamp
        completedBy: uid
        comments: [{ uid, text, timestamp }]
        createdAt: timestamp
        updatedAt: timestamp
```

---

**8b. Shared Alarms (Remote Alarm Delivery)**

**Create a Shared Alarm:**
- Long-press home screen or tap "Set Alarm" from group view
- Bottom sheet: "Create Shared Alarm"
- Inputs:
  - Title: "Team standup" / "Mom's medication"
  - Time: Material 3 time picker
  - Group: Dropdown select which group to send to
  - Repeat: Once / Daily / Weekly / Custom
  - Message: Optional text to display on alarm
- Submit → Alarm created in Firestore

**Alarm Received on Team Member Devices:**
- Alarm rings on recipient's device (even if phone is locked)
- Full-screen alarm UI:
  - Alarm title: "Team standup"
  - Who set it: "[User] wants everyone together"
  - Dismiss / Snooze buttons
  - Haptic + audio alert (respects phone volume/DND)
- Recipient taps "Dismiss" → updates Firestore (acknowledged)
- Receiver can tap "Acknowledge All" → marks alarm as dismissed for everyone

**Alarm History:**
- Group view shows recent alarms: "Team standup - 9am daily - Last sent 10min ago"
- Can see who dismissed it: "[User1] ✓ dismissed, [User2] ⏱ snoozed"

**Data Model:**
```
groups/{groupId}/alarms/{alarmId}/
  ├── title: string
  ├── message: string
  ├── createdBy: uid
  ├── scheduledTime: timestamp (ISO 8601 or HH:MM)
  ├── repeat: enum ["once", "daily", "weekly", "custom"]
  ├── repeatDays: int[] (0-6 for weekly)
  ├── recipients: uid[]
  ├── status: enum ["scheduled", "sent", "completed"]
  ├── dismissals: { uid: timestamp } (tracks who dismissed)
  ├── createdAt: timestamp
  └── lastTriggeredAt: timestamp
```

**Backend Logic (Cloud Function):**
- WorkManager-triggered Cloud Function runs daily at 5am
- Queries all alarms with today's scheduled time
- For each alarm, sends FCM notification to all group members
- Updates `lastTriggeredAt` timestamp

---

**8c. Family/Team Coordination Hub**

**New Tab: "Groups" (Bottom navigation)**
- Shows all groups user is member of
- Each group card displays:
  - Group name
  - Member count + avatars
  - Pending tasks count
  - Next scheduled alarm (if any)
  - Tap to open full group workspace

**Group Workspace View (Tabbed):**
- **Tab 1: Tasks** — shared task list (as described above)
- **Tab 2: Alarms** — alarm history + create new alarm
- **Tab 3: Members** — list of group members + invite button
- **Tab 4: Settings** — (Admin only) group name edit, member removal, group deletion

**Member Management:**
- Admin can remove members: tap member → "Remove from group"
- Admin can change member role (Member → Admin) — future feature
- Invite members: tap "+" → email input → send FCM invite link
- Member removal: deleted member loses access instantly (real-time)

**Group Sharing:**
- Invite link: `reminde://join-group/{groupId}/{inviteToken}`
- Copying invite link: `"Invite link copied to clipboard"`
- Share button: sends via WhatsApp, Email, etc.

**Notifications Dashboard (New):**
- Home screen section: "Group Activity"
- Shows last 5 events: "[User] completed 'Buy groceries'", "[User] set alarm 'Meeting at 2pm'"
- Each event is timestamped and tappable (opens relevant group)

**Data Model for Groups:**
```
groups/{groupId}/
  ├── name: string
  ├── createdBy: uid
  ├── members: { uid: role }  # role: "admin" | "member"
  ├── createdAt: timestamp
  ├── updatedAt: timestamp
  └── lastActivityAt: timestamp

users/{uid}/groups/
  ├── groupId: timestamp (for sorting)
  # Denormalized for faster queries
```

---

### 9. CONTENT INTELLIGENCE (SIMPLIFIED)

**7a. Content Categorization**
- Simple regex + keyword matching for categories
- Categories: article, video, product, social post, recipe, learning, note
- Runs at save time in background isolate
- Alternative: Optional cloud API call (Google Cloud Natural Language)

**7b. Auto-Summarization (Deferred)**
- Deferred to Phase 2 or Pro feature (requires trained ML model or expensive cloud API)
- Currently: Use OpenAI API if user provides API key (Pro feature)

**7c. Natural Language Reminder Parsing**
- Simple regex patterns only: `"tomorrow"`, `"next Saturday"`, `"in 3 hours"`
- Returns structured { date, time } with confidence score
- Fallback to manual picker if parsing fails

**9c. Intent-Based Queueing**
- Recipe saved → auto-assigned to "Weekend" queue
- YouTube link → auto-assigned to "Watch Later" + video duration-based reminder suggestion
- Product link → auto-assigned to "Buy Later" queue

---

### 10. COLLABORATIVE FEATURES (MVP)

**8a. Shared Spaces**
- Create collaborative reading environments with invited users
- Save items to a shared space → visible to all members
- Comment on items (threaded, lightweight)
- React with emoji: 🔥, 💡, 👏
- Shared queue — members can suggest reading order
- Invite via deep link

**8b. Shareable Quote Cards**
- Auto-generated from any highlighted text in reader
- Beautiful gradient backgrounds (6 preset palettes)
- Auto-watermarked with Reminde logo (subtle, bottom right)
- Share directly to Instagram, WhatsApp, etc.

**Note:** Public profiles and Discovery Feed are deferred to Phase 2 (require content moderation infrastructure).

---

### 11. GAMIFICATION & RETENTION MECHANICS

**9a. Reading Streaks**
- Tracks consecutive days with ≥1 item completed
- Visual ring animation fills as streak grows
- Streak milestone celebrations: 7, 30, 100, 365 days (confetti + unique badge)
- **Streak Freeze:** Available once per month for free users (unlimited for Pro)
- Streak displayed prominently on home screen and profile

**9b. Badge System**
- Beautiful, shareable mini-illustration badges (designed, not auto-generated)
- Initial badge set:

| Badge | Trigger |
|---|---|
| Night Owl | Completed article after 10pm |
| Weekend Warrior | Completed entire Weekend queue |
| Tag Master | Used 10+ unique tags |
| Speed Reader | Completed 5 articles in one day |
| Curator | Shared 3+ public reading lists |
| Memory Keeper | Rescued 5 Forgotten items |
| Early Bird | Completed article before 7am |

- Badges displayed in profile, shareable as images

**9c. Weekly Insight Stories (Instagram-style)**
- Auto-generated every Sunday evening
- Slides: Total items read, Total reading time, Longest streak, Top category, Top tag, Best reading day
- Beautiful data visualizations (animated charts, progress rings)
- "Share Story" → saves as image for social media posting
- This is the primary organic acquisition channel

**9d. Forgotten Rescue Missions**
- Weekly notification (Monday morning): `"3 long-lost articles miss you 👀"`
- Opens dedicated Forgotten queue with special "Rescue Mission" UI
- Playful animations, personality-driven microcopy
- Option: Read Now / Archive Forever / Snooze 1 Week

---

### 12. DESIGN SYSTEM & MICRO-INTERACTIONS (HYBRID MATERIAL 3 + NEO-BRUTALISM)

**Visual Language: Hybrid Approach**

Reminde uses a **Hybrid Design System** that maximizes Material 3's strengths while injecting Neo-Brutalist energy for action states:

**Foundation (Material 3 Engine):**
- Maintain Material 3's excellent accessibility, typography, and layout structure
- Use Material 3's component library for consistency and platform integration
- Layered depth, soft shadows, subtle glow effects
- Dynamic type scale (Material 3)
- Dark mode is first-class citizen
- Premium 24–32dp base grid
- Generous rounded corners: 16–24dp
- Full dynamic color theming from Android 12+ wallpaper (`DynamicColorBuilder`)
- Predictive Back Gesture support (Android 14+)

**Enhancements (Bento Grid + Neo-Brutalism):**
- **Bento Grid Layout:** Home hub uses structured 2/3-column grid instead of vertical scrolling — creates visual hierarchy and discoverability
- **Neo-Brutalist Action States:** When an urgent interaction requires user attention:
  * **High-Contrast Containers:** Reminder due → high-contrast accent color fill (not soft Material 3 tones)
  * **Bold Borders:** Action buttons get 2dp borders in primary color when active
  * **Monochrome Accents:** Notifications and alerts drop to high-contrast black/white + accent color combo
  * **Strong Typography:** Action labels get bolder weight (Material 3 Bold instead of Regular)
  * **Visual Urgency:** Use negative space to isolate important actions (e.g., "Alarm ringing NOW" gets full-screen alert UI with minimal surrounding elements)

**Example Application:**
- Normal state: Soft Material 3 card for reminder (light shadow, subtle color)
- Active state (reminder triggered): High-contrast background + 2dp bold border + large bold text + haptic pulse
- Completed state: Soft Material 3 fade-out with checkmark

**Color Palette with Brutalist Overrides:**
- Primary: Soft Material 3 color (from wallpaper or default)
- Primary Bold (Brutalist): High-contrast version for action states (darker/more saturated)
- Error: Bright red for deletions + mistakes (medium brightness)
- Error Brutalist: Full black/bright red combo for critical alerts
- Success: Soft green (Material 3)
- Success Brutalist: High-contrast green for completion celebrations
- Neutral backgrounds: Light/dark Material 3 tones
- Neutral Brutalist: Pure black or pure white for contrast overlays

**Micro-Interaction Specifications (Updated for Bento + Brutalism):**

| Interaction | Animation | Urgency Level |
|---|---|---|
| Button press | Scale to 0.96 + SpringSimulation + `HapticFeedback.lightImpact()` | Normal |
| Grid tile tap | Slight scale-up (1.02) + smooth navigation | Normal |
| Save action | Shrink-and-fade + item flies along curve to relevant grid tile | Normal |
| Archive swipe | Elastic resistance + snap animation at threshold | Normal |
| Long press | Card lifts (elevated shadow + 1.02 scale) + haptic + multi-select entry | Normal |
| Page transition | `CustomTransitionPage` with slide-and-fade | Normal |
| FAB expand | Spring physics expand with staggered child appearance | Normal |
| Completion | Confetti burst + haptic + streak increment animation | Normal |
| Scroll hero | Parallax floating elements (0.5x scroll multiplier) | Normal |
| Home background | Subtle particle animation (custom Flutter painter) | Normal |
| **Reminder Triggered** | Full-screen alert + bold high-contrast background + haptic triple pulse | **URGENT** |
| **Alarm Ringing** | Full-screen alarm UI + vibration pattern + high-contrast title/buttons | **CRITICAL** |
| **Task Assigned** | Toast with high-contrast accent + vibration + auto-dismiss after 4s | **Moderate** |
| **Streak at Risk** | Badge slides in bottom-right with bold border + subtle bounce | **Moderate** |
| **Offline State** | Persistent banner with high-contrast color + sync spinner | **Passive** |

**Skeleton Loading (Material 3 base + Bento grid-aware):**
- Every grid tile has exact-shape shimmer skeleton
- Skeleton matches tile height, border radius, element positions precisely
- Bento grid arrangement preserved during skeleton state (responsive columns maintained)

**Empty States (with Brutalist Overlay):**
- All empty states use Lottie animations
- Playful microcopy: `"Your reading queue awaits its first adventure"` 
- Direct CTA button in empty state with bold styling
- If truly critical (e.g., "Create your first group"), show high-contrast card with bold border

**Accessibility (Material 3 compliance):**
- `semanticsLabel` on all icon buttons
- `ExcludeSemantics` on decorative elements
- All animations respect `MediaQuery.reduceMotion`
- Minimum 44dp touch targets across all buttons and grid tiles
- High-contrast states tested for WCAG AAA compliance (critical for Neo-Brutalist action states)

**Responsive Grid Behavior:**
- Phone (320–600dp): 2-column bento grid
- Tablet (600+dp): 3-column bento grid
- Landscape (any width): 3–4 column grid
- Individual tile sizes adapt proportionally (2×2 tile stays 2:2 ratio)

---

### 13. TECHNICAL ARCHITECTURE DETAILS

**13a. Firestore Data Model (Updated for Collaboration)**

```
users/{uid}/
  ├── profile: { name, email, avatar, streakCount, streakLastDate, plan, createdAt }
  ├── preferences: { queueOrder, reminderDefaults, ttsSpeed, readerFont, theme, notificationChannels }
  ├── groups: { groupId: timestamp } (denormalized index for faster queries)
  └── items/{itemId}/
        title: string
        url: string
        thumbnail: string (Firebase Storage URL)
        category: enum [article|video|product|social|recipe|learning|note]
        tags: string[]
        description: string
        extractedContent: string (HTML/plain text)
        readTimeMinutes: int
        sourceDomain: string
        savedAt: timestamp
        reminder: { type, time, behaviorBlock }
        isCompleted: bool
        isArchived: bool
        readingProgress: float (0.0–1.0)
        lastOpenedAt: timestamp
        highlights: [{ id, text, note, position, color, updatedAt }]
        offlineCached: bool
        sharedSpaceId: string? (null if personal)

groups/{groupId}/
  ├── name: string
  ├── createdBy: uid
  ├── members: { uid: { role, joinedAt, displayName } } (role: "admin" | "member")
  ├── createdAt: timestamp
  ├── updatedAt: timestamp
  ├── lastActivityAt: timestamp
  └── tasks/{taskId}/
        title: string
        description: string
        assignedTo: uid
        createdBy: uid
        dueDate: timestamp (nullable)
        isCompleted: bool
        completedAt: timestamp (nullable)
        completedBy: uid (nullable)
        comments: [{ uid, displayName, text, timestamp }]
        priority: enum ["low" | "medium" | "high"]
        createdAt: timestamp
        updatedAt: timestamp

groups/{groupId}/alarms/{alarmId}/
  ├── title: string
  ├── message: string (optional)
  ├── createdBy: uid
  ├── scheduledTime: string (ISO 8601 or HH:MM format)
  ├── repeat: enum ["once" | "daily" | "weekly" | "custom"]
  ├── repeatDays: int[] (0-6 for weekly; empty for once/daily)
  ├── recipients: uid[]
  ├── status: enum ["scheduled" | "sent" | "completed"]
  ├── dismissals: { uid: timestamp } (tracks who dismissed)
  ├── createdAt: timestamp
  ├── lastTriggeredAt: timestamp (nullable)
  └── notificationSentAt: timestamp (nullable)
```

---

**13b. Offline-First Architecture (Group-Aware)

```
Read Path:  Hive (local) → instant display → Firestore update (background)
Write Path: Write to Hive immediately → queue Firestore write → WorkManager sync
Conflict:   Last-write-wins with timestamps for tasks/alarms
Offline:    Full read/write from Hive → sync queue builds up → flushes on reconnect
Group Tasks: Tasks synced per group; offline members queue changes locally, sync on reconnect
Group Alarms: Alarms stored in Firestore; delivery via FCM + WorkManager fallback
Banner:     Persistent offline banner (animated) via connectivity_plus stream
```

**13c. Sync Strategy (Simple Last-Write-Wins)**

For MVP, use **Last-Write-Wins** with timestamps:
- Reading progress: latest timestamp wins
- Highlights: append-only, no deletion
- Task updates: latest timestamp wins
- Alarm dismissals: append-only (can't delete dismissals)

**MVP Approach:**
- Write locally to Hive immediately (articles, tasks, alarms)
- Queue Firestore write in background
- On reconnect, merge by comparing timestamps
- For tasks/alarms: if member edits while offline, show "conflict" toast → user picks version

---

**13d. Performance Targets**

| Metric | Target |
|---|---|
| App startup (cold) | <2s |
| Home screen render | <500ms |
| Queue open | <300ms |
| Save completion | <1s |
| Reader open | <800ms |
| Group view open | <500ms |
| Task creation | <800ms |
| Alarm creation | <600ms |
| All animations | Consistent 60fps |

**13e. Performance Engineering Rules**
- Use `const` constructors everywhere possible
- `RepaintBoundary` around all animated elements
- `ListView.builder` with `cacheExtent: 500` for all lists
- Riverpod `select()` to prevent unnecessary rebuilds
- `cached_network_image` for all thumbnails (disk + memory cache)
- Firestore pagination: 20 items per page with infinite scroll
- Firestore composite indexes for group queries (pre-create in console)
- Group queries cached with 5-minute TTL locally

---

### 14. ANDROID-FIRST PLATFORM FEATURES

**14a. App Shortcuts (long-press home icon)**
- Save from Clipboard
- Open Tonight Queue
- Create Task (in default group)

**14b. Home Screen Widgets (via `home_widget` + Glance)**

| Widget | Size | Content |
|---|---|---|
| Smart Queue | 4×1 | Next item title + reminder countdown + tap to open reader |
| Quick Save | 1×1 | Single-tap save via clipboard |
| Reading Streak | 2×2 | Streak count + daily completion ring |
| **Pending Tasks** | 4×2 | Next task in default group + assignee + due date |

**Note:** Android Auto, Wear OS, and Live Folder are deferred to Phase 2+ (require separate platform development and testing).

---

### 15. MONETISATION

**Free Tier (Genuinely Powerful + Collaboration):**
- Unlimited personal saves
- 3 Smart Queues (Tonight, Weekend, Forgotten)
- Time-based reminders
- On-device categorization
- **1 Group (up to 3 members)** — shared tasks, alarms, coordination
- 1 Shared Space
- Basic Reading Streak (1 freeze/month)
- No advertisements — ever

**Reminde Pro — $4.99/month or $39.99/year:**
- All 8 Smart Queues
- All 3 reminder types (time, behavior, recurring)
- **Unlimited Groups (unlimited members per group)**
- **Advanced Alarm Features** (custom repeat patterns, detailed notification settings)
- Unlimited Shared Spaces
- Full home screen widget pack
- Focus Reader Mode (RSVP)
- Advanced Analytics dashboard
- Custom themes (10 premium palettes)
- Unlimited Streak Freezes
- Priority support

**Reminde Family — $6.99/month:**
- Pro benefits for up to 5 family members
- Shared group workspace (all family members auto-added)
- Family-only settings preset

**Conversion Strategy:**
- Free trial prompt appears after **3 days of meaningful use** (≥3 saves + ≥1 completed item + 1 group action)
- Trial: 14 days full Pro access
- Referral: new user joins via Group invite → both get 1-week Pro

**Payment:** RevenueCat for subscription management (handles Google Play Billing)

**Note:** Export integrations (Notion, Obsidian, Readwise) and advanced task features (subtasks, recurring tasks) are deferred to Phase 2.

---

### 16. NOTIFICATION SPECIFICATIONS

| Notification | Trigger | Content | Action |
|---|---|---|---|
| Daily Digest | User-set time (default 8am, FCM) | "You have 4 articles and 2 videos today" | Opens relevant queue |
| Time Reminder | Scheduled via AlarmManager | "[Article title] is waiting for you" | Opens reader |
| Forgotten Rescue | Weekly, Monday 9am | "3 long-lost articles miss you 👀" | Opens Forgotten queue |
| Streak Reminder | If no completion by 9pm | "Don't break your X-day streak!" | Opens Tonight queue |
| Weekly Insights | Sunday 7pm | "Your weekly reading story is ready" | Opens Insights screen |
| **Task Assigned** | When task assigned to user | "[User] assigned you 'Buy groceries' in Family Chores" | Opens task in group view |
| **Task Completed** | When team member completes task | "[User] completed 'Buy groceries' in Family Chores" | Opens group task list |
| **Shared Alarm** | Scheduled alarm time | "[User] set an alarm: Team standup" | Opens alarm (full-screen) |
| **Group Invite** | When invited to group | "[User] invited you to Family Chores" | Tap to join group instantly |
| **Group Activity Digest** | Daily at 9pm (opt-in) | "[User] completed 3 tasks, 1 alarm set today" | Opens group activity feed |
| Shared Space | New item or reaction | "[User] added something to [Space]" | Opens shared space |

**Group Notification Channels (User-Customizable):**
- Invite notifications
- Task assignments
- Task completions
- Alarm notifications
- Daily digest for pending tasks

All notifications: expandable (BigTextStyle), notification channels configured per type, respect Do Not Disturb, user can disable each channel independently in Settings.

---

### 17. GOOGLE PLAY STORE LAUNCH

**ASO Configuration:**
- **App Title:** Reminde – Save, Read & Coordinate Together
- **Short Description:** Personal read-it-later + family/team task coordinator. Never forget what matters.
- **Category:** Productivity
- **Target keywords:** read later, save articles, bookmark manager, family coordinator, family app, shared task list, team tasks, household organizer, shared alarms, notification app, offline reader
- **Screenshots:** 8–10 on Pixel devices showing:
  1. Home screen with queues
  2. Save flow
  3. Reader view
  4. Groups tab / task list
  5. Shared alarms UI
  6. Member coordination
  7. Widgets
  8. Insights/Streaks
- **Feature Graphic:** Split scene: left side shows reading/articles, right side shows family coordination (group, tasks, alarms)

**Launch Campaign (4 phases):**
1. **Pre-launch (6 weeks prior):** Google Play pre-registration + early adopter badge + landing page highlighting both personal + family features
2. **Warm-up (2–4 weeks prior):** Android YouTube channels + tech blog coverage + family/productivity focused outlets
3. **Launch week:** Auto-install for pre-registered users + Product Hunt launch + family productivity communities
4. **Post-launch:** Referral mechanic (join via group invite → both get 1-week Pro) + Reddit/Facebook group marketing for family coordinators

---

### 18. IMPLEMENTATION ROADMAP (EXPANDED FOR COLLABORATION)

| Phase | Timeline | Key Deliverables |
|---|---|---|
| Phase 1: Foundation + Collaboration | Weeks 1–9/10 | Auth, Save, Home, Queues, Reader, Offline (Hive), Time Reminders, **Groups setup, Shared Tasks, Shared Alarms framework** |
| Phase 2: Engagement & Polish | Weeks 10–16 | Streaks, Badges, Insight Stories, Shared Spaces, Widgets, Shortcuts, Material You, Animations, Performance tuning |
| Phase 3: Launch Prep | Weeks 17–19 | ASO prep, Beta testing, Play Store submission |
| Phase 4: Launch | Week 20+ | Pre-registration, Launch campaign, Monitor & stabilize |

**Phase 1 Breakdown (Collaboration features):**
- **Weeks 1–3:** Core group creation, member management, real-time Firestore sync
- **Weeks 4–6:** Shared task list UI, task assignment, task completion tracking
- **Weeks 7–9:** Shared alarm scheduling, FCM delivery, alarm UI on receive, WorkManager backend
- **Week 9–10:** Integration testing, edge case handling (offline groups, sync conflicts), performance optimization

**Phase 2+ Features (Deferred):**
- Advanced NLP summarization (cloud API integration)
- Public profiles & Discovery Feed
- TTS narration
- Export integrations (Notion, Obsidian, Readwise)
- Advanced alarm features (geofencing, custom repeat patterns)
- Task subtasks and dependencies
- Group expense splitting / budget tracking

---

### 19. RISK MITIGATIONS (BUILD THESE IN FROM DAY 1)

### 19. RISK MITIGATIONS (BUILD THESE IN FROM DAY 1)

| Risk | Mitigation |
|---|---|
| Group sync conflicts | Implement last-write-wins with timestamps; test 3+ concurrent edits; maintain audit trail |
| FCM alarm delivery reliability | Use multiple delivery channels: FCM + local WorkManager fallback; log all deliveries |
| Member invitation spam | Rate limit invites to 10/hour per user; implement ignore/block list |
| Offline task editing | Queue task updates locally in Hive; sync on reconnect; detect conflicts and surface to user |
| Low engagement (tasks/alarms) | Require one group action (create task or set alarm) before unlocking full features; send weekly digest |
| Subscription fatigue | Price below all competitors; free tier includes basic group features (up to 3 members) |
| Platform player entry | Early group adoption (Pocket → Reminde migration offers free family plan) |
| Notification fatigue | User can configure notification frequency per group; default: only critical alerts |
| Performance at scale | Pagination for task lists; cache member list; defer FCM delivery for 100+ member groups |

---

### 20. KEY DESIGN PRINCIPLES (NON-NEGOTIABLE)

1. **Every interaction must feel physical** — spring physics, haptic feedback, no linear animations
2. **AI must be invisible** — it surfaces content at the right time; it never interrupts
3. **Saving must feel effortless** — zero mandatory steps, everything auto-detected
4. **The queue is alive** — never a static list; always contextually relevant
5. **Offline first, always** — full functionality without internet, every single screen
6. **No dark patterns** — no artificial feature gating to force upgrades; free tier is genuinely useful
7. **Privacy by default** — all AI on-device; user data never leaves device without explicit consent
8. **Android is the star** — Material You, widgets, dynamic colors — not an afterthought
9. **Collaboration feels natural** — group features should feel as simple as personal features; no complexity overhead
10. **Real-time transparency** — users always know if changes are synced, pending, or failed; show connection status clearly
11. **Hybrid Design (Material 3 + Neo-Brutalism)** — Soft, accessible Material 3 as the foundation; high-contrast Neo-Brutalist overlays for urgent actions (alarms, critical reminders). This keeps the app usable for everyone while making important moments impossible to miss.

---

### 21. COLLABORATIVE UI/UX PATTERNS

**Real-Time Sync Indicators:**
- Active sync: pulsing dot + "Syncing..." label (appears in title bar)
- Sync complete: checkmark appears, fades after 2s
- Offline: X icon + "Offline — changes saved locally" banner
- All async without blocking UI

**Member Presence:**
- Group task view shows who's currently viewing: "You, Mom, Dad viewing"
- If member edits task while you're viewing: "Dad is editing this task" (toast notification)
- If member completes task on another device: instant UI update + subtle animation

**Invite Flow:**
- After creating group: "Invite teammates" CTA button
- Tap → email input → "Send Invite" → success message
- Invitees see push notification within 2s (FCM)
- Deep link: joining is one-tap (no re-login if they have account)

**Group Activity Feed:**
- Home screen widget: "Group Activity" section
- Events: "[User] completed 'Groceries'", "[User] set 'Team standup' alarm"
- Each event is tap-able and time-stamped
- Archival after 30 days

**Permission Edge Cases:**
- Non-admin trying to delete group task: disabled button, tooltip "Only admins can delete"
- Kicked member trying to access group: message "You've been removed from Family Chores"
- Member with edit permission: can edit task title/description/assignee

---

*End of Reminde v3.0 Specification*

This specification now covers: **Personal read-it-later** + **Collaborative tasks** + **Shared alarms**. All features are designed for simultaneous development in Phase 1 (9-10 weeks). The product serves both individual and family/team use cases without compromising either.
