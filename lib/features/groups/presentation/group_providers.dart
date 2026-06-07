import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../data/unavailable_group_repository.dart';
import '../domain/create_group.dart';
import '../domain/group_models.dart';
import '../domain/group_repository.dart';

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return const UnavailableGroupRepository();
});

final createGroupProvider = Provider<CreateGroup>((ref) {
  return CreateGroup(
    repository: ref.watch(groupRepositoryProvider),
    now: DateTime.now,
    idGenerator: _newGroupId,
  );
});

final groupCreationControllerProvider =
    AsyncNotifierProvider<GroupCreationController, Group?>(GroupCreationController.new);

final class GroupCreationController extends AsyncNotifier<Group?> {
  @override
  Group? build() => null;

  Future<CreateGroupResult> create({required String name}) async {
    state = const AsyncLoading();
    final session = await ref.read(authControllerProvider.future);
    final result = await ref.read(createGroupProvider)(session: session, name: name);
    state = switch (result) {
      CreateGroupSuccess(:final group) => AsyncData(group),
      CreateGroupFailure() => const AsyncData(null),
    };
    return result;
  }
}

String _newGroupId() {
  final timestamp = DateTime.now().toUtc().microsecondsSinceEpoch;
  final random = Random.secure();
  final suffix = List.generate(6, (_) => random.nextInt(36).toRadixString(36)).join();
  return 'group-$timestamp-$suffix';
}
