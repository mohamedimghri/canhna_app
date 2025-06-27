import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'matches_screen.dart';
import 'hotels_screen.dart';
import 'transport_screen.dart';
import 'places_screen.dart';
import 'profile_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants.dart';

class TraineeScreen extends StatefulWidget {
   final bool unlockedMatch;
  final bool unlockedHotel;
  final bool unlockedTransport;
  final bool unlockedPlace;

  const TraineeScreen({
    super.key,
    this.unlockedMatch = false,
    this.unlockedHotel = false,
    this.unlockedTransport = false,
    this.unlockedPlace = false,
  });

  @override
  State<TraineeScreen> createState() => _TraineeScreenState();
}

class _TraineeScreenState extends State<TraineeScreen> {
  int _selectedIndex = 0;
  bool unlockedMatch = false;
  bool unlockedHotel = false;
  bool unlockedTransport = false;
  bool unlockedPlace = false;

  @override
  void initState() {
    super.initState();
    fetchUserAccessRights();
  }

  Future<void> fetchUserAccessRights() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final response = await Supabase.instance.client
        .from('purchases')
        .select('offres(match, hotel, transport, place)')
        .eq('user_id', userId);

    bool hasMatch = false;
    bool hasHotel = false;
    bool hasTransport = false;
    bool hasPlace = false;

    for (final purchase in response as List) {
      final offre = purchase['offres'];
      if (offre['match'] == true) hasMatch = true;
      if (offre['hotel'] == true) hasHotel = true;
      if (offre['transport'] == true) hasTransport = true;
      if (offre['place'] == true) hasPlace = true;
    }

    setState(() {
      unlockedMatch = hasMatch;
      unlockedHotel = hasHotel;
      unlockedTransport = hasTransport;
      unlockedPlace = hasPlace;
    });
  }

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget getCurrentScreen() {
    final screens = [
      unlockedMatch ? const MatchesScreen() : const LockedScreen(type: "Matchs"),
      unlockedHotel ? const HotelsScreen() : const LockedScreen(type: "Hotels"),
      unlockedTransport ? const TransportScreen() : const LockedScreen(type: "Transports"),
      unlockedPlace ? const PlacesListScreen() : const LockedScreen(type: "Places"),
      const ProfileScreen(),
    ];

    return screens[_selectedIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: buildBottomNavigationBar(),
      body: getCurrentScreen(),
    );
  }

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      onTap: _navigateBottomBar,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primaryColor,
      selectedIconTheme: IconThemeData(color: primaryColor),
      elevation: 0.0,
      currentIndex: _selectedIndex,
      items: [
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/icons/match.svg', width: 30, height: 30),
          label: 'Matchs',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/icons/hotels.svg', width: 30, height: 30),
          label: 'Hotels',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/icons/bus.svg', width: 30, height: 30),
          label: 'Transports',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/icons/location.svg', width: 30, height: 30),
          label: 'Places',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/icons/profile.svg', width: 30, height: 30),
          label: 'Profil',
        ),
      ],
    );
  }
}

/// Widget affiché si l'utilisateur n'a pas accès à cette section
class LockedScreen extends StatelessWidget {
  final String type;

  const LockedScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '🔒 Accès non autorisé\nAchetez une offre incluant $type pour y accéder.',
        style: const TextStyle(fontSize: 18),
        textAlign: TextAlign.center,
      ),
    );
  }
}
