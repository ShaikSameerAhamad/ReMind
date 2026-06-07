import assert from "node:assert/strict";
import {describe, it} from "node:test";

import {
  buildAlarmNotificationPayload,
  chunkTokens,
  deliveryLogsForMissingTokens,
  nextScheduledAt,
  SharedAlarmInput,
} from "../../src/alarms/scheduler";

const baseAlarm: SharedAlarmInput = {
  groupId: "family",
  alarmId: "wake-up",
  title: "Wake up",
  message: "School bus leaves soon.",
  scheduledAt: new Date("2026-06-07T08:30:00.000Z"),
  localTimeZone: "UTC",
  repeat: "once",
  repeatDays: [],
  recipients: ["user-a", "user-b"],
};

describe("shared alarm scheduler helpers", () => {
  it("builds a notification payload that routes to the alarm receive screen", () => {
    const payload = buildAlarmNotificationPayload(baseAlarm);

    assert.equal(payload.notification.title, "Wake up");
    assert.equal(payload.notification.body, "School bus leaves soon.");
    assert.equal(payload.data.type, "shared_alarm");
    assert.equal(payload.data.groupId, "family");
    assert.equal(payload.data.alarmId, "wake-up");
    assert.equal(
      payload.data.deepLink,
      "remind://groups/family/alarms/wake-up/received",
    );
  });

  it("does not reschedule one-time alarms", () => {
    assert.equal(nextScheduledAt(baseAlarm, baseAlarm.scheduledAt), null);
  });

  it("advances daily alarms to the next local wall-clock occurrence", () => {
    const nextRun = nextScheduledAt(
      {...baseAlarm, repeat: "daily"},
      new Date("2026-06-07T08:31:00.000Z"),
    );

    assert.equal(nextRun?.toISOString(), "2026-06-08T08:30:00.000Z");
  });

  it("advances weekly alarms to the next configured weekday", () => {
    const nextRun = nextScheduledAt(
      {...baseAlarm, repeat: "weekly", repeatDays: [1, 3]},
      new Date("2026-06-07T09:00:00.000Z"),
    );

    assert.equal(nextRun?.toISOString(), "2026-06-08T08:30:00.000Z");
  });

  it("records recipients with no available device token", () => {
    const logs = deliveryLogsForMissingTokens(baseAlarm.recipients, [
      {uid: "user-a", tokenId: "phone", token: "token-a"},
    ]);

    assert.deepEqual(logs, [{uid: "user-b", status: "no_token"}]);
  });

  it("chunks FCM token fan-out into multicast-safe batches", () => {
    const records = Array.from({length: 501}, (_, index) => ({
      uid: `user-${index}`,
      tokenId: "phone",
      token: `token-${index}`,
    }));

    const chunks = chunkTokens(records);

    assert.equal(chunks.length, 2);
    assert.equal(chunks[0].length, 500);
    assert.equal(chunks[1].length, 1);
  });
});
