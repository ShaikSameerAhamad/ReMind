import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/group_task.dart';
import '../domain/task_repository.dart';

final class FirestoreTaskRepository implements TaskRepository {
  const FirestoreTaskRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Stream<List<GroupTask>> watchGroupTasks(String groupId) {
    return _tasksRef(groupId)
        .orderBy('status')
        .orderBy('dueAt')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(_taskFromFirestore).toList(growable: false));
  }

  @override
  Stream<GroupTask?> watchTask({
    required String groupId,
    required String taskId,
  }) {
    return _tasksRef(groupId).doc(taskId).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return null;
      }
      return _taskFromFirestore(snapshot);
    });
  }

  @override
  Future<void> createTask(GroupTask task) async {
    final batch = _firestore.batch();
    batch.set(_tasksRef(task.groupId).doc(task.id), _taskToFirestore(task),
        SetOptions(merge: true));
    batch.set(
      _firestore.collection('groups').doc(task.groupId),
      {
        'updatedAt': FieldValue.serverTimestamp(),
        'lastActivityAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  @override
  Future<void> completeTask(GroupTaskCompletion completion) async {
    final batch = _firestore.batch();
    batch.set(
      _tasksRef(completion.groupId).doc(completion.taskId),
      {
        'status': GroupTaskStatus.completed.name,
        'completedAt': Timestamp.fromDate(completion.completedAt),
        'completedBy': completion.completedBy,
        'updatedAt': Timestamp.fromDate(completion.completedAt),
        'updatedBy': completion.completedBy,
      },
      SetOptions(merge: true),
    );
    batch.set(
      _firestore.collection('groups').doc(completion.groupId),
      {
        'updatedAt': FieldValue.serverTimestamp(),
        'lastActivityAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  @override
  Future<void> addComment(TaskComment comment) async {
    final batch = _firestore.batch();
    batch.set(
      _tasksRef(comment.groupId).doc(comment.taskId),
      {
        'comments': FieldValue.arrayUnion([_commentToFirestore(comment)]),
        'updatedAt': Timestamp.fromDate(comment.createdAt),
        'updatedBy': comment.authorId,
      },
      SetOptions(merge: true),
    );
    batch.set(
      _firestore.collection('groups').doc(comment.groupId),
      {
        'updatedAt': FieldValue.serverTimestamp(),
        'lastActivityAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  CollectionReference<Map<String, dynamic>> _tasksRef(String groupId) {
    return _firestore.collection('groups').doc(groupId).collection('tasks');
  }

  Map<String, Object?> _taskToFirestore(GroupTask task) {
    return {
      'title': task.title,
      'notes': task.notes,
      'createdBy': task.createdBy,
      'assignedTo': task.assignedTo,
      'priority': task.priority.name,
      'status': task.status.name,
      'createdAt': Timestamp.fromDate(task.createdAt),
      'updatedAt': Timestamp.fromDate(task.updatedAt),
      'dueAt': task.dueAt == null ? null : Timestamp.fromDate(task.dueAt!),
      'completedAt': task.completedAt == null
          ? null
          : Timestamp.fromDate(task.completedAt!),
      'completedBy': task.completedBy,
      'updatedBy': task.createdBy,
      'comments':
          task.comments.map(_commentToFirestore).toList(growable: false),
    };
  }

  GroupTask _taskFromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return _taskFromData(
        snapshot.id,
        snapshot.reference.parent.parent?.id ?? '',
        snapshot.data() ?? const {});
  }

  GroupTask _taskFromData(
      String id, String groupId, Map<String, Object?> data) {
    return GroupTask(
      id: id,
      groupId: groupId,
      title: data['title'] as String? ?? 'Untitled task',
      notes: data['notes'] as String?,
      createdBy: data['createdBy'] as String? ?? '',
      assignedTo: data['assignedTo'] as String?,
      priority: _enumByName(
          GroupTaskPriority.values, data['priority'], GroupTaskPriority.normal),
      status: _enumByName(
          GroupTaskStatus.values, data['status'], GroupTaskStatus.open),
      createdAt: _dateFromFirestore(data['createdAt']),
      updatedAt: _dateFromFirestore(data['updatedAt']),
      dueAt: _nullableDateFromFirestore(data['dueAt']),
      completedAt: _nullableDateFromFirestore(data['completedAt']),
      completedBy: data['completedBy'] as String?,
      updatedBy: data['updatedBy'] as String?,
      comments: _commentsFromFirestore(
        groupId: groupId,
        taskId: id,
        value: data['comments'],
      ),
    );
  }

  Map<String, Object?> _commentToFirestore(TaskComment comment) {
    return {
      'id': comment.id,
      'uid': comment.authorId,
      'displayName': comment.authorName,
      'text': comment.text,
      'timestamp': Timestamp.fromDate(comment.createdAt),
    };
  }

  List<TaskComment> _commentsFromFirestore({
    required String groupId,
    required String taskId,
    required Object? value,
  }) {
    if (value is! List) {
      return const [];
    }
    final comments = <TaskComment>[];
    for (final entry in value) {
      if (entry is! Map) {
        continue;
      }
      final data = entry.cast<String, Object?>();
      comments.add(
        TaskComment(
          groupId: groupId,
          taskId: taskId,
          id: data['id'] as String? ?? '',
          authorId: data['uid'] as String? ?? '',
          authorName: data['displayName'] as String? ?? 'Member',
          text: data['text'] as String? ?? '',
          createdAt: _dateFromFirestore(data['timestamp']),
        ),
      );
    }
    comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return comments;
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
