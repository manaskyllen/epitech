class OutfitModel {

  OutfitModel({required this.id, required this.userId, required this.name});

  factory OutfitModel.fromJson(Map<String, dynamic> json) {
    // Handle both int and String for IDs (API might send as string)
    int parseId(dynamic id) {
      if (id is int) return id;
      if (id is String) {
        // Try to parse as int first
        try {
          return int.parse(id);
        } catch (e) {
          // If it's a string ID like 'outfit-1', return hash code
          return id.hashCode;
        }
      }
      return 0;
    }

    return OutfitModel(
      id: parseId(json['id']),
      userId: parseId(json['user_id'] ?? 0),
      name: json['name'] as String? ?? '',
    );
  }

  final int id;
  final int userId;
  final String name;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name
    };
  }
}
