import 'package:inspiria/core/api/entity/user_entity.dart';
import 'package:inspiria/core/api/repository/auth_repository.dart';

class LoginUseCase {
  LoginUseCase(this.repository);

  final AuthRepository repository;

  Future<UserEntity> call(String email, String password) async {
    return await repository.login(email, password);
  }
}
