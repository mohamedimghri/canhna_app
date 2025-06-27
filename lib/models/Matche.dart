import 'package:canhna_app/models/Equipe.dart';

class Matche {
  final String id;
  final Equipe equipe1;
  final Equipe equipe2;
  final DateTime dateHeure;
  final String stade;
  final String? lienTicket;

  Matche({
    required this.id,
    required this.equipe1,
    required this.equipe2,
    required this.dateHeure,
    required this.stade,
    this.lienTicket,
  });

  factory Matche.fromJson(Map<String, dynamic> json) => Matche(
        id: json['id'] as String,
        equipe1: Equipe.fromJson(json['equipe1']),
        equipe2: Equipe.fromJson(json['equipe2']),
        dateHeure: DateTime.parse(json['dateheure']),
        stade: json['stade'] as String,
        lienTicket: json['lien_ticket'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'equipe1': equipe1.toJson(),
        'equipe2': equipe2.toJson(),
        'dateheure': dateHeure.toIso8601String(),
        'stade': stade,
        'lien_ticket': lienTicket,
      };
}
