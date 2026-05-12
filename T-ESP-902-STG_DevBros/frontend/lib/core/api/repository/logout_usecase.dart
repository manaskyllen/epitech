import 'package:inspiria/core/api/repository/auth_repository.dart';

class LogoutUseCase {
  LogoutUseCase(this.repository);

  final AuthRepository repository;

  Future<void> call() async {
    return await repository.logout();
  }
}
