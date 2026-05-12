import 'package:inspiria/features/outfit/logic/model/outfit_item_model.dart';

class OutfitItemResponce {

  OutfitItemResponce({required this.statusCode, this.outfitItem, this.errorMessage});

  final OutfitItemModel? outfitItem;
  final int statusCode;
  final String? errorMessage;
}

class OutfitItemResponces {
  OutfitItemResponces({required this.statusCode, this.outfitItemList, this.errorMessage});

  final int statusCode;
  final String? errorMessage;
  final List<OutfitItemModel>? outfitItemList;
}
