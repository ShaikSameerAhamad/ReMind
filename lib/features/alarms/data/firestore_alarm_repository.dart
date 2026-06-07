import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/alarm_repository.dart';
import '../domain/shared_alarm.dart';

final class FirestoreAlarmRepository implements AlarmRepository {
  const FirestoreAlarmRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Stream<List<SharedAlarm>> watchGroupAlarms(String groupId) {
    return _alarmsRef(groupId)
        .orderBy('status')
        .orderBy('scheduledAt')
        .limit(50)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(_alarmFromFirestore).toList(growable: false));
  }

  @override
  Stream<SharedAlarm?> watchAlarm({
    required String groupId,
    required String alarmId,
  }) {
    return _alarmsRef(groupId).doc(alarmId).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return null;
      }
      return _alarmFromSnapshot(snapshot);
    });
  }

  @override
  Future<void> createAlarm(SharedAlarm alarm) async {
    final batch = _firestore.batch();
    batch.set(_alarmsRef(alarm.groupId).doc(alarm.id), _alarmToFirestore(alarm),
        SetOptions(merge: true));
    batch.set(
      _firestore.collection('groups').doc(alarm.groupId),
      {
        'updatedAt': FieldValue.serverTimestamp(),
        'lastActivityAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  @override
  Future<void> dismissAlarm(AlarmDismissal dismissal) async {
    await _alarmsRef(dismissal.groupId).doc(dismissal.alarmId).set(
      {
        'dismissals': {
          dismissal.dismissedBy: Timestamp.fromDate(dismissal.dismissedAt),
        },
        'updatedAt': Timestamp.fromDate(dismissal.dismissedAt),
      },
      SetOptions(merge: true),
    );
  }

  CollectionReference<Map<String, dynamic>> _alarmsRef(String groupId) {
    return _firestore.collection('groups').doc(groupId).collection('alarms');
  }

  Map<String, Object?> _alarmToFirestore(SharedAlarm alarm) {
    return {
      'title': alarm.title,
      'message': alarm.message,
      'createdBy': alarm.createdBy,
      'scheduledAt': Timestamp.fromDate(alarm.scheduledAt),
      'localTimeZone': alarm.localTimeZone,
      'repeat': alarm.repeat.name,
      'repeatDays': alarm.repeatDays,
      'recipients': alarm.recipients,
      'status': alarm.status.name,
      'deliveryLog': const <Object?>[],
      'createdAt': Timestamp.fromDate(alarm.createdAt),
      'updatedAt': Timestamp.fromDate(alarm.updatedAt),
      'lastTriggeredAt': alarm.lastTriggeredAt == null
          ? null
          : Timestamp.fromDate(alarm.lastTriggeredAt!),
      'dismissals': alarm.dismissals.map(
        (userId, dismissedAt) =>
            MapEntry(userId, Timestamp.fromDate(dismissedAt)),
      ),
    };
  }

  SharedAlarm _alarmFromFirestore(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot) {
    return _alarmFromSnapshot(snapshot);
  }

  SharedAlarm _alarmFromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? const <String, Object?>{};
    return SharedAlarm(
      id: snapshot.id,
      groupId: snapshot.reference.parent.parent?.id ?? '',
      title: data['title'] as String? ?? 'Shared alarm',
      message: data['message'] as String?,
      createdBy: data['createdBy'] as String? ?? '',
      scheduledAt: _dateFromFirestore(data['scheduledAt']),
      localTimeZone: data['localTimeZone'] as String? ?? 'UTC',
      repeat: _enumByName(AlarmRepeat.values, data['repeat'], AlarmRepeat.once),
      repeatDays: _intList(data['repeatDays']),
      recipients: _stringList(data['recipients']),
      status: _enumByName(
          AlarmStatus.values, data['status'], AlarmStatus.scheduled),
      createdAt: _dateFromFirestore(data['createdAt']),
      updatedAt: _dateFromFirestore(data['updatedAt']),
      lastTriggeredAt: _nullableDateFromFirestore(data['lastTriggeredAt']),
      dismissals: _dismissalsFromFirestore(data['dismissals']),
    );
  }

  T _enumByName<T extends Enum>(List<T> values, Object? value, T fallback) {
    if (value is! String) {
      return fallback;
    }
    for (final item in values) {
      if (item.name == value) {
        return item;
      }
    }
    return fallback;
  }

  List<String> _stringList(Object? value) {
    if (value is! List) {
      return const [];
    }
    return value.whereType<String>().toList(growable: false);
  }

  List<int> _intList(Object? value) {
    if (value is! List) {
      return const [];
    }
    return value
        .whereType<num>()
        .map((value) => value.toInt())
        .toList(growable: false);
  }

  Map<String, DateTime> _dismissalsFromFirestore(Object? value) {
    if (value is! Map) {
      return const {};
    }
    final dismissals = <String, DateTime>{};
    for (final entry in value.entries) {
      if (entry.key is String) {
        dismissals[entry.key as String] = _dateFromFirestore(entry.value);
      }
    }
    return dismissals;
  }

  DateTime _dateFromFirestore(Object? value) {
    return _nullableDateFromFirestore(value) ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }

  DateTime? _nullableDateFromFirestore(Object? value) {
    return switch (value) {
      final Timestamp timestamp => timestamp.toDate().toUtc(),
      final DateTime date => date.toUtc(),
      _ => null,
    };
  }
}
