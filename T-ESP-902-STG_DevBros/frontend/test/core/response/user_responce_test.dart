import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/core/model/user_model.dart';
import 'package:inspiria/core/response/user_responce.dart';

void main() {
  group('UserResponce Tests', () {
    test('should initialize with a single user and success status', () {
      final mockUser = UserModel(
        id: 1,
        firstname: 'John',
        lastname: 'Doe',
        email: 'john.doe@example.com',
      );

      final response = UserResponce(
        statusCode: 200,
        user: mockUser,
      );

      expect(response.statusCode, 200);
      expect(response.user, mockUser);
      expect(response.user?.firstname, 'John');
      expect(response.errorMessage, isNull);
    });

    test('should initialize with an error message', () {
      final response = UserResponce(
        statusCode: 401,
        errorMessage: 'Unauthorized',
      );

      expect(response.statusCode, 401);
      expect(response.errorMessage, 'Unauthorized');
      expect(response.user, isNull);
    });
  });

  group('UserResponces (List) Tests', () {
    test('should initialize with a list of users', () {
      final mockList = [
        UserModel(id: 1, firstname: 'Alice', lastname: 'Test', email: 'alice@test.com'),
        UserModel(id: 2, firstname: 'Bob', lastname: 'Test', email: 'bob@test.com'),
      ];

      final response = UserResponces(
        statusCode: 200,
        userList: mockList,
      );

      expect(response.statusCode, 200);
      expect(response.userList?.length, 2);
      expect(response.userList![0].firstname, 'Alice');
    });
  });
}