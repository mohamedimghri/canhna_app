import 'package:canhna_app/services/auth/auth_service.dart';
import 'package:canhna_app/views/auth/login_screen.dart';
import 'package:canhna_app/views/guide/edit_profiel_guide.dart';
import 'package:canhna_app/views/guide/manage_tour_guide.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileGuideScreen extends StatefulWidget {
  const ProfileGuideScreen({super.key});

  @override
  State<ProfileGuideScreen> createState() => _ProfileGuideScreenState();
}

class _ProfileGuideScreenState extends State<ProfileGuideScreen> {
  final AuthService _authService = AuthService();
  final supabase = Supabase.instance.client;

  String name = 'Loading...';
  String email = '';
  String profileImage = '';
  bool isCertified = false;
  int acceptedToursCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      // Load profile data
      final profileResponse = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      // Count accepted tours - fixed syntax
      final toursResponse = await supabase
          .from('bookingGuid')
          .select()
          .eq('guide_id', user.id)
          .eq('state', 'accepted');

      setState(() {
        name = profileResponse['name'] ?? 'Unknown Guide';
        email = user.email ?? '';
        profileImage = profileResponse['image_url'] ?? '';
        isCertified = profileResponse['is_certified'] ?? false;
        acceptedToursCount = toursResponse.length; // Using length instead of count
        isLoading = false;
      });

      if (profileImage.isNotEmpty) {
        try {
          final publicUrl = supabase.storage
              .from('profile-images')
              .getPublicUrl(profileImage);
          setState(() => profileImage = publicUrl);
        } catch (e) {
          debugPrint('Error getting image URL: $e');
        }
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _logout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverList(
                          delegate: SliverChildListDelegate([
                            _buildHeader(),
                            const SizedBox(height: 24),
                          ]),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              _buildSectionTitle("Guide Actions"),
                              const SizedBox(height: 8),
                              _buildOption(
                                icon: Icons.tour_outlined,
                                text: "Manage Tours",
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ManageToursScreen()),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _buildSectionTitle("Account Settings"),
                              const SizedBox(height: 8),
                              _buildOption(
                                icon: Icons.edit_outlined,
                                text: "Edit Profile",
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const EditProfielGuide()),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _buildOption(
                                icon: Icons.logout_outlined,
                                text: "Log Out",
                                color: Colors.red.shade400,
                                onTap: () => _showLogoutDialog(context),
                              ),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: profileImage.isNotEmpty
                    ? NetworkImage(profileImage)
                    : const NetworkImage('https://randomuser.me/api/portraits/men/32.jpg'),
              ),
              if (isCertified)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.verified, color: Colors.white, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Professional Guide',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            email,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hiking, color: Colors.blue[400], size: 20),
              const SizedBox(width: 4),
              Text(
                '$acceptedToursCount accepted tours',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String text,
    VoidCallback? onTap,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(icon, color: color ?? Colors.grey[700]),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _logout();
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}