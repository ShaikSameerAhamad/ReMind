# reMind Product Requirements Document

Version: 1.0  
Brand: reMind  
Tagline: Save smarter. Sync better  
Source: Reminde v3.0 product specification

## 1. Product Summary

reMind is an Android-first read-it-later and coordination app for people who save useful links, articles, videos, tasks, and reminders but struggle to return to them at the right time. It combines personal saving, smart queues, offline reading, reminders, reading streaks, shared task lists, shared alarms, and family or team workspaces into one productivity surface.

The app should feel fast, calm, and dependable. Its core promise is simple: save what matters, bring it back when it matters, and keep shared responsibilities in sync.

## 2. Problem Statement

People save information constantly but rarely return to it. Articles disappear into bookmarks, videos are lost in watch-later lists, reminders are scattered across apps, and family or team tasks live in chats where they are hard to track.

reMind solves two connected problems:

| Problem | Who Faces It | Why It Matters |
|---|---|---|
| Save-and-forget behavior | Readers, students, researchers, creators, professionals | Saved knowledge loses value when it never resurfaces. |
| Fragmented coordination | Families, couples, roommates, small teams | Tasks, alarms, and decisions get buried in chats and cause missed responsibilities. |
| Weak Android read-it-later options | Android power users and displaced Pocket or Omnivore users | Existing tools are either iOS-first, stagnant, or too generic. |
| Notification overload | Busy users who already have many productivity apps | Reminders must be timely and useful, not noisy. |

The market timing is favorable because legacy read-it-later tools have shut down, narrowed scope, or left gaps on Android. reMind should enter as an Android-native, offline-first, collaborative alternative.

## 3. Product Vision

reMind becomes the trusted memory layer for saved content and shared responsibilities. It helps users capture instantly, resurface intelligently, and coordinate smoothly without forcing them to manage another complicated system.

North star: users come back to what they saved and complete what they planned with less friction.

## 4. Target Users

### Persona 1: Android Knowledge Worker

Name: Arjun  
Age: 29  
Tech comfort: High  
Goals: Save technical articles, revisit long reads, track learning goals, avoid losing useful resources.  
Frustrations: Browser bookmarks are cluttered, Pocket alternatives feel weak on Android, notifications are either too generic or too noisy.  
reMind value: Smart queues, offline reader, reminders, reading streaks, and Android widgets.

### Persona 2: Busy Parent or Household Coordinator

Name: Maya  
Age: 37  
Tech comfort: Medium  
Goals: Coordinate groceries, school tasks, medication reminders, weekend planning, and family chores.  
Frustrations: Family tasks live across WhatsApp, sticky notes, and calendar alarms. Nobody knows what is done.  
reMind value: Shared groups, assignable tasks, shared alarms, group activity feed, and clear completion status.

### Persona 3: Student or Lifelong Learner

Name: Neha  
Age: 21  
Tech comfort: Medium-high  
Goals: Save course links, videos, research material, and study reminders. Build consistent reading habits.  
Frustrations: Saved material piles up before exams. She forgets why she saved something.  
reMind value: Learning queue, reading streaks, badges, reminders, and clean reader mode.

### Persona 4: Small Team Operator

Name: Daniel  
Age: 34  
Tech comfort: High  
Goals: Coordinate small project tasks, reminders, links, and team follow-ups without adopting a heavy project management suite.  
Frustrations: Project tools are too heavy for lightweight recurring work; chat-only coordination loses accountability.  
reMind value: Group tasks, shared alarms, activity feed, real-time sync, and offline edits.

## 5. Core Features and Scope

### MVP Must-Have Features

