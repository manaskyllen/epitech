class SuitcaseModel {

  factory SuitcaseModel.fromJson(Map<String, dynamic> json) {
    return SuitcaseModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()),

      name: (json['name'] as String?) ?? '',

      departure_date: json['departure_date'] != null
          ? DateTime.parse(json['departure_date'].toString())
          : DateTime.now(),

      end_date: json['end_date'] != null
          ? DateTime.parse(json['end_date'].toString())
          : DateTime.now(),

      destination: (json['destination'] as String?) ?? '',

      user_id: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id'].toString()) ?? 0,

      clothings: json['clothings'] != null
          ? List<Map<String, dynamic>>.from(json['clothings'])
          : [],

      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,

      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
    );
  }
  SuitcaseModel({
    this.id,
    required this.name,
    required this.departure_date,
    required this.end_date,
    required this.destination,
    required this.user_id,
    this.clothings,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final String name;
  final DateTime departure_date;
  final DateTime end_date;
  final String destination;
  final int user_id;
  final List<Map<String, dynamic>>? clothings;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'departure_date': departure_date.toIso8601String(),
      'end_date': end_date.toIso8601String(),
      'destination': destination,
      'user_id': user_id,
      'clothings': clothings ?? [],
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}