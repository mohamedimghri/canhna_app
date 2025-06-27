
import 'package:canhna_app/views/client/hotels_screen.dart';
import 'package:canhna_app/views/client/matches_screen.dart';
import 'package:canhna_app/views/client/places_screen.dart';
import 'package:canhna_app/views/client/profile_screen.dart';
import 'package:canhna_app/views/client/transport_screen.dart';
import 'package:canhna_app/views/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TraineeScreen extends StatefulWidget {
  const TraineeScreen({super.key});
  @override
  State<TraineeScreen> createState() => _TraineeScreenState();
}

class _TraineeScreenState extends State<TraineeScreen> {
  int _selectedIndex = 0;

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final screens = [
    MatchesScreen(),
    HotelsScreen(),
    TransportScreen(),
    PlacesScreen(),
    ProfileScreen(),
  ];
  final appBars = [
    AppBar(),
     AppBar(),
      AppBar(),
       AppBar(),
        AppBar(),
   
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:appBars.elementAt(_selectedIndex),
      backgroundColor: Colors.white,
      
      bottomNavigationBar: buildBottomNavigationBar(),
      body: screens.elementAt(_selectedIndex),
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
          icon: SvgPicture.asset('icons/match.svg', width: 30, height: 30),
          label: 'Matchs',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset('icons/hotels.svg', width: 30, height: 30),
          label: 'Hotels',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset('icons/bus.svg', width: 30, height: 30),
          label: 'Transports',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset('icons/location.svg', width: 30, height: 30),
          label: 'Places',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset('icons/profile.svg', width: 30, height: 30),
          label: 'Profile',
        ),
      ],
    );
  }
}