| Feature | Description | MVP Label |
|---|---|---|
| Authentication | Google Sign-In, guest mode, logout, account migration path from guest to signed-in user. | Must-Have |
| Personal save system | Save by URL paste, Android share intent, and clipboard detection. | Must-Have |
| Metadata enrichment | Fetch title, thumbnail, source, category, and estimated read time where available. | Must-Have |
| Smart queues | Tonight, Weekend, Forgotten, Continue Reading, Watch Later, Learning, Recently Saved. | Must-Have |
| Home hub | Bento-style dashboard with queue previews, streak, group activity, task and alarm quick actions. | Must-Have |
| Reader screen | Clean extracted article view, fallback browser, progress tracking, customization panel. | Must-Have |
| Time reminders | Tonight, Tomorrow AM, Weekend, custom date/time, and basic recurring reminders. | Must-Have |
| Offline-first storage | Hive local storage, queued writes, Firestore sync, visible sync state. | Must-Have |
| Reading streaks | Streak count, daily completion, basic streak widget. | Must-Have |
| Groups | Create group, invite members, roles, membership state. | Must-Have |
| Shared tasks | Create, assign, complete, comment lightly, sync in real time. | Must-Have |
| Shared alarms | Create group alarm, deliver via FCM, show received alarm UI, track dismissal. | Must-Have |
| Group activity feed | Recent group events on home and group screens. | Must-Have |
| Push notifications | Daily digest, reminders, task assigned, task completed, group invite, shared alarm. | Must-Have |

### Phase 2+ Nice-to-Have Features

| Feature | Description | Phase |
|---|---|---|
| Advanced behavior-based reminders | Learn preferred reading windows over 14 days and improve suggestions. | Phase 2 |
| Badges and insights stories | Weekly stories, badge gallery, shareable achievements. | Phase 2 |
| Full widget pack | Smart queue, quick save, reading streak, pending tasks. | Phase 2 |
| Shared spaces | Collaborative reading spaces and shared quote cards. | Phase 2 |
| Focus Reader Mode | RSVP word-by-word reading mode. | Phase 2 |
| Advanced AI summaries | Cloud or local summarization after product-market validation. | Phase 2+ |
| ML Kit date extraction | Natural time parsing such as "tomorrow 2pm". | Phase 2+ |
| TTS narration | Audio reading mode. | Phase 2+ |
| Export integrations | Notion, Obsidian, Readwise, Wallabag. | Phase 2+ |
| Advanced task features | Subtasks, dependencies, recurring tasks. | Phase 2+ |
| Advanced alarms | Geofencing, custom vibration, complex repeat rules. | Phase 2+ |
| Public profiles and discovery | Social discovery and public content feeds. | Later |

## 6. Critical User Flows

### Flow 1: New User Signup -> Save First Article -> View in Queue

1. User opens reMind and sees splash with the reMind loop icon and tagline.
2. User moves through onboarding: save smarter, smart queues, sync better.
3. User chooses Google Sign-In or Continue as Guest.
4. App lands on the home hub with an empty queue state and visible quick-save FAB.
5. User taps FAB -> URL Paste or shares a URL from another Android app.
6. Save sheet opens with auto-filled title, thumbnail, source, category suggestion, tags, and reminder suggestion.
7. User taps Save.
8. Item is written to Hive immediately and queued for Firestore sync.
9. App shows save confirmation and animates the item into the relevant home tile.
10. User opens Recently Saved or Tonight Queue and sees the saved item.

Success criteria: first save can be completed within 30 seconds, even in guest mode and even if network metadata enrichment is delayed.

### Flow 2: Create Family Group -> Invite Members -> Assign First Task

1. User taps Create Task or Groups from the home hub.
2. If no group exists, app prompts user to create a group.
3. User enters group name, such as "Family Chores".
4. User adds invite emails or shareable invite links.
5. App creates `groups/{groupId}` and adds creator as admin.
6. Invitees receive FCM notification or link.
7. Invitee joins group and appears in member list.
8. Admin taps New Task.
9. Admin enters title, optional description, due date, assignee, and priority.
10. Task appears instantly for all group members through Firestore real-time listeners.

Success criteria: a non-technical user can create a group and assign a first task without reading setup instructions.

### Flow 3: Set Shared Alarm -> Receive on Group Member Device -> Dismiss

