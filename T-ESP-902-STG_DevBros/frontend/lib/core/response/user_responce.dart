import 'package:inspiria/core/model/user_model.dart';

class UserResponce {

  UserResponce({required this.statusCode, this.user, this.errorMessage});

  final UserModel? user;
  final int statusCode;
  final String? errorMessage;
}

class UserResponces {
  UserResponces({required this.statusCode, this.userList, this.errorMessage});

  final int statusCode;
  final String? errorMessage;
  final List<UserModel>? userList;
}
