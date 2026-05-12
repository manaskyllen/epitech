class ClothingMaterialModel {

  ClothingMaterialModel({
    required this.id,
    required this.name,
    required this.material,
    required this.model,
  });

  factory ClothingMaterialModel.fromJson(Map<String, dynamic> json) {
    return ClothingMaterialModel(
      id: json['id'] as int,
      name: json['name'] as String,
      material: json['material'] as String,
      model: json['model'] as String,
    );
  }

  final int id;
  final String name;
  final String material;
  final String model;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'material': material,
      'model': model
    };
  }
}
