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

  final List<Widget> screens = [
    const MatchesScreen(),
    const HotelsScreen(),
    const TransportScreen(),
    const PlacesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: screens.elementAt(_selectedIndex),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: BottomNavigationBar(
        onTap: _navigateBottomBar,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        selectedIconTheme: const IconThemeData(size: 28),
        unselectedIconTheme: const IconThemeData(size: 26),
        elevation: 0,
        currentIndex: _selectedIndex,
        items: [
          _buildBottomNavItem(
            iconPath: 'assets/icons/match.svg',
            label: 'Matches',
            isSelected: _selectedIndex == 0,
          ),
          _buildBottomNavItem(
            iconPath: 'assets/icons/hotels.svg',
            label: 'Hotels',
            isSelected: _selectedIndex == 1,
          ),
          _buildBottomNavItem(
            iconPath: 'assets/icons/bus.svg',
            label: 'Transport',
            isSelected: _selectedIndex == 2,
          ),
          _buildBottomNavItem(
            iconPath: 'assets/icons/location.svg',
            label: 'Places',
            isSelected: _selectedIndex == 3,
          ),
          _buildBottomNavItem(
            iconPath: 'assets/icons/profile.svg',
            label: 'Profile',
            isSelected: _selectedIndex == 4,
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavItem({
    required String iconPath,
    required String label,
    required bool isSelected,
  }) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: SvgPicture.asset(
          iconPath,
          width: 24,
          height: 24,
          color: isSelected ? primaryColor : Colors.grey,
        ),
      ),
      label: label,
    );
  }
}