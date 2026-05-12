class OutfitItemModel {

  factory OutfitItemModel.fromJson(Map<String, dynamic> json) {
    return OutfitItemModel(
      id: json['id'] as int,
      outfitId: json['outfit_id'] as int,
      clothingId: json['clothing_id'] as int,
    );
  }

  OutfitItemModel({
    required this.id,
    required this.outfitId,
    required this.clothingId,
  });

  final int id;
  final int outfitId;
  final int clothingId;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'outfit_id': outfitId,
      'clothing_id': clothingId,
    };
  }
}
