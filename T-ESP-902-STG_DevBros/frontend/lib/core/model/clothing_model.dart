class ClothingModel {

  ClothingModel({
    this.id,
    this.itemType,
    this.itemSubtype,
    this.color,
    this.size,
    this.style,
    this.season,
    this.gender,
    this.fabric,
    this.texture,
    this.userId,
    this.clothingModelId,
    this.imageName,
  });

   factory ClothingModel.fromJson(Map<String, dynamic> json) {
    return ClothingModel(
      id: json['id'], 
      
      itemType: json['itemType']?.toString(),
      itemSubtype: json['itemSubtype']?.toString(),
      color: json['color']?.toString(),
      size: json['size']?.toString(),
      style: json['style']?.toString(),
      season: json['season']?.toString(),
      gender: json['gender']?.toString(),
      fabric: json['fabric']?.toString(),
      texture: json['texture']?.toString(),
      
      userId: json['user_id'],
      clothingModelId: json['clothingModel_id'],
      
      imageName: json['imageName']?.toString() ?? json['filename']?.toString() ?? json['image_url']?.toString(),
    );
  }

  final int? id;
  final String? itemType;
  final String? itemSubtype;
  final String? color;
  final String? size;
  final String? style;
  final String? season;
  final String? gender;
  final String? fabric;
  final String? texture;
  final int? userId;
  final int? clothingModelId;
  final String? imageName;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemType': itemType,
      'itemSubtype': itemSubtype,
      'color': color,
      'size': size,
      'style': style,
      'season': season,
      'gender': gender,
      'fabric': fabric,
      'texture': texture,
      'user_id': userId,
      'clothingModel_id': clothingModelId,
      'imageName': imageName,
    };
  }
}