import 'package:canhna_app/views/admin/dashboard_admin.dart';
import 'package:canhna_app/views/auth/Register_screen.dart';
import 'package:canhna_app/views/auth/login_screen.dart';
import 'package:canhna_app/views/client/oferres_screen.dart';

import 'package:canhna_app/views/client/trainee_screen.dart';
import 'package:canhna_app/views/guide/dashboard_guide.dart';
import 'package:canhna_app/views/guide/guide_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          final userId = session.user.id;

          return FutureBuilder<Map<String, dynamic>>(
            future: _getRoleAndStatus(userId),
            builder: (context, resultSnapshot) {
              if (resultSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final data = resultSnapshot.data;
              if (data == null) {
                return const LoginScreen();
              }

              final role = data['role'] as String?;
              final isActive = data['is_active'] as bool;
              if (!isActive) {
                return Scaffold(
                  backgroundColor: Colors.white,
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Votre compte est désactivé. Veuillez contacter l'administrateur.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await Supabase.instance.client.auth.signOut();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.logout),
                            label: const Text("Se déconnecter"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              if (role == 'admin') {
                return const DashboardAdmin();
              } else if (role == 'client') {
                return FutureBuilder<Map<String, dynamic>>(
                  future: getUserAccessRights(userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final rights = snapshot.data ?? {
                      'match': false,
                      'hotel': false,
                      'transport': false,
                      'place': false,
                      'hasAnyOffer': false,
                    };

                    if (!rights['hasAnyOffer']) {
                      return const OffresScreen();
                    }

                    return TraineeScreen(
                      unlockedMatch: rights['match']!,
                      unlockedHotel: rights['hotel']!,
                      unlockedTransport: rights['transport']!,
                      unlockedPlace: rights['place']!,
                    );
                  },
                );
              } else if (role == 'guide') {
                return const GuideScreen();
              } else {
                return const LoginScreen();
              }
            },
          );
        }

        return const LoginScreen();
      },
    );
  }

  /// Récupère le rôle et le statut actif de l'utilisateur
  Future<Map<String, dynamic>> _getRoleAndStatus(String userId) async {
    final response = await Supabase.instance.client
        .from('profiles')
        .select('role, is_active')
        .eq('id', userId)
        .single();

    return {
      'role': response['role'],
      'is_active': response['is_active'],
    };
  }

  /// Récupère les droits d'accès selon les achats de l'utilisateur
  Future<Map<String, dynamic>> getUserAccessRights(String userId) async {
    final response = await Supabase.instance.client
        .from('purchases')
        .select('offres(match, hotel, transport, place)')
        .eq('user_id', userId);

    bool unlockedMatch = false;
    bool unlockedHotel = false;
    bool unlockedTransport = false;
    bool unlockedPlace = false;

    for (final purchase in response as List) {
      final offre = purchase['offres'];
      if (offre['match'] == true) unlockedMatch = true;
      if (offre['hotel'] == true) unlockedHotel = true;
      if (offre['transport'] == true) unlockedTransport = true;
      if (offre['place'] == true) unlockedPlace = true;
    }

    final hasAnyOffer =
        unlockedMatch || unlockedHotel || unlockedTransport || unlockedPlace;

    return {
      'match': unlockedMatch,
      'hotel': unlockedHotel,
      'transport': unlockedTransport,
      'place': unlockedPlace,
      'hasAnyOffer': hasAnyOffer,
    };
  }
}
