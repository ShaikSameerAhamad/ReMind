import 'package:cloud_firestore/cloud_firestore.dart';

import 'push_token_store.dart';

final class FirestorePushTokenStore implements PushTokenStore {
  const FirestorePushTokenStore({required FirebaseFirestore firestore}) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<void> registerToken(PushTokenRecord record) {
    return _firestore.collection('users').doc(record.uid).set(
      {
        'fcmTokens': {
          record.tokenId: {
            'token': record.token,
            'platform': record.platform,
            'updatedAt': FieldValue.serverTimestamp(),
          },
        },
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> unregisterToken(PushTokenRecord record) {
    return _firestore.collection('users').doc(record.uid).set(
      {
        'fcmTokens': {
          record.tokenId: FieldValue.delete(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
