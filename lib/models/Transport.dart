class Transport {
  final String id;
  final String type;
  final String prix;
  final String? description;
  final String? imageUrl;

  Transport({
    required this.id,
    required this.type,
    required this.prix,
    this.description,
    this.imageUrl,
  });

  factory Transport.fromJson(Map<String, dynamic> json) => Transport(
        id: json['id'],
        type: json['type'],
        prix: json['prix'],
        description: json['description'],
        imageUrl: json['image_url'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'prix': prix,
        'description': description,
        'image_url': imageUrl,
      };
}
