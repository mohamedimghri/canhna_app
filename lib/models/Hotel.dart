class Hotel {
  final String id;
  final String nom;
  final String lieu;
  final double prixParNuit;
  final String? lienHotel;
  final String? imageUrl;

  Hotel({
    required this.id,
    required this.nom,
    required this.lieu,
    required this.prixParNuit,
    this.lienHotel,
    this.imageUrl,
  });

  // Convertir depuis JSON (depuis Supabase)
  factory Hotel.fromJson(Map<String, dynamic> json) => Hotel(
        id: json['id'] as String,
        nom: json['nom'] as String,
        lieu: json['lieu'] as String,
        prixParNuit: (json['prix_par_nuit'] as num).toDouble(),
        lienHotel: json['lien_hotel'] as String?,
        imageUrl: json['image_url'],
        
      );

  // Convertir vers JSON (pour insert/update)
  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'lieu': lieu,
        'prix_par_nuit': prixParNuit,
        'lien_hotel': lienHotel,
        'image_url': imageUrl,
      };
}
