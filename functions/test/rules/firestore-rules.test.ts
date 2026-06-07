import assert from "node:assert/strict";
import {readFileSync} from "node:fs";
import path from "node:path";
import {after, before, beforeEach, describe, it} from "node:test";

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  RulesTestEnvironment,
} from "@firebase/rules-unit-testing";
import {
  collection,
  doc,
  getDoc,
  getDocs,
  setDoc,
  Timestamp,
  updateDoc,
} from "firebase/firestore";

const projectId = "remind-rules-test";
const rulesPath = path.join(process.cwd(), "..", "firestore.rules");
const firestoreEmulatorPort = Number(process.env.FIRESTORE_EMULATOR_PORT ?? "8906");

let testEnv: RulesTestEnvironment;

describe("Firestore security rules", () => {
  before(async () => {
    testEnv = await initializeTestEnvironment({
      projectId,
      firestore: {
        rules: readFileSync(rulesPath, "utf8"),
        host: "127.0.0.1",
        port: firestoreEmulatorPort,
      },
    });
  });

  beforeEach(async () => {
    await testEnv.clearFirestore();
  });

  after(async () => {
    await testEnv.cleanup();
  });

  it("allows users to access their own profile and blocks other profiles", async () => {
    const alice = testEnv.authenticatedContext("alice").firestore();
    const bob = testEnv.authenticatedContext("bob").firestore();

    await assertSucceeds(
      setDoc(doc(alice, "users/alice"), {
        profile: {name: "Alice"},
        updatedAt: Timestamp.now(),
      }),
    );
    await assertSucceeds(getDoc(doc(alice, "users/alice")));
    await assertFails(getDoc(doc(bob, "users/alice")));
  });

  it("allows a signed-in user to create a group as its admin", async () => {
    const alice = testEnv.authenticatedContext("alice").firestore();

    await assertSucceeds(
      setDoc(doc(alice, "groups/family"), groupDocument("alice")),
    );
  });

  it("blocks group listing for signed-in users", async () => {
    await seedGroup();
    const alice = testEnv.authenticatedContext("alice").firestore();

    await assertFails(getDocs(collection(alice, "groups")));
  });

  it("allows members to create tasks and blocks nonmembers", async () => {
    await seedGroup();
    const alice = testEnv.authenticatedContext("alice").firestore();
    const eve = testEnv.authenticatedContext("eve").firestore();

    await assertSucceeds(
      setDoc(doc(alice, "groups/family/tasks/task-1"), taskDocument("alice")),
    );
    await assertFails(
      setDoc(doc(eve, "groups/family/tasks/task-2"), taskDocument("eve")),
    );
  });

  it("allows members to create shared alarms and blocks nonmembers", async () => {
    await seedGroup();
    const alice = testEnv.authenticatedContext("alice").firestore();
    const eve = testEnv.authenticatedContext("eve").firestore();

    await assertSucceeds(
      setDoc(doc(alice, "groups/family/alarms/alarm-1"), alarmDocument("alice")),
    );
    await assertFails(
      setDoc(doc(eve, "groups/family/alarms/alarm-2"), alarmDocument("eve")),
    );
  });

  it("allows recipients to write only their own alarm dismissal", async () => {
    await seedGroup();
    await seedAlarm();
    const alice = testEnv.authenticatedContext("alice").firestore();
    const bob = testEnv.authenticatedContext("bob").firestore();

    await assertSucceeds(
      updateDoc(doc(alice, "groups/family/alarms/alarm-1"), {
        "dismissals.alice": Timestamp.now(),
        updatedAt: Timestamp.now(),
      }),
    );
    await assertFails(
      updateDoc(doc(bob, "groups/family/alarms/alarm-1"), {
        "dismissals.alice": Timestamp.now(),
        updatedAt: Timestamp.now(),
      }),
    );
  });

  it("allows invite acceptance to add only the joining member as member", async () => {
    await seedGroup();
    const bob = testEnv.authenticatedContext("bob").firestore();

    await assertSucceeds(
      updateDoc(doc(bob, "groups/family"), {
        "members.bob": {
          role: "member",
          joinedAt: Timestamp.now(),
          displayName: "Bob",
          avatarUrl: null,
        },
        "inviteCodes.invite-1.status": "accepted",
        "inviteCodes.invite-1.acceptedBy": "bob",
        "inviteCodes.invite-1.acceptedAt": Timestamp.now(),
        updatedAt: Timestamp.now(),
        lastActivityAt: Timestamp.now(),
      }),
    );

    await assertFails(
      updateDoc(doc(bob, "groups/family"), {
        "members.bob.role": "admin",
      }),
    );
  });

  it("blocks activity feed writes from clients", async () => {
    await seedGroup();
    const alice = testEnv.authenticatedContext("alice").firestore();

    await assertFails(
      setDoc(doc(alice, "groups/family/activity/event-1"), {
        type: "task_created",
        actorUid: "alice",
        createdAt: Timestamp.now(),
      }),
    );
  });
});

async function seedGroup(): Promise<void> {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), "groups/family"), groupDocument("alice"));
  });
}

async function seedAlarm(): Promise<void> {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(
      doc(context.firestore(), "groups/family/alarms/alarm-1"),
      alarmDocument("alice"),
    );
  });
}

function groupDocument(createdBy: string): Record<string, unknown> {
  const now = Timestamp.now();
  return {
    name: "Family",
    createdBy,
    members: {
      alice: {
        role: "admin",
        joinedAt: now,
        displayName: "Alice",
        avatarUrl: null,
      },
    },
    inviteCodes: {
      "invite-1": {
        code: "invite-1",
        deepLink: "remind://groups/family/invites/invite-1",
        createdBy,
        recipientEmail: null,
        createdAt: now,
        expiresAt: Timestamp.fromMillis(Date.now() + 86_400_000),
        status: "active",
      },
    },
    createdAt: now,
    updatedAt: now,
    lastActivityAt: now,
    archivedAt: null,
  };
}

function taskDocument(createdBy: string): Record<string, unknown> {
  const now = Timestamp.now();
  return {
    title: "Pack lunch",
    notes: null,
    createdBy,
    assignedTo: "alice",
    priority: "normal",
    status: "open",
    createdAt: now,
    updatedAt: now,
    dueAt: null,
    completedAt: null,
    completedBy: null,
    updatedBy: createdBy,
    comments: [],
  };
}

function alarmDocument(createdBy: string): Record<string, unknown> {
  const now = Timestamp.now();
  return {
    title: "Leave home",
    message: "The cab is almost here.",
    createdBy,
    scheduledAt: Timestamp.fromMillis(Date.now() + 86_400_000),
    localTimeZone: "Asia/Kolkata",
    repeat: "once",
    repeatDays: [],
    recipients: ["alice"],
    status: "scheduled",
    dismissals: {},
    deliveryLog: [],
    createdAt: now,
    updatedAt: now,
    lastTriggeredAt: null,
  };
}

assert.equal(path.basename(rulesPath), "firestore.rules");
