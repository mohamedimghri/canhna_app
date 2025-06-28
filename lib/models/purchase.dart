import 'package:canhna_app/models/offre.dart';
import 'package:canhna_app/models/profile.dart';

class Purchase {
  final String id;
  final String userId;
  final String offreId;
  final DateTime purchasedAt;
  final Profile? user;
  final Offre? offre;

  Purchase({
    required this.id,
    required this.userId,
    required this.offreId,
    required this.purchasedAt,
    this.user,
    this.offre,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) => Purchase(
        id: json['id'],
        userId: json['user_id'],
        offreId: json['offre_id'],
        purchasedAt: json['purchased_at'] != null
            ? DateTime.parse(json['purchased_at'])
            : DateTime.now(),
        user: json['user'] != null ? Profile.fromJson(json['user']) : null,
        offre: json['offre'] != null ? Offre.fromJson(json['offre']) : null,
      );

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'offre_id': offreId,
      'purchased_at': purchasedAt.toIso8601String(),
    };
  }
}