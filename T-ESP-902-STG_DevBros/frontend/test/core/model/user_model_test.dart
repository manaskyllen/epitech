import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/core/model/user_model.dart';

void main() {
  group('UserModel Tests', () {
    final mockJson = {
      'id': 1,
      'firstname': 'Jean',
      'lastname': 'Dupont',
      'email': 'jean.dupont@example.com',
      'password': 'hashed_password_123',
      'otp': '123456',
      'otpGeneratedAt': DateTime.now().toIso8601String(),
    };

    test('should create instance from JSON with all fields', () {
      final user = UserModel.fromJson(mockJson);

      expect(user.id, 1);
      expect(user.firstname, 'Jean');
      expect(user.lastname, 'Dupont');
      expect(user.email, 'jean.dupont@example.com');
      expect(user.password, 'hashed_password_123');
      expect(user.otp, '123456');
    });

    test('toJson should NOT include sensitive fields', () {
      final user = UserModel(
        id: 1,
        firstname: 'Jean',
        lastname: 'Dupont',
        email: 'jean.dupont@example.com',
        password: 'secret_password',
        otp: '999999',
      );

      final json = user.toJson();

      // Vérification des champs inclus
      expect(json['id'], 1);
      expect(json['firstname'], 'Jean');
      
      // Vérification de l'exclusion des champs sensibles
      expect(json.containsKey('password'), isFalse);
      expect(json.containsKey('otp'), isFalse);
      expect(json.containsKey('otpGeneratedAt'), isFalse);
    });

    test('should handle optional fields like profilePictureUrl and sso', () {
      final user = UserModel(
        id: 2,
        firstname: 'Alice',
        lastname: 'Inspiria',
        email: 'alice@inspiria.com',
        profilePictureUrl: 'https://avatar.com/alice.png',
        sso: 'google',
        isActif: false,
        newsletter: true,
      );

      final json = user.toJson();

      expect(json['profilePictureUrl'], 'https://avatar.com/alice.png');
      expect(json['sso'], 'google');
      expect(json['isActif'], isFalse);
      expect(json['newsletter'], isTrue);
    });

    test('should use default values for isActif and newsletter', () {
      final user = UserModel(
        id: 3,
        firstname: 'Bob',
        lastname: 'Test',
        email: 'bob@test.com',
      );

      expect(user.isActif, isTrue);
      expect(user.newsletter, isFalse);
    });
  });
}