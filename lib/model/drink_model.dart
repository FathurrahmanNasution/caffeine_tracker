class DrinkModel {
  final String id;
  final String name;
  final String imageUrl;
  final double caffeinePerMl; // mg per mL
  final int standardVolume; // mL
  final String information;
  final bool isFavorite;

  DrinkModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.caffeinePerMl,
    required this.standardVolume,
    required this.information,
    this.isFavorite = false,
  });

  // From Firestore
  factory DrinkModel.fromMap(Map<String, dynamic> map, String documentId) {
    return DrinkModel(
      id: documentId,
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      caffeinePerMl: (map['caffeinePerMl'] ?? 0).toDouble(),
      standardVolume: map['standardVolume'] ?? 0,
      information: map['information'] ?? '',
      isFavorite: map['isFavorite'] ?? false,
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'caffeinePerMl': caffeinePerMl,
      'standardVolume': standardVolume,
      'information': information,
      'isFavorite': isFavorite,
    };
  }
}