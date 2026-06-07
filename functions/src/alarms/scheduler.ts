import {DateTime} from "luxon";

export type AlarmRepeat = "once" | "daily" | "weekly";

export interface SharedAlarmInput {
  readonly groupId: string;
  readonly alarmId: string;
  readonly title: string;
  readonly message?: string;
  readonly scheduledAt: Date;
  readonly localTimeZone: string;
  readonly repeat: AlarmRepeat;
  readonly repeatDays: readonly number[];
  readonly recipients: readonly string[];
}

export interface AlarmNotificationPayload {
  readonly notification: {
    readonly title: string;
    readonly body: string;
  };
  readonly data: Record<string, string>;
}

export interface PushTokenRecord {
  readonly uid: string;
  readonly tokenId: string;
  readonly token: string;
}

export interface DeliveryLogEntry {
  readonly uid: string;
  readonly tokenId?: string;
  readonly status: "sent" | "failed" | "no_token";
  readonly errorCode?: string;
}

export function buildAlarmNotificationPayload(
  alarm: SharedAlarmInput,
): AlarmNotificationPayload {
  const deepLink =
    `remind://groups/${encodeURIComponent(alarm.groupId)}` +
    `/alarms/${encodeURIComponent(alarm.alarmId)}/received`;
  return {
    notification: {
      title: alarm.title,
      body: alarm.message ?? "Shared alarm due now.",
    },
    data: {
      type: "shared_alarm",
      groupId: alarm.groupId,
      alarmId: alarm.alarmId,
      deepLink,
      scheduledAt: alarm.scheduledAt.toISOString(),
    },
  };
}

export function nextScheduledAt(
  alarm: SharedAlarmInput,
  after: Date,
): Date | null {
  if (alarm.repeat === "once") {
    return null;
  }

  const zone = alarm.localTimeZone.trim() || "UTC";
  const scheduled = DateTime.fromJSDate(alarm.scheduledAt, {zone});
  const baseline = DateTime.fromJSDate(after, {zone});
  const wallClock = {
    hour: scheduled.hour,
    minute: scheduled.minute,
    second: scheduled.second,
    millisecond: scheduled.millisecond,
  };

  if (alarm.repeat === "daily") {
    let candidate = baseline.set(wallClock);
    if (candidate <= baseline) {
      candidate = candidate.plus({days: 1});
    }
    return candidate.toUTC().toJSDate();
  }

  const days = normalizeRepeatDays(alarm.repeatDays);
  if (days.length === 0) {
    return null;
  }

  for (let offset = 0; offset <= 7; offset += 1) {
    const day = baseline.plus({days: offset});
    if (!days.includes(day.weekday % 7)) {
      continue;
    }
    const candidate = day.set(wallClock);
    if (candidate > baseline) {
      return candidate.toUTC().toJSDate();
    }
  }

  return null;
}

export function deliveryLogsForMissingTokens(
  recipients: readonly string[],
  tokenRecords: readonly PushTokenRecord[],
): DeliveryLogEntry[] {
  const usersWithTokens = new Set(tokenRecords.map((record) => record.uid));
  return recipients
    .filter((uid) => !usersWithTokens.has(uid))
    .map((uid) => ({uid, status: "no_token"}));
}

export function chunkTokens(
  tokens: readonly PushTokenRecord[],
  chunkSize = 500,
): PushTokenRecord[][] {
  const chunks: PushTokenRecord[][] = [];
  for (let index = 0; index < tokens.length; index += chunkSize) {
    chunks.push(tokens.slice(index, index + chunkSize));
  }
  return chunks;
}

function normalizeRepeatDays(repeatDays: readonly number[]): number[] {
  return [...new Set(repeatDays.filter((day) => day >= 0 && day <= 6))].sort();
}
