class Equipe {
  final String id;
  final String name;
  final String? imageUrl;

  Equipe({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  factory Equipe.fromJson(Map<String, dynamic> json) => Equipe(
        id: json['id'] as String,
        name: json['name'] as String,
        imageUrl: json['image_url'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image_url': imageUrl,
      };
}
