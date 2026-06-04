# reMind Security and Access Document

Version: 1.0  
Audience: Product, engineering, QA, and early security review  
Scope: Authentication, authorization, Firestore access, offline behavior, error handling, and edge cases

## 1. Security Goals

reMind stores personal reading history, saved links, group tasks, shared alarms, and household or team coordination data. The product must protect private user content while still allowing simple collaboration.

Security goals:

- Users can only access their own personal data.
- Group data is visible only to current group members.
- Group admins can manage members and destructive group actions.
- Offline writes are allowed locally but validated before cloud sync.
- Tokens and sensitive config are never stored in plain text.
- Notification delivery is logged without exposing private content unnecessarily.
- Account deletion removes user access while preserving shared group integrity.

## 2. Authentication Methods

### Primary: Google Sign-In

Google Sign-In is the default authentication path for signed-in users. It creates or resolves a Firebase Auth user and gives the app a Firebase ID token for Firestore, Storage, Functions, and FCM access.

Expected behavior:

1. User taps Continue with Google.
2. Google OAuth flow returns identity.
3. Firebase Auth signs in with Google credential.
4. App creates or updates `users/{uid}`.
5. App registers device FCM token under the user record.
6. App starts cloud sync for local pending data.

### Secondary: Guest Mode

Guest mode allows immediate use without account creation. It should support personal local features but block or limit cloud collaboration until the user signs in.

Guest behavior:

- Saves, queues, reader progress, and basic reminders work locally through Hive.
- Guest data has a local-only user ID such as `guest:{deviceId}`.
- Guest cannot create cloud groups, invite members, or receive cross-device alarms.
- Guest can create local-only tasks and reminders if product wants a softer onboarding path.
- When guest signs in, app offers to migrate local saved items, streaks, and preferences into the signed-in account.

### Token Storage

Firebase Auth handles refresh tokens through platform-secure storage. App code should not manually store Firebase ID tokens in Hive.

Use secure storage for:

- Local encryption keys.
- Third-party SDK secrets if unavoidable.
- Any temporary OAuth data not managed by Firebase.

Do not store in Hive:

- Plaintext auth tokens.
- RevenueCat secret keys.
- FCM server keys.
- Admin credentials.

### Logout

Logout must clear the local authenticated session and prevent stale data exposure.

Logout steps:

1. Stop active Firestore listeners.
2. Unregister or disassociate current FCM token from `users/{uid}`.
3. Flush or mark pending sync operations as user-owned and no longer runnable.
4. Sign out from Firebase Auth and Google Sign-In.
5. Clear secure token material.
6. Clear or encrypt local Hive boxes containing user data.
7. Return to auth screen.

Product decision: if multiple accounts are expected on one device, local user data should be partitioned by UID instead of fully deleted.

## 3. Roles and Permissions

| Role | Can Create Groups | Can Edit Tasks | Can Delete Others' Tasks | Can Manage Members | Can Create Shared Alarms | Can Use Personal Saves |
|---|---:|---:|---:|---:|---:|---:|
| Guest User | No | Local only | No | No | No | Yes, local only |
| Regular User | Yes, within plan limits | In groups they belong to | No, unless creator or admin | No | Yes, in groups they belong to | Yes |
| Group Member | No, unless regular user action outside group | Yes, if group member | No | No | Yes, if allowed by group settings | Yes |
| Group Admin | Yes | Yes | Yes | Yes | Yes | Yes |
| System Function | N/A | Yes, service role only | Yes, service role only | Yes, service role only | Yes | N/A |

### Regular User

Can manage personal saved items, queues, reminders, reader settings, streaks, and profile. Can create groups if signed in and within plan limits.

### Group Admin

Can update group settings, invite members, remove members, delete group tasks, cancel group alarms, and archive the group.

### Group Member

Can view group tasks and alarms, create tasks, update tasks they have permission to edit, complete assigned tasks, create shared alarms if group settings allow, and leave the group.

### Guest User

Can use local personal features. Cannot use cross-device collaboration because there is no stable authenticated identity for access control.

## 4. Firestore Row-Level Security Rules

These are implementation-oriented pseudo-rules. Final rules should be tested with the Firebase Emulator Suite.

