import 'package:flutter_test/flutter_test.dart';
import 'package:remind/core/utils/validation.dart';

void main() {
  test('secureUrl accepts only valid https URLs', () {
    expect(ReMindValidators.secureUrl('https://example.com/article'), const Valid());
    expect(ReMindValidators.secureUrl('http://example.com'), const Invalid('Use a secure https link.'));
    expect(ReMindValidators.secureUrl('not a url'), const Invalid('Enter a valid link.'));
  });

  test('task title validation rejects blank and overlong titles', () {
    expect(ReMindValidators.taskTitle('Buy groceries'), const Valid());
    expect(ReMindValidators.taskTitle('   '), const Invalid('Task title is required.'));
    expect(
      ReMindValidators.taskTitle(List.filled(121, 'x').join()),
      const Invalid('Task title must be 120 characters or less.'),
    );
  });

  test('alarm recipients require at least one valid member id', () {
    expect(ReMindValidators.alarmRecipients(['uid-1']), const Valid());
    expect(ReMindValidators.alarmRecipients([]), const Invalid('Choose at least one group member.'));
    expect(
      ReMindValidators.alarmRecipients(['uid-1', ' ']),
      const Invalid('Alarm recipients must be valid group members.'),
    );
  });
}
