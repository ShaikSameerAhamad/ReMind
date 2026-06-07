import {getFirestore, Timestamp, FieldValue} from "firebase-admin/firestore";
import {getMessaging} from "firebase-admin/messaging";
import {logger} from "firebase-functions";
import {onSchedule} from "firebase-functions/v2/scheduler";

import {
  buildAlarmNotificationPayload,
  chunkTokens,
  deliveryLogsForMissingTokens,
  DeliveryLogEntry,
  nextScheduledAt,
  PushTokenRecord,
  SharedAlarmInput,
} from "./scheduler";

const region = process.env.FUNCTIONS_REGION ?? "asia-south1";
const alarmBatchSize = Number(process.env.ALARM_PROCESS_BATCH_SIZE ?? "100");
const notificationChannelId =
  process.env.ALARM_NOTIFICATION_CHANNEL_ID ?? "remind_general";

export const processSharedAlarms = onSchedule(
  {
    schedule: "every 1 minutes",
    region,
    timeZone: "UTC",
    timeoutSeconds: 540,
    memory: "256MiB",
    maxInstances: 1,
  },
  async () => {
    const firestore = getFirestore();
    const now = new Date();
    const dueSnapshot = await firestore
      .collectionGroup("alarms")
      .where("status", "==", "scheduled")
      .where("scheduledAt", "<=", Timestamp.fromDate(now))
      .orderBy("scheduledAt", "asc")
      .limit(alarmBatchSize)
      .get();

    logger.info("Processing due shared alarms.", {
      dueAlarmCount: dueSnapshot.size,
      now: now.toISOString(),
    });

    for (const alarmSnapshot of dueSnapshot.docs) {
      await processAlarm(alarmSnapshot, now);
    }
  },
);

async function processAlarm(
  alarmSnapshot: FirebaseFirestore.QueryDocumentSnapshot,
  now: Date,
): Promise<void> {
  const groupRef = alarmSnapshot.ref.parent.parent;
  if (!groupRef) {
    logger.warn("Skipping orphaned alarm document.", {
      alarmPath: alarmSnapshot.ref.path,
    });
    return;
  }

  const alarm = parseAlarm({
    alarmId: alarmSnapshot.id,
    groupId: groupRef.id,
    data: alarmSnapshot.data(),
  });
  if (alarm === null) {
    logger.warn("Skipping malformed alarm document.", {
      alarmPath: alarmSnapshot.ref.path,
    });
    return;
  }

  const tokenRecords = await loadRecipientTokens(alarm.recipients);
  const deliveryLogs: DeliveryLogEntry[] = [
    ...deliveryLogsForMissingTokens(alarm.recipients, tokenRecords),
  ];

  for (const tokenChunk of chunkTokens(tokenRecords)) {
    const payload = buildAlarmNotificationPayload(alarm);
    const response = await getMessaging().sendEachForMulticast({
      tokens: tokenChunk.map((record) => record.token),
      notification: payload.notification,
      data: payload.data,
      android: {
        priority: "high",
        notification: {
          channelId: notificationChannelId,
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
      },
    });

    response.responses.forEach((sendResponse, index) => {
      const record = tokenChunk[index];
      if (sendResponse.success) {
        deliveryLogs.push({
          uid: record.uid,
          tokenId: record.tokenId,
          status: "sent",
        });
        return;
      }

      const errorCode = sendResponse.error?.code ?? "messaging/unknown";
      deliveryLogs.push({
        uid: record.uid,
        tokenId: record.tokenId,
        status: "failed",
        errorCode,
      });
    });
  }

  const nextRunAt = nextScheduledAt(alarm, now);
  const firestoreLogs = deliveryLogs.map((entry) => ({
    ...entry,
    timestamp: Timestamp.fromDate(now),
  }));
  const update: Record<string, unknown> = {
    lastTriggeredAt: Timestamp.fromDate(now),
    updatedAt: FieldValue.serverTimestamp(),
  };

  if (firestoreLogs.length > 0) {
    update.deliveryLog = FieldValue.arrayUnion(...firestoreLogs);
  }

  if (nextRunAt === null) {
    update.status = "sent";
  } else {
    update.scheduledAt = Timestamp.fromDate(nextRunAt);
    update.dismissals = {};
  }

  await alarmSnapshot.ref.set(update, {merge: true});

  logger.info("Shared alarm delivery processed.", {
    groupId: alarm.groupId,
    alarmId: alarm.alarmId,
    recipientCount: alarm.recipients.length,
    tokenCount: tokenRecords.length,
    deliveryLogCount: deliveryLogs.length,
    nextRunAt: nextRunAt?.toISOString() ?? null,
  });
}

async function loadRecipientTokens(
  recipients: readonly string[],
): Promise<PushTokenRecord[]> {
  const firestore = getFirestore();
  const userSnapshots = await Promise.all(
    recipients.map((uid) => firestore.collection("users").doc(uid).get()),
  );

  return userSnapshots.flatMap((snapshot) => {
    const uid = snapshot.id;
    const tokens = snapshot.get("fcmTokens");
    if (!tokens || typeof tokens !== "object") {
      return [];
    }

    return Object.entries(tokens as Record<string, unknown>).flatMap(
      ([tokenId, value]) => {
        if (!value || typeof value !== "object") {
          return [];
        }
        const token = (value as Record<string, unknown>).token;
        return typeof token === "string" && token.trim().length > 0
          ? [{uid, tokenId, token}]
          : [];
      },
    );
  });
}

function parseAlarm(params: {
  readonly alarmId: string;
  readonly groupId: string;
  readonly data: FirebaseFirestore.DocumentData;
}): SharedAlarmInput | null {
  const scheduledAt = dateFromFirestore(params.data.scheduledAt);
  const title = stringValue(params.data.title);
  const recipients = stringList(params.data.recipients);
  const repeat = stringValue(params.data.repeat);

  if (scheduledAt === null || title === null || recipients.length === 0) {
    return null;
  }

  return {
    alarmId: params.alarmId,
    groupId: params.groupId,
    title,
    message: stringValue(params.data.message) ?? undefined,
    scheduledAt,
    localTimeZone: stringValue(params.data.localTimeZone) ?? "UTC",
    repeat: repeat === "daily" || repeat === "weekly" ? repeat : "once",
    repeatDays: numberList(params.data.repeatDays),
    recipients,
  };
}

function dateFromFirestore(value: unknown): Date | null {
  if (value instanceof Timestamp) {
    return value.toDate();
  }
  if (value instanceof Date) {
    return value;
  }
  return null;
}

function stringValue(value: unknown): string | null {
  return typeof value === "string" && value.trim().length > 0
    ? value.trim()
    : null;
}

function stringList(value: unknown): string[] {
  if (!Array.isArray(value)) {
    return [];
  }
  return value.filter((item): item is string => typeof item === "string");
}

function numberList(value: unknown): number[] {
  if (!Array.isArray(value)) {
    return [];
  }
  return value
    .filter((item): item is number => typeof item === "number")
    .map((item) => Math.trunc(item));
}
