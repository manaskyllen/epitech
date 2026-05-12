import 'package:inspiria/core/model/favorite_model.dart';

class FavoriteResponce {

  FavoriteResponce({required this.statusCode, this.favorite, this.errorMessage});

  final FavoriteModel? favorite;
  final int statusCode;
  final String? errorMessage;
}

class FavoriteResponces {
  FavoriteResponces({required this.statusCode, this.favoriteList, this.errorMessage});

  final int statusCode;
  final String? errorMessage;
  final List<FavoriteModel>? favoriteList;
}
