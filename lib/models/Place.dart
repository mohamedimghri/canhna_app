class Place {
  final String id;
  final String nom;
  final String? description;
  final String? imageUrl;
  final String lieu;
  final double? latitude;
  final double? longitude;

  Place({
    required this.id,
    required this.nom,
    required this.lieu,
    this.description,
    this.imageUrl,
    this.latitude,
    this.longitude,
  });

  factory Place.fromJson(Map<String, dynamic> json) => Place(
        id: json['id'],
        nom: json['nom'],
        description: json['description'],
        imageUrl: json['image_url'],
        lieu: json['lieu'],
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
      );
}