1. User taps Set Alarm from home or group view.
2. Bottom sheet opens with title, time, group selector, repeat option, recipients, and optional message.
3. User submits the alarm.
4. Alarm is saved locally and to Firestore under `groups/{groupId}/alarms/{alarmId}`.
5. Cloud Function schedules or triggers FCM at the scheduled time.
6. Recipient device receives notification and opens full-screen alarm UI when permitted by Android settings.
7. Recipient dismisses the alarm.
8. App writes dismissal timestamp to Firestore and updates group alarm status.
9. Creator and group activity feed can show dismissal state.

Success criteria: alarm delivery path is observable with logs, retry state, and local fallback behavior.

### Flow 4: Reading Streak -> Earning Badges -> Viewing Insights

1. User opens an item in the reader.
2. User reads to completion or taps Mark Complete.
3. App increments daily completion and streak if rules are met.
4. Completion animation and haptic feedback confirm progress.
5. If a badge condition is met, app shows the earned badge.
6. User opens Insights from home or profile.
7. App shows streak count, recently completed items, saved-versus-read trend, and badges.

Success criteria: completion feels rewarding but does not interrupt the reading experience.

## 7. MVP Definition

The MVP is an Android-first Flutter app that lets users save links, organize them into smart queues, read offline, receive useful reminders, and coordinate shared tasks and alarms with one group.

### Included in v1

- Google Sign-In and guest mode.
- URL save, clipboard save, Android share intent.
- Metadata extraction and simple category detection.
- Smart queues and home hub.
- Reader view with progress tracking and basic customization.
- Time-based and basic recurring reminders.
- Hive local storage, Firestore sync, and offline write queue.
- One free group with up to three members.
- Shared tasks, basic comments, completion, assignment, and activity feed.
- Shared alarms with FCM and WorkManager fallback.
- Reading streaks and basic badges.

### Deliberately Not in v1

- Public social discovery.
- Advanced AI summaries.
- TTS narration.
- Geofencing.
- OCR and QR scanning.
- Advanced task dependencies and subtasks.
- Export integrations.
- Android Auto or Wear OS.
- Full CRDT conflict resolution.
- Complex price-drop tracking.

## 8. Success Metrics

### Activation

| Metric | Target |
|---|---|
| Signup-to-first-save conversion | 70%+ |
| Median time to first save | Under 3 minutes |
| First group created within 7 days | 20%+ of signed-in users |
| First task or alarm created after group setup | 60%+ |

### Engagement

| Metric | Target |
|---|---|
| D1 retention | 45%+ |
| D7 retention | 25%+ |
| D30 retention | 12%+ |
| Saved items opened within 7 days | 35%+ |
| Weekly active readers | 30%+ of active users |
| Weekly active groups | 40%+ of created groups |

### Coordination

| Metric | Target |
|---|---|
| Task completion rate | 50%+ within due window |
| Shared alarm dismissal tracking success | 95%+ of delivered alarms |
| Group invite acceptance rate | 35%+ |
| Average group actions per active group per week | 5+ |

### Reliability

| Metric | Target |
|---|---|
| Cold startup | Under 2 seconds |
| Home render | Under 500 ms |
| Save completion | Under 1 second after user taps Save |
| Offline queued writes synced within 5 minutes of reconnect | 95%+ |
| Notification delivery observable with fallback state | 99% logged |

### Monetization

| Metric | Target |
|---|---|
| Free-to-trial conversion after meaningful use | 8%+ |
| Trial-to-paid conversion | 25%+ |
| Monthly churn for paid users | Under 6% |

## 9. Product Principles

1. Save must require almost no thought.
2. The app should resurface useful things without becoming noisy.
3. Offline mode is a first-class experience, not an error state.
4. Collaboration should feel as simple as personal use.
5. Critical states, especially alarms, must be unmistakable.
6. The free tier must remain genuinely useful.
7. Android platform features should make reMind feel native.
