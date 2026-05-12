import 'package:inspiria/core/model/clothing_material_model.dart';

class ClothingMaterialResponce {

  ClothingMaterialResponce({required this.statusCode, this.clothingMaterial, this.errorMessage});

  final ClothingMaterialModel? clothingMaterial;
  final int statusCode;
  final String? errorMessage;
}


class  ClothingMaterialResponces{
  ClothingMaterialResponces({required this.statusCode, this.clothingMaterials, this.errorMessage});

  final List<ClothingMaterialModel>? clothingMaterials;
  final int statusCode;
  final String? errorMessage;
}