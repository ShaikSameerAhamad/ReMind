enum AuthSessionKind { signedOut, guest, signedIn }

final class AuthProfile {
  const AuthProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.avatarUrl,
  });

  final String uid;
  final String? email;
  final String displayName;
  final String? avatarUrl;
}

final class AuthSession {
  const AuthSession._({
    required this.kind,
    required this.profile,
    required this.guestDeviceId,
    required this.shouldPromptGuestMigration,
  });

  const AuthSession.signedOut()
      : this._(
          kind: AuthSessionKind.signedOut,
          profile: null,
          guestDeviceId: null,
          shouldPromptGuestMigration: false,
        );

  factory AuthSession.guest({required String deviceId}) {
    return AuthSession._(
      kind: AuthSessionKind.guest,
      profile: null,
      guestDeviceId: deviceId,
      shouldPromptGuestMigration: false,
    );
  }

  factory AuthSession.signedIn({
    required AuthProfile profile,
    bool shouldPromptGuestMigration = false,
  }) {
    return AuthSession._(
      kind: AuthSessionKind.signedIn,
      profile: profile,
      guestDeviceId: null,
      shouldPromptGuestMigration: shouldPromptGuestMigration,
    );
  }

  final AuthSessionKind kind;
  final AuthProfile? profile;
  final String? guestDeviceId;
  final bool shouldPromptGuestMigration;

  bool get canUseCloud => kind == AuthSessionKind.signedIn;

  String? get ownerId {
    return switch (kind) {
      AuthSessionKind.signedOut => null,
      AuthSessionKind.guest => 'guest:$guestDeviceId',
      AuthSessionKind.signedIn => profile!.uid,
    };
  }

  String get displayName {
    return switch (kind) {
      AuthSessionKind.signedOut => 'Signed out',
      AuthSessionKind.guest => 'Guest',
      AuthSessionKind.signedIn => profile!.displayName,
    };
  }
}
