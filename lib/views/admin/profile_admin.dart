import 'package:canhna_app/services/auth/auth_service.dart';
import 'package:canhna_app/views/admin/edit_profile_admin.dart';
import 'package:canhna_app/views/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileAdmin extends StatefulWidget {
  const ProfileAdmin({super.key});

  @override
  State<ProfileAdmin> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileAdmin> {
  final AuthService _authService = AuthService();
  final supabase = Supabase.instance.client;

  String name = '';
  String email = '';
  String phone = '';
  String profilePictureUrl = '';
  bool isLoading = true;
  String role = 'Unkown';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final userId = user.id;
    final userEmail = user.email ?? '';

    try {
      final profileResponse = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      final picturePath = profileResponse['image_url'] ?? '';
      String finalProfilePicUrl = '';

      if (picturePath.isNotEmpty) {
        try {
          finalProfilePicUrl = supabase.storage
              .from('profile-images')
              .getPublicUrl(picturePath);
        } catch (e) {
          print('Error generating profile URL: $e');
        }
      }

      setState(() {
        name = profileResponse['name'] ?? 'Unknown';
        phone = profileResponse['phone_number'] ?? 'N/A';
        email = userEmail;
        profilePictureUrl = finalProfilePicUrl;
        role = profileResponse['role'] ?? 'Admin';
        isLoading = false;
      });
    } catch (e) {
      print('Error loading profile: $e');
      setState(() {
        isLoading = false;
      });
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
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.blueAccent,
      elevation: 0,
      title: const Text(
        'Profile',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      iconTheme: const IconThemeData(color: Colors.black),
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
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
                          _buildSectionTitle("Account Settings"),
                          const SizedBox(height: 8),
                          _buildOption(
                            icon: Icons.edit_outlined,
                            text: "Edit Profile",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfileAdmin(),
                              ),
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
  );
}

  Widget _buildHeader() {
  return Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
    child: Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: profilePictureUrl.isNotEmpty
              ? NetworkImage(profilePictureUrl)
              : const NetworkImage('https://via.placeholder.com/150'),
        ),
        const SizedBox(height: 20),
        Text(
          name,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          email,
          style: const TextStyle(
            fontSize: 22,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          phone,
          style: const TextStyle(
            fontSize: 22,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Admin', // Replace with your actual role from database
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade800,
            ),
          ),
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
          color: Color(0xFF6B7280),
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(icon, color: color ?? const Color(0xFF4B5563), size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1F2937),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
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
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Log Out", style: TextStyle(color: Colors.black)),
          content: const Text("Are you sure you want to log out?", 
              style: TextStyle(color: Colors.grey)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _logout();
              },
              child: const Text("Log Out", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}