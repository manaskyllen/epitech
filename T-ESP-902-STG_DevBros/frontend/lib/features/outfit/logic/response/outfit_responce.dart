import 'package:inspiria/features/outfit/logic/model/outfit_model.dart';

class OutfitResponce {

  OutfitResponce({required this.statusCode, this.outfit, this.errorMessage});

  final OutfitModel? outfit;
  final int statusCode;
  final String? errorMessage;
}

class OutfitResponces {
  OutfitResponces({required this.statusCode, this.outfitList, this.errorMessage});

  final int statusCode;
  final List<OutfitModel>? outfitList;
  final String? errorMessage;
  
}