```text
function signedIn() {
  return request.auth != null;
}

function isSelf(uid) {
  return signedIn() && request.auth.uid == uid;
}

function groupDoc(groupId) {
  return get(/databases/$(database)/documents/groups/$(groupId));
}

function isGroupMember(groupId) {
  return signedIn()
    && groupDoc(groupId).data.members[request.auth.uid] != null;
}

function isGroupAdmin(groupId) {
  return signedIn()
    && groupDoc(groupId).data.members[request.auth.uid].role == "admin";
}

match /users/{uid} {
  allow read, update, delete: if isSelf(uid);
  allow create: if isSelf(uid);

  match /items/{itemId} {
    allow read, create, update, delete: if isSelf(uid);
  }
}

match /groups/{groupId} {
  allow read: if isGroupMember(groupId);
  allow create: if signedIn()
    && request.resource.data.createdBy == request.auth.uid
    && request.resource.data.members[request.auth.uid].role == "admin";
  allow update: if isGroupMember(groupId)
    && !isRemovingMemberUnlessAdmin();
  allow delete: if isGroupAdmin(groupId);

  match /tasks/{taskId} {
    allow read: if isGroupMember(groupId);
    allow create: if isGroupMember(groupId)
      && request.resource.data.createdBy == request.auth.uid;
    allow update: if isGroupMember(groupId)
      && taskUpdateIsAllowed();
    allow delete: if isGroupAdmin(groupId)
      || resource.data.createdBy == request.auth.uid;
  }

  match /alarms/{alarmId} {
    allow read: if isGroupMember(groupId);
    allow create: if isGroupMember(groupId)
      && request.auth.uid in request.resource.data.recipients;
    allow update: if isGroupMember(groupId)
      && alarmUpdateIsAllowed();
    allow delete: if isGroupAdmin(groupId)
      || resource.data.createdBy == request.auth.uid;
  }

  match /activity/{eventId} {
    allow read: if isGroupMember(groupId);
    allow create, update, delete: if false;
  }
}

match /sharedSpaces/{sharedSpaceId} {
  allow read: if signedIn()
    && request.auth.uid in resource.data.members;
  allow create: if signedIn()
    && request.auth.uid == request.resource.data.ownerUid;
  allow update: if signedIn()
    && request.auth.uid in resource.data.members;
  allow delete: if signedIn()
    && request.auth.uid == resource.data.ownerUid;
}
```

### Rule Notes

- Activity events should generally be written by Cloud Functions to prevent spoofed feed entries.
- Members should not be able to escalate their own role.
- Admin removal of members must validate that at least one admin remains.
- Task completion can be allowed for any member, but task deletion should be admin or creator-only.
- Alarm dismissal updates should only allow users to write their own `dismissals.{uid}` value.

## 5. Storage Access Rules

Firebase Storage should mirror Firestore ownership:

| Path | Access |
|---|---|
| `users/{uid}/avatars/*` | Owner read/write; optionally public read through signed URL. |
| `users/{uid}/items/{itemId}/thumbnails/*` | Owner read/write. |
| `groups/{groupId}/*` | Current group members read; admins or creator write depending on asset type. |
| `public/brand/*` | Public read, admin write only. |

Never allow broad unauthenticated writes to Storage.

## 6. Error Handling

| Failure Point | User Experience | Technical Handling |
|---|---|---|
| Network offline | Persistent banner: "Offline - changes saved locally." | Writes go to Hive and sync queue; WorkManager retries. |
| Firestore write fails | Non-blocking toast: "Saved locally. Sync will retry." | Mark operation `failed` or `pending_retry`, exponential backoff. |
| FCM delivery fails | Sender sees no scary error unless all recipients fail. | Log delivery failure; WorkManager local fallback for own-device alarms; retry eligible notifications. |
| User not authenticated | Redirect to login or guest upgrade prompt. | Clear protected providers and listeners. |
| Access group user is not in | Message: "You no longer have access to this group." | Return 403 state, stop listeners, remove cached active group. |
| Empty task title | Inline error below field. | Client validation and server rule length validation. |
| Invalid due date | Inline error. | Validate date exists, timezone sane, optional due date may be null. |
| Task creation offline | Task appears with pending sync dot. | Local task ID generated; Firestore write queued. |
| Alarm delivery uncertainty | Show delivery state when available. | Cloud Function logs per recipient; client records local receipt and dismissal. |
| Metadata extraction fails | Item still saves with URL and editable title. | Extraction retry is background-only. |

