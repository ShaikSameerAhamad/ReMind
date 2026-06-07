import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/firebase_bootstrap.dart';
import '../domain/group_repository.dart';
import 'firestore_group_repository.dart';
import 'unavailable_group_repository.dart';

Future<GroupRepository> createDefaultGroupRepository() async {
  final firebase = await FirebaseBootstrap.ensureInitialized();
  if (!firebase.isConfigured) {
    return const UnavailableGroupRepository();
  }
  return FirestoreGroupRepository(firestore: FirebaseFirestore.instance);
}
