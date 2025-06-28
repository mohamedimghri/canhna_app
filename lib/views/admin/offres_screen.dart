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

class _OffresScreenState extends State<OffresScreen> with TickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  List<Offre> _offres = [];
  bool _isLoading = true;
  late AnimationController _fabAnimationController;
  late AnimationController _listAnimationController;
  late Animation<double> _fabAnimation;

  // Enhanced spacing constants
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Enhanced border radius constants
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;

  // Enhanced typography styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
    letterSpacing: -0.5,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
    letterSpacing: -0.25,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
    height: 1.4,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.black54,
    height: 1.3,
  );

  static const TextStyle priceStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: primaryColor,
    letterSpacing: -0.5,
  );

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.elasticOut),
    );
    _fetchOffres();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  Future<void> _fetchOffres() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase.from('offres').select('*');
      final data = response as List<dynamic>;
      setState(() {
        _offres = data.map((json) => Offre.fromJson(json)).toList();
      });
      _fabAnimationController.forward();
      _listAnimationController.forward();
    } catch (e) {
      debugPrint('Error fetching offres: $e');
      if (mounted) {
        _showErrorSnackBar('Error loading offers: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: spacingS),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
        margin: const EdgeInsets.all(spacingM),
        elevation: 8,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: spacingS),
            Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
        margin: const EdgeInsets.all(spacingM),
        elevation: 8,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(Offre offre) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusL)),
          elevation: 24,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(spacingS),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(radiusS),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: spacingM),
              const Expanded(
                child: Text(
                  'Delete Offer',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Are you sure you want to delete this offer?',
                  style: bodyLarge,
                ),
                const SizedBox(height: spacingL),
                Container(
                  padding: const EdgeInsets.all(spacingM),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey.shade50, Colors.grey.shade100],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(radiusM),
                    border: Border.all(color: Colors.grey.shade300),
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
                      const SizedBox(height: spacingS),
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
                          style: priceStyle.copyWith(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: spacingL),
                Container(
                  padding: const EdgeInsets.all(spacingM),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(radiusS),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.red.shade600, size: 20),
                      const SizedBox(width: spacingS),
                      Expanded(
                        child: Text(
                          'This action cannot be undone.',
                          style: bodyMedium.copyWith(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
                padding: const EdgeInsets.symmetric(
                  horizontal: spacingL,
                  vertical: spacingM,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radiusS),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: spacingS),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: spacingL,
                  vertical: spacingM,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radiusS),
                ),
                elevation: 4,
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
      await _fetchOffres();
      if (mounted) {
        _showSuccessSnackBar('Offer deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error deleting offer: $e');
      }
    }
  }

  void _openOffreOverlay({Offre? existingOffre}) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (cxt) => ModalOffre(
        existingOffre: existingOffre,
        onOfferSaved: _fetchOffres,
      ),
    );
  }

  Widget _buildOfferCard(Offre offre, int index) {
    return AnimatedBuilder(
      animation: _listAnimationController,
      builder: (context, child) {
        final animationValue = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _listAnimationController,
            curve: Interval(
              (index * 0.1).clamp(0.0, 1.0),
              ((index * 0.1) + 0.3).clamp(0.0, 1.0),
              curve: Curves.easeOutBack,
            ),
          ),
        );

        return Transform.translate(
          offset: Offset(0, 50 * (1 - animationValue.value)),
          child: Opacity(
            opacity: animationValue.value,
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: spacingM,
                vertical: spacingS,
              ),
              child: Material(
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.15),
                borderRadius: BorderRadius.circular(radiusL),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(radiusL),
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildImageSection(offre),
                      _buildContentSection(offre),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSection(Offre offre) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(radiusL)),
          child: SizedBox(
            height: 220,
            width: double.infinity,
            child: offre.imageUrl != null && offre.imageUrl!.isNotEmpty
                ? Image.network(
                    offre.imageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey.shade100,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: primaryColor,
                                  strokeWidth: 3,
                                ),
                              ),
                              const SizedBox(height: spacingM),
                              Text(
                                'Loading image...',
                                style: bodyMedium.copyWith(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.grey.shade100, Colors.grey.shade200],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(spacingL),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(radiusXL),
                            ),
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: spacingM),
                          Text(
                            'Failed to load image',
                            style: bodyMedium.copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withOpacity(0.1),
                          primaryColor.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(spacingL),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(radiusXL),
                          ),
                          child: Icon(
                            Icons.image_outlined,
                            size: 48,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: spacingM),
                        Text(
                          'No image available',
                          style: bodyMedium.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        // Gradient overlay for better text readability
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection(Offre offre) {
    return Padding(
      padding: const EdgeInsets.all(spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Price Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  offre.titre,
                  style: headingMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: spacingM),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: spacingM,
                  vertical: spacingS,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withOpacity(0.15),
                      primaryColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(radiusM),
                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                ),
                child: Text(
                  '${offre.prix.toStringAsFixed(2)} \$',
                  style: priceStyle.copyWith(fontSize: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: spacingM),

          // Description
          Text(
            offre.description ?? 'No description available',
            style: bodyMedium.copyWith(height: 1.4),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: spacingL),

          // Service chips
          if (_hasAnyService(offre)) ...[
            Text(
              'Included Services',
              style: bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: spacingM),
            Wrap(
              spacing: spacingS,
              runSpacing: spacingS,
              children: [
                if (offre.match) _buildServiceChip('Match Tickets', Icons.sports_soccer),
                if (offre.hotel) _buildServiceChip('Hotel', Icons.hotel),
                if (offre.transport) _buildServiceChip('Transport', Icons.directions_bus),
                if (offre.place) _buildServiceChip('Reserved Seating', Icons.place),
              ],
            ),
            const SizedBox(height: spacingL),
          ],

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: spacingM),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(radiusM),
                    ),
                  ),
                  onPressed: () => _openOffreOverlay(existingOffre: offre),
                ),
              ),
              const SizedBox(width: spacingM),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red.shade700,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: spacingM),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(radiusM),
                    ),
                  ),
                  onPressed: () => _showDeleteConfirmationDialog(offre),
                ),
              ),
            ],
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
        gradient: LinearGradient(
          colors: [
            primaryColor.withOpacity(0.1),
            primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(radiusM),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: primaryColor),
          const SizedBox(width: spacingS),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
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
        padding: const EdgeInsets.all(spacingXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(spacingXXL),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withOpacity(0.1),
                    primaryColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: primaryColor.withOpacity(0.2), width: 2),
              ),
              child: Icon(
                Icons.local_offer_outlined,
                size: 80,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: spacingXL),
            Text(
              'No offers available',
              style: headingLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: spacingM),
            Text(
              'Create your first offer to get started\nand begin managing your offers',
              style: bodyMedium.copyWith(height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: spacingXL),
            ElevatedButton.icon(
              onPressed: _openOffreOverlay,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Create First Offer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: spacingXL,
                  vertical: spacingL,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radiusM),
                ),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(spacingL),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(radiusL),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              color: primaryColor,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: spacingL),
          Text(
            'Loading offers...',
            style: bodyMedium.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "CANHNA Admin",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: accentColor,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 70,
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _offres.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _fetchOffres,
                  color: primaryColor,
                  backgroundColor: Colors.white,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      top: spacingL,
                      bottom: 120, // Space for FAB
                    ),
                    itemCount: _offres.length,
                    itemBuilder: (context, index) => _buildOfferCard(_offres[index], index),
                  ),
                ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabAnimation.value,
            child: FloatingActionButton.extended(
              onPressed: _openOffreOverlay,
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded, size: 24),
              label: const Text(
                'New Offer',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radiusL),
              ),
              elevation: 8,
            ),
          );
        },
      ),
    );
  }
}
