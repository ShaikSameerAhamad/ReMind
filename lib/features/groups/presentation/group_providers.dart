import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../data/unavailable_group_repository.dart';
import '../domain/accept_group_invite.dart';
import '../domain/create_group.dart';
import '../domain/create_group_invite.dart';
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

final createGroupInviteProvider = Provider<CreateGroupInvite>((ref) {
  return CreateGroupInvite(
    repository: ref.watch(groupRepositoryProvider),
    now: DateTime.now,
    codeGenerator: _newInviteCode,
  );
});

final acceptGroupInviteProvider = Provider<AcceptGroupInvite>((ref) {
  return AcceptGroupInvite(
    repository: ref.watch(groupRepositoryProvider),
    now: DateTime.now,
  );
});

final groupCreationControllerProvider =
    AsyncNotifierProvider<GroupCreationController, Group?>(
        GroupCreationController.new);

final class GroupCreationController extends AsyncNotifier<Group?> {
  @override
  Group? build() => null;

  Future<CreateGroupResult> create({required String name}) async {
    state = const AsyncLoading();
    final session = await ref.read(authControllerProvider.future);
    final result =
        await ref.read(createGroupProvider)(session: session, name: name);
    state = switch (result) {
      CreateGroupSuccess(:final group) => AsyncData(group),
      CreateGroupFailure() => const AsyncData(null),
    };
    return result;
  }
}

final groupInviteControllerProvider =
    AsyncNotifierProvider<GroupInviteController, GroupInvite?>(
        GroupInviteController.new);

final class GroupInviteController extends AsyncNotifier<GroupInvite?> {
  @override
  GroupInvite? build() => null;

  Future<CreateGroupInviteResult> create({
    required String groupId,
    required String? recipientEmail,
  }) async {
    state = const AsyncLoading();
    final session = await ref.read(authControllerProvider.future);
    final result = await ref.read(createGroupInviteProvider)(
      session: session,
      groupId: groupId,
      recipientEmail: recipientEmail,
    );
    state = switch (result) {
      CreateGroupInviteSuccess(:final invite) => AsyncData(invite),
      CreateGroupInviteFailure() => const AsyncData(null),
    };
    return result;
  }
}

final groupInviteAcceptanceControllerProvider =
    AsyncNotifierProvider<GroupInviteAcceptanceController, String?>(
        GroupInviteAcceptanceController.new);

final class GroupInviteAcceptanceController extends AsyncNotifier<String?> {
  @override
  String? build() => null;

  Future<AcceptGroupInviteResult> accept({
    required String groupId,
    required String inviteCode,
  }) async {
    state = const AsyncLoading();
    final session = await ref.read(authControllerProvider.future);
    final result = await ref.read(acceptGroupInviteProvider)(
      session: session,
      groupId: groupId,
      inviteCode: inviteCode,
    );
    state = switch (result) {
      AcceptGroupInviteSuccess(:final groupId) => AsyncData(groupId),
      AcceptGroupInviteFailure() => const AsyncData(null),
    };
    return result;
  }
}

String _newGroupId() {
  final timestamp = DateTime.now().toUtc().microsecondsSinceEpoch;
  final random = Random.secure();
  final suffix =
      List.generate(6, (_) => random.nextInt(36).toRadixString(36)).join();
  return 'group-$timestamp-$suffix';
}

String _newInviteCode() {
  final random = Random.secure();
  const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  return List.generate(8, (_) => alphabet[random.nextInt(alphabet.length)])
      .join();
}
