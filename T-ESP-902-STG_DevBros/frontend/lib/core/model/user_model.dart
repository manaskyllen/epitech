class UserModel {

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      firstname: json['firstname'] as String,
      lastname: json['lastname'] as String,
      email: json['email'] as String,
      password: json['password'] as String?,
      otp: json['otp'] as String?,
      otpGeneratedAt: json['otpGeneratedAt'] != null 
        ? DateTime.parse(json['otpGeneratedAt'].toString()) 
        : null,
    );
  }

  UserModel({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    this.sso,
    this.profilePictureUrl,
    this.isActif = true,
    this.newsletter = false,
    this.password,
    this.otp,
    this.otpGeneratedAt,
    this.rememberToken,
  });

  final int id;
  final String firstname;
  final String lastname;
  final String email;
  final String? sso;
  final String? profilePictureUrl;
  final bool? isActif;
  final bool? newsletter;
  final String? rememberToken;

  // Champs cachés, à ne pas exposer dans la sérialisation
  final String? password;
  final String? otp;
  final DateTime? otpGeneratedAt;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'sso': sso,
      'profilePictureUrl': profilePictureUrl,
      'isActif': isActif,
      'newsletter': newsletter,
    };
    // Les champs cachés ne sont pas inclus dans la sérialisation
    return data;
  }
}