## 7. Edge Cases

### User Logs In on Two Devices

Behavior: both devices can read and write. Last-write-wins applies to personal item updates and task edits. If a conflicting edit is detected, show "Updated from another device" and refresh the detail view.

Implementation:

- Every mutable record has `updatedAt` and `updatedBy`.
- Local sync compares remote timestamp before writing.
- Append-only fields use merge semantics.

### Group Member Removed While Viewing Group

Behavior: current screen switches to an access removed state: "You've been removed from [Group Name]."

Implementation:

- Active listener receives group membership change.
- App invalidates group providers for that group.
- Cached group data is hidden or deleted.
- Pending writes for that group are cancelled.

### User Creates Five Tasks Offline Then Reconnects

Behavior: tasks appear immediately with pending sync state, then become synced one by one or in batch after reconnect.

Implementation:

- Each task gets a local UUID.
- Sync queue stores operation order and idempotency key.
- WorkManager drains queue with batched writes where possible.
- Failures remain visible with retry action.

### Concurrent Task Edits

Behavior: most recent edit wins. User sees a non-blocking message: "This task was edited by [User]."

Implementation:

- Compare `updatedAt`.
- Store `updatedBy`.
- For comments, append rather than overwrite.
- For completion, first valid completion wins unless admin reopens.

### Alarm Set for 2 PM but Recipient Phone Is Offline

Behavior: if FCM cannot reach the phone, the device should still surface the alarm when it comes online or if a local fallback was scheduled.

Implementation:

- Creator device and recipient devices schedule local WorkManager fallback when they sync the alarm before due time.
- Cloud Function sends FCM at due time.
- Client writes receipt status.
- If phone was offline and missed FCM, sync detects due alarm and triggers missed-alarm UI with clear timestamp.

### User Deletes Account While in Shared Groups

Behavior: personal data is removed. Shared group records are preserved, but the user is removed or anonymized.

Implementation:

- Remove user from all `groups.members`.
- Reassign sole-admin groups by prompting before deletion or archive group if no admin remains.
- Preserve task history with display name changed to "Deleted user" unless policy requires deletion.
- Delete `users/{uid}/items`, profile, FCM tokens, avatars, and personal thumbnails.

### Invite Spam

Behavior: user receives a limited number of invites and can block repeated senders.

Implementation:

- Rate limit invites per sender, for example 10 per hour.
- Store invite audit records.
- Support ignore/block list.

## 8. Privacy and Data Minimization

- Store only metadata needed to deliver product value.
- Do not send article content to AI services in MVP.
- Keep saved items private by default.
- Shared tasks and alarms must clearly show which group can see them.
- Notification payloads should avoid sensitive content when lock-screen privacy is enabled.
- Give users per-channel notification controls.

## 9. Audit and Logging

Log security-relevant events:

| Event | Log Fields |
|---|---|
| Sign-in | UID, provider, timestamp, device ID hash. |
| Group invite | Sender, recipient hash/email, group ID, timestamp. |
| Member removed | Actor UID, removed UID, group ID. |
| Task deleted | Actor UID, task ID, group ID. |
| Alarm delivery | Alarm ID, recipient UID, status, error code. |
| Access denied | UID, resource type, resource ID, reason. |

Do not log raw article content, auth tokens, full notification payloads, or sensitive user notes.

## 10. Security Testing Checklist

- Firebase Auth sign-in, sign-out, guest migration.
- Firestore emulator tests for every role.
- User cannot read another user's `items`.
- Removed member cannot read group tasks.
- Member cannot promote themselves to admin.
- Member cannot edit another user's alarm dismissal value.
- Guest cannot write cloud group data.
- Storage files cannot be read by non-members.
- Pending offline write fails safely after access is revoked.
- Account deletion removes personal data and FCM tokens.
