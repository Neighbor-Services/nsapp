import 'package:flutter_test/flutter_test.dart';
import 'package:nsapp/core/utils/validation_util.dart';

void main() {
  group('ValidationUtil Tests', () {
    test('validateEmail - valid email', () {
      expect(ValidationUtil.validateEmail('test@example.com'), null);
    });

    test('validateEmail - invalid email', () {
      expect(ValidationUtil.validateEmail('invalid-email'), 'Enter a valid email address');
    });

    test('validateEmail - empty email', () {
      expect(ValidationUtil.validateEmail(''), 'Email is required');
    });

    test('validatePassword - short password', () {
      expect(ValidationUtil.validatePassword('short'), 'Password must be at least 8 characters long');
    });

    test('validatePassword - valid password', () {
      expect(ValidationUtil.validatePassword('password123'), null);
    });

    test('validatePhone - valid phone', () {
      expect(ValidationUtil.validatePhone('+1234567890'), null);
    });

    test('validatePhone - invalid phone', () {
      expect(ValidationUtil.validatePhone('123'), 'Enter a valid phone number');
    });

    test('validateRequired - empty value', () {
      expect(ValidationUtil.validateRequired('', 'Field'), 'Field is required');
    });

    test('validateName - valid name', () {
      expect(ValidationUtil.validateName('John Doe'), null);
    });

    test('validateName - invalid name with special chars', () {
      expect(ValidationUtil.validateName('John@Doe'), 'Name should only contain letters and be 2-50 characters long');
    });
  });
}
