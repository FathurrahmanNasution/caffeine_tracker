class DrinkModel {
  final String id;
  final String name;
  final String imageUrl;
  final double caffeineinMg;
  final int standardVolume;
  final String information;
  bool isFavorite;

  DrinkModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.caffeineinMg,
    required this.standardVolume,
    required this.information,
    this.isFavorite = false,
  });

  factory DrinkModel.fromMap(Map<String, dynamic> map, String documentId) {
    return DrinkModel(
      id: documentId,
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      caffeineinMg: (map['caffeineinMg'] ?? 0),
      standardVolume: map['standardVolume'] ?? 0,
      information: map['information'] ?? '',
      // isFavorite tidak lagi dari map
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'caffeineinMg': caffeineinMg,
      'standardVolume': standardVolume,
      'information': information,
      // Tidak simpan isFavorite di sini
    };
  }
}