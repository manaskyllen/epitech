class FavoriteModel {

  FavoriteModel({
    required this.id,
    required this.userId,
    required this.clothingId,
    required this.outfitId,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      clothingId: json['clothing_id'] as int,
      outfitId: json['outfit_id'] as int,
    );
  }

  final int id;
  final int userId;
  final int clothingId;
  final int outfitId;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'clothing_id': clothingId,
      'outfit_id': outfitId,
    };
  }
}
