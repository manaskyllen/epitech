import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/core/api/entity/user_entity.dart';

void main() {
  group('UserEntity', () {
    test('should create UserEntity with id and email', () {
      final user = UserEntity(
        id: 'user-1',
        email: 'john@example.com',
      );

      expect(user, isNotNull);
      expect(user.id, equals('user-1'));
      expect(user.email, equals('john@example.com'));
    });

    test('should have correct id', () {
      final user = UserEntity(
        id: 'user-123',
        email: 'test@example.com',
      );

      expect(user.id, equals('user-123'));
    });

    test('should have correct email', () {
      final user = UserEntity(
        id: 'user-1',
        email: 'jane@example.com',
      );

      expect(user.email, equals('jane@example.com'));
    });

    test('should support equality comparison', () {
      final user1 = UserEntity(id: 'user-1', email: 'test@example.com');
      final user2 = UserEntity(id: 'user-1', email: 'test@example.com');
      final user3 = UserEntity(id: 'user-2', email: 'other@example.com');

      expect(user1, equals(user2));
      expect(user1, isNot(equals(user3)));
    });

    test('should have same hash for equal entities', () {
      final user1 = UserEntity(id: 'user-1', email: 'test@example.com');
      final user2 = UserEntity(id: 'user-1', email: 'test@example.com');

      expect(user1.hashCode, equals(user2.hashCode));
    });

    test('should have different hash for different entities', () {
      final user1 = UserEntity(id: 'user-1', email: 'test1@example.com');
      final user2 = UserEntity(id: 'user-1', email: 'test2@example.com');

      expect(user1.hashCode, isNot(equals(user2.hashCode)));
    });

    test('should identify identical objects', () {
      final user1 = UserEntity(id: 'user-1', email: 'test@example.com');
      final user2 = user1;

      expect(user1, equals(user2));
    });

    test('should handle long email addresses', () {
      const longEmail = 'very.long.email.address.with.many.parts@subdomain.example.co.uk';
      final user = UserEntity(
        id: 'user-1',
        email: longEmail,
      );

      expect(user.email, equals(longEmail));
    });

    test('should handle various ID formats', () {
      const ids = ['1', 'user-123', 'abc-def-ghi', 'UUID-v4-format'];

      for (final id in ids) {
        final user = UserEntity(id: id, email: 'test@example.com');
        expect(user.id, equals(id));
      }
    });

    test('should not be equal to non-UserEntity objects', () {
      final user = UserEntity(id: 'user-1', email: 'test@example.com');
      const otherObject = 'not a user';

      expect(user, isNot(equals(otherObject)));
    });

    test('should allow multiple users with different emails', () {
      final user1 = UserEntity(id: 'user-1', email: 'user1@example.com');
      final user2 = UserEntity(id: 'user-1', email: 'user2@example.com');

      expect(user1, isNot(equals(user2)));
    });

    test('should allow multiple users with different IDs', () {
      final user1 = UserEntity(id: 'user-1', email: 'test@example.com');
      final user2 = UserEntity(id: 'user-2', email: 'test@example.com');

      expect(user1, isNot(equals(user2)));
    });
  });
}
