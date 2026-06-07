import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/firebase_bootstrap.dart';
import '../domain/task_repository.dart';
import 'firestore_task_repository.dart';
import 'unavailable_task_repository.dart';

Future<TaskRepository> createDefaultTaskRepository() async {
  final firebase = await FirebaseBootstrap.ensureInitialized();
  if (!firebase.isConfigured) {
    return const UnavailableTaskRepository();
  }
  return FirestoreTaskRepository(firestore: FirebaseFirestore.instance);
}
