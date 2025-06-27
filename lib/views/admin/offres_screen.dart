import 'package:canhna_app/models/offre.dart';
import 'package:canhna_app/views/admin/widgets/modal_offre.dart';
import 'package:canhna_app/views/constants.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OffresScreen extends StatefulWidget {
  const OffresScreen({super.key});

  @override
  State<OffresScreen> createState() => _OffresScreenState();
}

class _OffresScreenState extends State<OffresScreen> {
  final supabase = Supabase.instance.client;
  List<Offre> _offres = [];
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

  static const TextStyle priceStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );

  @override
  void initState() {
    super.initState();
    _fetchOffres();
  }

  Future<void> _fetchOffres() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase.from('offres').select('*');
      final data = response as List<dynamic>;
      setState(() {
        _offres = data.map((json) => Offre.fromJson(json)).toList();
      });
    } catch (e) {
      debugPrint('Error fetching offres: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading offers: $e'),
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
  Future<void> _showDeleteConfirmationDialog(Offre offre) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
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
                'Delete Offer',
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
                  'Are you sure you want to delete this offer?',
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offre.titre,
                        style: headingMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: spacingXS),
                      Text(
                        '${offre.prix.toStringAsFixed(2)} \$',
                        style: priceStyle.copyWith(fontSize: 16),
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
                _deleteOffre(offre.id);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteOffre(String id) async {
    try {
      await supabase.from('offres').delete().eq('id', id);
      await _fetchOffres(); // Refresh the list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: spacingS),
                const Text('Offer deleted successfully'),
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
                Expanded(child: Text('Error deleting offer: $e')),
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

  void _openOffreOverlay({Offre? existingOffre}) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (cxt) => ModalOffre(
            existingOffre: existingOffre,
            onOfferSaved: _fetchOffres,
          ),
    );
  }

  Widget _buildOfferCard(Offre offre) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Enhanced image section
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(radiusM),
            ),
            child: SizedBox(
              height: 200, // Increased height for better visual impact
              child:
                  offre.imageUrl != null && offre.imageUrl!.isNotEmpty
                      ? Image.network(
                        offre.imageUrl!,
                        height: 200,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            color: Colors.grey[100],
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                    color: primaryColor,
                                  ),
                                  const SizedBox(height: spacingS),
                                  Text('Loading image...', style: bodyMedium),
                                ],
                              ),
                            ),
                          );
                        },
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              height: 200,
                              color: Colors.grey[100],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image_outlined,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: spacingS),
                                  Text(
                                    'Failed to load image',
                                    style: bodyMedium.copyWith(
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      )
                      : Container(
                        height: 200,
                        color: Colors.grey[100],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: spacingS),
                            Text(
                              'No image available',
                              style: bodyMedium.copyWith(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
            ),
          ),

          // Enhanced content section
          Padding(
            padding: const EdgeInsets.all(spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  offre.titre,
                  style: headingLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: spacingS),

                // Description
                Text(
                  offre.description ?? 'No description available',
                  style: bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: spacingM),

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

                // Enhanced service chips
                if (_hasAnyService(offre)) ...[
                  Text(
                    'Included Services:',
                    style: bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: spacingS),
                  Wrap(
                    spacing: spacingS,
                    runSpacing: spacingXS,
                    children: [
                      if (offre.match)
                        _buildServiceChip('Match Tickets', Icons.sports_soccer),
                      if (offre.hotel) _buildServiceChip('Hotel', Icons.hotel),
                      if (offre.transport)
                        _buildServiceChip('Transport', Icons.directions_bus),
                      if (offre.place)
                        _buildServiceChip('Reserved Seating', Icons.place),
                    ],
                  ),
                  const SizedBox(height: spacingM),
                ],

                // Enhanced action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: BorderSide(color: primaryColor),
                        padding: const EdgeInsets.symmetric(
                          horizontal: spacingM,
                          vertical: spacingS,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(radiusS),
                        ),
                      ),
                      onPressed: () => _openOffreOverlay(existingOffre: offre),
                    ),
                    const SizedBox(width: spacingS),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        foregroundColor: Colors.red[700],
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: spacingM,
                          vertical: spacingS,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(radiusS),
                        ),
                      ),
                      onPressed: () => _showDeleteConfirmationDialog(offre),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
                Icons.local_offer_outlined,
                size: 64,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: spacingL),
            Text('No offers available', style: headingLarge),
            const SizedBox(height: spacingS),
            Text(
              'Create your first offer to get started',
              style: bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: spacingL),
            ElevatedButton.icon(
              onPressed: _openOffreOverlay,
              icon: const Icon(Icons.add),
              label: const Text('Create First Offer'),
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
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: primaryColor),
              )
              : _offres.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                onRefresh: _fetchOffres,
                color: primaryColor,
                child: ListView.builder(
                  padding: const EdgeInsets.only(
                    top: spacingM,
                    bottom: 100, // Space for FAB
                  ),
                  itemCount: _offres.length,
                  itemBuilder:
                      (context, index) => _buildOfferCard(_offres[index]),
                ),
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openOffreOverlay,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'New Offer',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
      ),
    );
  }
}
