import 'package:canhna_app/models/profile.dart';
import 'package:canhna_app/models/purchase.dart';
import 'package:canhna_app/views/constants.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../../models/offre.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final supabase = Supabase.instance.client;
  List<Profile> _clients = [];
  Map<String, List<Purchase>> _clientPurchases = {};
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

  static const TextStyle priceStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );

  @override
  void initState() {
    super.initState();
    _fetchClients();
  }

  Future<void> _fetchClients() async {
    setState(() => _isLoading = true);
    try {
      // Fetch clients (users with role 'client')
      final response = await supabase
          .from('profiles')
          .select('*')
          .eq('role', 'client')
          .order('name', ascending: true);
      
      final data = response as List<dynamic>;
      final clients = data.map((json) => Profile.fromJson(json)).toList();
      
      // Initialize the purchases map
      Map<String, List<Purchase>> clientPurchases = {};
      
      // For each client, fetch their purchases with offer details
      for (var client in clients) {
        final purchasesResponse = await supabase
            .from('purchases')
            .select('''
              *,
              offre:offre_id(id, titre, description, image_url, prix, match, hotel, transport, place)
            ''')
            .eq('user_id', client.id);
        
        final purchasesData = purchasesResponse as List<dynamic>;
        final purchases = purchasesData.map((json) => Purchase.fromJson(json)).toList();
        
        clientPurchases[client.id] = purchases;
      }
      
      setState(() {
        _clients = clients;
        _clientPurchases = clientPurchases;
      });
    } catch (e) {
      debugPrint('Error fetching clients: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading clients: $e'),
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
  Future<void> _showDeleteConfirmationDialog(Profile client) async {
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
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 28,
              ),
              const SizedBox(width: spacingS),
              const Text(
                'Delete Client',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Are you sure you want to delete this client?',
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
                        backgroundImage: client.imageUrl != null && client.imageUrl!.isNotEmpty
                            ? NetworkImage(client.imageUrl!)
                            : null,
                        child: client.imageUrl == null || client.imageUrl!.isEmpty
                            ? Icon(Icons.person, color: primaryColor)
                            : null,
                      ),
                      const SizedBox(width: spacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              client.name ?? 'Unknown Client',
                              style: headingMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (client.phoneNumber != null)
                              Text(
                                client.phoneNumber!,
                                style: bodyMedium,
                              ),
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
                _deleteClient(client.id);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteClient(String id) async {
    try {
      await supabase.from('profiles').delete().eq('id', id);
      await _fetchClients(); // Refresh the list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: spacingS),
                const Text('Client deleted successfully'),
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
                Expanded(child: Text('Error deleting client: $e')),
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

  void _showClientDetails(Profile client) {
    final purchases = _clientPurchases[client.id] ?? [];
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: primaryColor.withOpacity(0.1),
                      backgroundImage: client.imageUrl != null && client.imageUrl!.isNotEmpty
                          ? NetworkImage(client.imageUrl!)
                          : null,
                      child: client.imageUrl == null || client.imageUrl!.isEmpty
                          ? Icon(Icons.person, size: 50, color: primaryColor)
                          : null,
                    ),
                    const SizedBox(height: spacingL),
                    
                    // Name
                    Text(
                      client.name ?? 'Unknown Client',
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
                        client.role?.toUpperCase() ?? 'CLIENT',
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
                      value: client.phoneNumber ?? 'Not provided',
                    ),
                    const SizedBox(height: spacingM),
                    _buildDetailRow(
                      icon: Icons.verified_user,
                      label: 'Status',
                      value: (client.isActive ?? false) ? 'Active' : 'Inactive',
                      valueColor: (client.isActive ?? false) ? Colors.green : Colors.red,
                    ),
                    const SizedBox(height: spacingL),
                    
                    // Purchased offers section
                    Text(
                      'Purchased Offers',
                      style: headingMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: spacingM),
                    
                    if (purchases.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(spacingL),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(radiusM),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: spacingM),
                            Text(
                              'No purchases found',
                              style: bodyMedium.copyWith(
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: purchases.length,
                        itemBuilder: (context, index) {
                          final purchase = purchases[index];
                          final offre = purchase.offre;
                          
                          if (offre == null) {
                            return SizedBox.shrink();
                          }
                          
                          return Card(
                            margin: EdgeInsets.only(bottom: spacingM),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(radiusM),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Offer image
                                if (offre.imageUrl != null && offre.imageUrl!.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(radiusM),
                                    ),
                                    child: Image.network(
                                      offre.imageUrl!,
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        height: 120,
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: Icon(
                                            Icons.image_not_supported_outlined,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                
                                Padding(
                                  padding: const EdgeInsets.all(spacingM),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Offer title
                                      Text(
                                        offre.titre,
                                        style: headingMedium,
                                      ),
                                      const SizedBox(height: spacingS),
                                      
                                      // Purchase date
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: spacingS),
                                          Text(
                                            'Purchased on: ${DateFormat('MMM d, yyyy').format(purchase.purchasedAt)}',
                                            style: bodyMedium,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: spacingS),
                                      
                                      // Price
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
                                          '${offre.prix.toStringAsFixed(2)} \$',
                                          style: priceStyle,
                                        ),
                                      ),
                                      const SizedBox(height: spacingM),
                                      
                                      // Services included
                                      if (_hasAnyService(offre)) ...[  
                                        Text(
                                          'Services Included:',
                                          style: bodyMedium.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: spacingS),
                                        Wrap(
                                          spacing: spacingS,
                                          runSpacing: spacingXS,
                                          children: [
                                            if (offre.match)
                                              _buildServiceChip('Match Tickets', Icons.sports_soccer),
                                            if (offre.hotel) 
                                              _buildServiceChip('Hotel', Icons.hotel),
                                            if (offre.transport)
                                              _buildServiceChip('Transport', Icons.directions_bus),
                                            if (offre.place)
                                              _buildServiceChip('Reserved Seating', Icons.place),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    
                    const SizedBox(height: spacingM),
                    
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
                              padding: const EdgeInsets.symmetric(vertical: spacingM),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(radiusS),
                              ),
                            ),
                            onPressed: () => _showContactOptions(client),
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

  void _showContactOptions(Profile client) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
            
            Text(
              'Contact ${client.name ?? 'Client'}',
              style: headingMedium,
            ),
            const SizedBox(height: spacingL),
            
            if (client.phoneNumber != null && client.phoneNumber!.isNotEmpty) ...[  
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
                subtitle: Text(client.phoneNumber!),
                onTap: () => _makePhoneCall(client.phoneNumber!),
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
                subtitle: Text(client.phoneNumber!),
                onTap: () => _sendSMS(client.phoneNumber!),
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
                        'No phone number available for this client',
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

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
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
    final Uri launchUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
    );
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

  bool _hasAnyService(Offre offre) {
    return offre.match || offre.hotel || offre.transport || offre.place;
  }

  Widget _buildServiceChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: spacingM,
        vertical: spacingS,
      ),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(radiusS),
        border: Border.all(color: primaryColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: primaryColor),
          const SizedBox(width: spacingXS),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientCard(Profile client) {
    final purchases = _clientPurchases[client.id] ?? [];
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(
        horizontal: spacingM,
        vertical: spacingS,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusM),
      ),
      shadowColor: Colors.black.withOpacity(0.1),
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
                      backgroundImage: client.imageUrl != null && client.imageUrl!.isNotEmpty
                          ? NetworkImage(client.imageUrl!)
                          : null,
                      child: client.imageUrl == null || client.imageUrl!.isEmpty
                          ? Icon(Icons.person, size: 30, color: primaryColor)
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
                          color: (client.isActive ?? false) ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: spacingM),
                
                // Client info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.name ?? 'Unknown Client',
                        style: headingMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: spacingXS),
                      if (client.phoneNumber != null)
                        Text(
                          client.phoneNumber!,
                          style: bodyMedium,
                        ),
                      const SizedBox(height: spacingXS),
                      Row(
                        children: [
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
                              client.role?.toUpperCase() ?? 'CLIENT',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: spacingS),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: spacingS,
                              vertical: spacingXS,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(radiusS),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.shopping_bag,
                                  size: 10,
                                  color: accentColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${purchases.length} Purchases',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: accentColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                    onPressed: () => _showClientDetails(client),
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
                    onPressed: () => _showContactOptions(client),
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
                label: const Text('Delete Client'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: spacingS),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(radiusS),
                  ),
                ),
                onPressed: () => _showDeleteConfirmationDialog(client),
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
                Icons.people_outline,
                size: 64,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: spacingL),
            Text(
              'No clients found',
              style: headingLarge,
            ),
            const SizedBox(height: spacingS),
            Text(
              'There are currently no clients in the system',
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
          'Clients Management',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchClients,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            )
          : _clients.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _fetchClients,
                  color: primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      top: spacingM,
                      bottom: spacingM,
                    ),
                    itemCount: _clients.length,
                    itemBuilder: (context, index) => _buildClientCard(_clients[index]),
                  ),
                ),
    );
  }
}