import 'package:canhna_app/views/guide/profiel_guide.dart';
import 'package:flutter/material.dart';
import 'package:canhna_app/views/client/profile_screen.dart';
import 'dashboard_guide.dart';

class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  int _selectedIndex = 0;
  bool _isGuideApproved = true; // Should come from Supabase in real implementation

  // Screens accessible to the guide
  final List<Widget> _screens = [
    const DashboardGuide(),
    const ProfileGuideScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildMainContent(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildMainContent() {
    if (!_isGuideApproved) {
      return _buildPendingApprovalScreen();
    }
    return _screens[_selectedIndex];
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _navigateBottomBar,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue[800],
      unselectedItemColor: Colors.grey[600],
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  Widget _buildPendingApprovalScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_top,
              size: 60,
              color: Colors.orange[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Application Under Review',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your guide application is being reviewed by our team. '
              'You will receive a notification once approved.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                setState(() {
                  _selectedIndex = 0;
                });
              },
              child: const Text(
                'Go to Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateBottomBar(int index) {
    if (_isGuideApproved || index == 0) {
      setState(() {
        _selectedIndex = index;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please complete your guide registration first'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('You have no new notifications at this time.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}