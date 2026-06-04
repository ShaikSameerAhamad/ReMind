sealed class ValidationResult {
  const ValidationResult();
}

final class Valid extends ValidationResult {
  const Valid();

  @override
  bool operator ==(Object other) => other is Valid;

  @override
  int get hashCode => 1;
}

final class Invalid extends ValidationResult {
  const Invalid(this.message);

  final String message;

  @override
  bool operator ==(Object other) => other is Invalid && other.message == message;

  @override
  int get hashCode => message.hashCode;
}

abstract final class ReMindValidators {
  static ValidationResult secureUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null || uri.host.isEmpty) {
      return const Invalid('Enter a valid link.');
    }
    if (uri.scheme != 'https') {
      return const Invalid('Use a secure https link.');
    }
    return const Valid();
  }

  static ValidationResult taskTitle(String value) {
    return _requiredBounded(
      value,
      emptyMessage: 'Task title is required.',
      maxLength: 120,
      tooLongMessage: 'Task title must be 120 characters or less.',
    );
  }

  static ValidationResult groupName(String value) {
    return _requiredBounded(
      value,
      emptyMessage: 'Group name is required.',
      maxLength: 80,
      tooLongMessage: 'Group name must be 80 characters or less.',
    );
  }

  static ValidationResult alarmRecipients(List<String> recipients) {
    if (recipients.isEmpty) {
      return const Invalid('Choose at least one group member.');
    }
    if (recipients.any((recipient) => recipient.trim().isEmpty)) {
      return const Invalid('Alarm recipients must be valid group members.');
    }
    return const Valid();
  }

  static ValidationResult _requiredBounded(
    String value, {
    required String emptyMessage,
    required int maxLength,
    required String tooLongMessage,
  }) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return Invalid(emptyMessage);
    }
    if (trimmed.length > maxLength) {
      return Invalid(tooLongMessage);
    }
    return const Valid();
  }
}
