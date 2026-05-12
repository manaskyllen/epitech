import 'package:inspiria/core/model/clothing_model.dart';

class ClothingResponce {

  ClothingResponce({required this.statusCode, this.clothing, this.errorMessage});

  final ClothingModel? clothing;
  final int statusCode;
  final String? errorMessage;
}

class ClothingResponces {
  ClothingResponces({required this.statusCode, this.clothingList, this.errorMessage});

  final int statusCode;
  final String? errorMessage;
  final List<ClothingModel>? clothingList;
}