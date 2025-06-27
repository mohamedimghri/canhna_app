import 'package:canhna_app/views/admin/clients_screen.dart';
import 'package:canhna_app/views/admin/guides_screen.dart';
import 'package:canhna_app/views/admin/offres_screen.dart';
import 'package:canhna_app/views/admin/profile_admin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants.dart';

void main() {
  runApp(DashboardAdmin());
}

class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({super.key});

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  int _selectedIndex = 0;
  final screens = [
    OffresScreen(),
    GuidesScreen(),
    ClientsScreen(),
    ProfileAdmin(),
  ];
  void _navigation(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: screens.elementAt(_selectedIndex),
        bottomNavigationBar: buildBottomNavigationBar(),
      ),
    );
  }

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      onTap: _navigation,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primaryColor,
      selectedIconTheme: IconThemeData(color: primaryColor),
      elevation: 0.0,
      currentIndex: _selectedIndex,
      items: [
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/offer.svg',
            width: 30,
            height: 30,
          ),
          label: 'Offres',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/guide.svg',
            width: 30,
            height: 30,
          ),
          label: 'Guides',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/people.svg',
            width: 30,
            height: 30,
          ),
          label: 'Clients',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/profile.svg',
            width: 30,
            height: 30,
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}
