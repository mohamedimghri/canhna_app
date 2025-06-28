import 'package:canhna_app/models/profile.dart';
import 'package:canhna_app/views/constants.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class GuidesScreen extends StatefulWidget {
  const GuidesScreen({super.key});

  @override
  State<GuidesScreen> createState() => _GuidesScreenState();
}

class _GuidesScreenState extends State<GuidesScreen> {
  final supabase = Supabase.instance.client;
  List<Profile> _guides = [];
  bool _isLoading = true;

  // Spacing constants (8-point grid system)
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // Border radius constants
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;

  // Typography styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.black54,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Colors.black54,
  );

  @override
  void initState() {
    super.initState();
    _fetchGuides();
  }

  Future<void> _fetchGuides() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase
          .from('profiles')
          .select('*')
          .eq('role', 'guide')
          .order('name', ascending: true);

      final data = response as List<dynamic>;
      final guides =
          data.map((json) {
            // Convert image path to public URL if it exists
            if (json['image_url'] != null && json['image_url'].isNotEmpty) {
              json['image_url'] = supabase.storage
                  .from('profile-images')
                  .getPublicUrl(json['image_url']);
            }
            return Profile.fromJson(json);
          }).toList();

      setState(() {
        _guides = guides;
      });
    } catch (e) {
      debugPrint('Error fetching guides: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading guides: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Enhanced delete confirmation dialog
  Future<void> _showDeleteConfirmationDialog(Profile guide) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              const SizedBox(width: spacingS),
              const Text(
                'Delete Guide',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Are you sure you want to delete this guide?',
                  style: bodyLarge,
                ),
                const SizedBox(height: spacingM),
                Container(
                  padding: const EdgeInsets.all(spacingM),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(radiusS),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: primaryColor.withOpacity(0.1),
                        backgroundImage:
                            guide.imageUrl != null && guide.imageUrl!.isNotEmpty
                                ? NetworkImage(guide.imageUrl!)
                                : null,
                        child:
                            guide.imageUrl == null || guide.imageUrl!.isEmpty
                                ? Icon(Icons.person, color: primaryColor)
                                : null,
                      ),
                      const SizedBox(width: spacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              guide.name ?? 'Unknown Guide',
                              style: headingMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (guide.phoneNumber != null)
                              Text(guide.phoneNumber!, style: bodyMedium),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: spacingM),
                Text(
                  'This action cannot be undone.',
                  style: bodyMedium.copyWith(
                    color: Colors.red[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
                padding: const EdgeInsets.symmetric(
                  horizontal: spacingL,
                  vertical: spacingM,
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: spacingL,
                  vertical: spacingM,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radiusS),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteGuide(guide.id);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteGuide(String id) async {
    try {
      await supabase.from('profiles').delete().eq('id', id);
      await _fetchGuides(); // Refresh the list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: spacingS),
                const Text('Guide deleted successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusS),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: spacingS),
                Expanded(child: Text('Error deleting guide: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusS),
            ),
          ),
        );
      }
    }
  }

  void _showGuideDetails(Profile guide) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(radiusL),
                topRight: Radius.circular(radiusL),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Modal handle
                Container(
                  margin: const EdgeInsets.only(top: spacingM),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(spacingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Profile picture
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: primaryColor.withOpacity(0.1),
                              backgroundImage:
                                  guide.imageUrl != null &&
                                          guide.imageUrl!.isNotEmpty
                                      ? NetworkImage(guide.imageUrl!)
                                      : null,
                              child:
                                  guide.imageUrl == null ||
                                          guide.imageUrl!.isEmpty
                                      ? Icon(
                                        Icons.person,
                                        size: 50,
                                        color: primaryColor,
                                      )
                                      : null,
                            ),
                            // Active status indicator
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color:
                                      (guide.isActive ?? false)
                                          ? Colors.green
                                          : Colors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: spacingL),

                        // Name
                        Text(
                          guide.name ?? 'Unknown Guide',
                          style: headingLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: spacingS),

                        // Role chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: spacingM,
                            vertical: spacingS,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(radiusS),
                          ),
                          child: Text(
                            guide.role?.toUpperCase() ?? 'GUIDE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: spacingL),

                        // Details
                        _buildDetailRow(
                          icon: Icons.phone,
                          label: 'Phone Number',
                          value: guide.phoneNumber ?? 'Not provided',
                        ),
                        const SizedBox(height: spacingM),
                        _buildDetailRow(
                          icon: Icons.verified_user,
                          label: 'Status',
                          value:
                              (guide.isActive ?? false) ? 'Active' : 'Inactive',
                          valueColor:
                              (guide.isActive ?? false)
                                  ? Colors.green
                                  : Colors.red,
                        ),
                        const SizedBox(height: spacingXL),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.phone, size: 18),
                                label: const Text('Contact'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primaryColor,
                                  side: BorderSide(color: primaryColor),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: spacingM,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      radiusS,
                                    ),
                                  ),
                                ),
                                onPressed: () => _showContactOptions(guide),
                              ),
                            ),
                            const SizedBox(width: spacingM),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(
                                  Icons.assignment_add,
                                  size: 18,
                                ),
                                label: const Text('Assign'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: spacingM,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      radiusS,
                                    ),
                                  ),
                                ),
                                onPressed: () => _showAssignMission(guide),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: spacingM),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(spacingM),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(radiusS),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 20),
          const SizedBox(width: spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: bodySmall),
                const SizedBox(height: spacingXS),
                Text(
                  value,
                  style: bodyMedium.copyWith(
                    color: valueColor ?? Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showContactOptions(Profile guide) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(radiusL),
                topRight: Radius.circular(radiusL),
              ),
            ),
            padding: const EdgeInsets.all(spacingL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Modal handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: spacingL),

                Text('Contact ${guide.name ?? 'Guide'}', style: headingMedium),
                const SizedBox(height: spacingL),

                if (guide.phoneNumber != null &&
                    guide.phoneNumber!.isNotEmpty) ...[
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(spacingS),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(radiusS),
                      ),
                      child: Icon(Icons.phone, color: Colors.green),
                    ),
                    title: const Text('Call'),
                    subtitle: Text(guide.phoneNumber!),
                    onTap: () => _makePhoneCall(guide.phoneNumber!),
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(spacingS),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(radiusS),
                      ),
                      child: Icon(Icons.message, color: Colors.blue),
                    ),
                    title: const Text('Send SMS'),
                    subtitle: Text(guide.phoneNumber!),
                    onTap: () => _sendSMS(guide.phoneNumber!),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(spacingL),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(radiusS),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.orange),
                        const SizedBox(width: spacingM),
                        Expanded(
                          child: Text(
                            'No phone number available for this guide',
                            style: bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: spacingM),
              ],
            ),
          ),
    );
  }

  void _showAssignMission(Profile guide) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(radiusL),
                topRight: Radius.circular(radiusL),
              ),
            ),
            padding: const EdgeInsets.all(spacingL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Modal handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: spacingL),

                Icon(Icons.assignment_add, size: 48, color: primaryColor),
                const SizedBox(height: spacingM),

                Text('Assign Mission', style: headingMedium),
                const SizedBox(height: spacingS),

                Text(
                  'Assign a guidance mission to ${guide.name ?? 'this guide'}',
                  style: bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: spacingL),

                Container(
                  padding: const EdgeInsets.all(spacingL),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(radiusS),
                  ),
                  child: Text(
                    'Mission assignment functionality will be implemented here. This could include selecting tours, dates, and other mission details.',
                    style: bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: spacingL),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: spacingL,
                      vertical: spacingM,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(radiusS),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
                const SizedBox(height: spacingM),
              ],
            ),
          ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      await launchUrl(launchUri);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch phone call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendSMS(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'sms', path: phoneNumber);
    try {
      await launchUrl(launchUri);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch SMS: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildGuideCard(Profile guide) {
    return Card(
      elevation: 10,
      margin: const EdgeInsets.symmetric(
        horizontal: spacingM,
        vertical: spacingS,
      ),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusM),
      ),
      shadowColor: Colors.black.withAlpha(90),
      child: Padding(
        padding: const EdgeInsets.all(spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Profile picture with status indicator
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: primaryColor.withOpacity(0.1),
                      backgroundImage:
                          guide.imageUrl != null && guide.imageUrl!.isNotEmpty
                              ? NetworkImage(guide.imageUrl!)
                              : null,
                      child:
                          guide.imageUrl == null || guide.imageUrl!.isEmpty
                              ? Icon(
                                Icons.person,
                                size: 30,
                                color: primaryColor,
                              )
                              : null,
                    ),
                    // Active status indicator
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color:
                              (guide.isActive ?? false)
                                  ? Colors.green
                                  : Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: spacingM),

                // Guide info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guide.name ?? 'Unknown Guide',
                        style: headingMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: spacingXS),
                      if (guide.phoneNumber != null)
                        Text(guide.phoneNumber!, style: bodyMedium),
                      const SizedBox(height: spacingXS),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: spacingS,
                          vertical: spacingXS,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(radiusS),
                        ),
                        child: Text(
                          guide.role?.toUpperCase() ?? 'GUIDE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: spacingM),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(vertical: spacingS),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(radiusS),
                      ),
                    ),
                    onPressed: () => _showGuideDetails(guide),
                  ),
                ),
                const SizedBox(width: spacingS),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.phone_outlined, size: 16),
                    label: const Text('Contact'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: BorderSide(color: Colors.green.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(vertical: spacingS),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(radiusS),
                      ),
                    ),
                    onPressed: () => _showContactOptions(guide),
                  ),
                ),
                const SizedBox(width: spacingS),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.assignment_ind_rounded, size: 16),
                    label: const Text('Assign'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: spacingS),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(radiusS),
                      ),
                    ),
                    onPressed: () => _showAssignMission(guide),
                  ),
                ),
              ],
            ),
            const SizedBox(height: spacingS),

            // Delete button (separate row for emphasis)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Delete Guide'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: spacingS),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(radiusS),
                  ),
                ),
                onPressed: () => _showDeleteConfirmationDialog(guide),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(spacingXL),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.person_search_outlined,
                size: 64,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: spacingL),
            Text('No guides found', style: headingLarge),
            const SizedBox(height: spacingS),
            Text(
              'There are currently no guides in the system',
              style: bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Guides Management',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchGuides,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: primaryColor),
              )
              : _guides.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                onRefresh: _fetchGuides,
                color: primaryColor,
                child: ListView.builder(
                  padding: const EdgeInsets.only(
                    top: spacingM,
                    bottom: spacingM,
                  ),
                  itemCount: _guides.length,
                  itemBuilder:
                      (context, index) => _buildGuideCard(_guides[index]),
                ),
              ),
    );
  }
}
