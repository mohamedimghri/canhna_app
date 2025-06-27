class Offre {
  final String id;
  final String titre;
  final String? description;
  final double prix;
  final String? imageUrl;
  final bool match;
  final bool hotel;
  final bool transport;
  final bool place;

  Offre({
    required this.id,
    required this.titre,
    this.description,
    required this.prix,
    this.imageUrl,
    required this.match,
    required this.hotel,
    required this.transport,
    required this.place,
  });

  factory Offre.fromJson(Map<String, dynamic> json) => Offre(
        id: json['id'],
        titre: json['titre'],
        description: json['description'],
        prix: (json['prix'] as num).toDouble(),
        imageUrl: json['image_url'],
        match: json['match'] ?? false,
        hotel: json['hotel'] ?? false,
        transport: json['transport'] ?? false,
        place: json['place'] ?? false,
      );
}
