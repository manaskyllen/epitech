class AuthResponseModel {
  AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.email,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      userId: json['userId'],
      email: json['email'],
    );
  }

  final String accessToken;
  final String refreshToken;
  final String userId;
  final String email;

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'userId': userId,
      'email': email,
    };
  }
}
