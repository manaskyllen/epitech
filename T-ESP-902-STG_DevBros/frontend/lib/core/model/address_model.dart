class AddressModel {

  AddressModel({
    required this.id,
    required this.street1,
    required this.street2,
    required this.city,
    required this.zipCode,
    required this.country,
    required this.userId,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as int,
      street1: json['street1'] as String,
      street2: json['street2'] as String,
      city: json['city'] as String,
      zipCode: json['zipCode'] as String,
      country: json['country'] as String,
      userId: json['user_id'] as int,
    );
  }

  final int id;
  final String street1;
  final String street2;
  final String city;
  final String zipCode;
  final String country;
  final int userId;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'street1': street1,
      'street2': street2,
      'city': city,
      'zipCode': zipCode,
      'country': country,
      'user_id': userId,
    };
  }
}
