import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/firebase_bootstrap.dart';
import '../domain/alarm_repository.dart';
import 'firestore_alarm_repository.dart';
import 'unavailable_alarm_repository.dart';

Future<AlarmRepository> createDefaultAlarmRepository() async {
  final firebase = await FirebaseBootstrap.ensureInitialized();
  if (!firebase.isConfigured) {
    return const UnavailableAlarmRepository();
  }
  return FirestoreAlarmRepository(firestore: FirebaseFirestore.instance);
}
