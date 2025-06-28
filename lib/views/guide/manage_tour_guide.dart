import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageToursScreen extends StatefulWidget {
  const ManageToursScreen({super.key});

  @override
  State<ManageToursScreen> createState() => _ManageToursScreenState();
}

class _ManageToursScreenState extends State<ManageToursScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _bookingRequests = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _fetchBookingRequests();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  Future<void> _fetchBookingRequests() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('bookingGuid')
          .select('''
            *,
            client:client_id(*),
            profile:client_id(
              id,
              image_url,
              phone_number
            )
          ''')
          .eq('guide_id', userId)
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> typedResponse =
          (response as List)
              .cast<Map<dynamic, dynamic>>()
              .map<Map<String, dynamic>>((item) {
                return item.cast<String, dynamic>();
              })
              .toList();

      final processedBookings = await Future.wait(
        typedResponse.map((booking) async {
          final clientData =
              (booking['client'] as Map?)?.cast<String, dynamic>() ?? {};
          final profileData =
              (booking['profile'] as Map?)?.cast<String, dynamic>() ?? {};

          String imageUrl = '';
          final dynamicImageUrl = profileData['image_url'];
          if (dynamicImageUrl != null &&
              dynamicImageUrl.toString().isNotEmpty) {
            try {
              imageUrl = _supabase.storage
                  .from('profile-images')
                  .getPublicUrl(dynamicImageUrl.toString());
            } catch (e) {
              debugPrint('Error generating image URL: $e');
            }
          }

          return {
            ...booking,
            'client': {
              ...clientData,
              'phone_number':
                  profileData['phone_number'] ??
                  clientData['phone_number'] ??
                  'No phone',
              'image_url': imageUrl,
            },
          }..cast<String, dynamic>();
        }).toList(),
      );

      setState(() {
        _bookingRequests = processedBookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      _showSnackBar('Failed to load bookings: ${e.toString()}', Colors.red);
    }
  }

  void _showContactOptions(Map<String, dynamic> clientData) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(20),
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
                const SizedBox(height: 20),
                Text(
                  'Contact ${clientData['name'] ?? 'Client'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                if (clientData['phone_number'] != null &&
                    clientData['phone_number'].toString().isNotEmpty &&
                    clientData['phone_number'] != 'No phone') ...[
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.phone, color: Colors.green),
                    ),
                    title: const Text('Call'),
                    subtitle: Text(clientData['phone_number']),
                    onTap: () {
                      Navigator.pop(context);
                      _makePhoneCall(clientData['phone_number']);
                    },
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.message, color: Colors.blue),
                    ),
                    title: const Text('Send SMS'),
                    subtitle: Text(clientData['phone_number']),
                    onTap: () {
                      Navigator.pop(context);
                      _sendSMS(clientData['phone_number']);
                    },
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber, color: Colors.orange),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'No phone number available for this client',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
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

  Future<void> _acceptBooking(String bookingId) async {
    try {
      setState(() {
        _bookingRequests.removeWhere(
          (booking) => booking['id'].toString() == bookingId,
        );
      });

      final response =
          await _supabase
              .from('bookingGuid')
              .update({'state': 'accepted'})
              .eq('id', bookingId)
              .select();

      if (response == null || response.isEmpty) {
        await _fetchBookingRequests();
        _showSnackBar('Failed to update booking', Colors.red);
      } else {
        _showSnackBar('Booking accepted successfully!', Colors.green);
      }
    } catch (e) {
      await _fetchBookingRequests();
      _showSnackBar('Failed to accept booking: ${e.toString()}', Colors.red);
    }
  }

  Future<void> _cancelBooking(String bookingId) async {
    try {
      setState(() {
        _bookingRequests.removeWhere(
          (booking) => booking['id'].toString() == bookingId,
        );
      });

      final response =
          await _supabase
              .from('bookingGuid')
              .update({'state': 'canceled'})
              .eq('id', bookingId)
              .select();

      if (response == null || response.isEmpty) {
        await _fetchBookingRequests();
        _showSnackBar('Failed to update booking', Colors.red);
      } else {
        _showSnackBar('Booking canceled', Colors.orange);
      }
    } catch (e) {
      await _fetchBookingRequests();
      _showSnackBar('Failed to cancel booking: ${e.toString()}', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
          ),
        ),
        title: const Text(
          'Booking Requests',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_isLoading)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_bookingRequests.where((b) => b['state'] == 'en_cour').length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body:
          _isLoading
              ? _buildLoadingState()
              : _hasError
              ? _buildErrorState()
              : _bookingRequests.isEmpty
              ? _buildEmptyState()
              : FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: RefreshIndicator(
                    onRefresh: _fetchBookingRequests,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _bookingRequests.length,
                      itemBuilder: (context, index) {
                        final booking = _bookingRequests[index];
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300 + (index * 100)),
                          curve: Curves.easeOutBack,
                          child: _buildBookingCard(booking, index),
                        );
                      },
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          SizedBox(height: 20),
          Text('Loading bookings...', style: TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 20),
          const Text(
            'Failed to load bookings',
            style: TextStyle(fontSize: 18, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _fetchBookingRequests,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No booking requests yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'New requests will appear here',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking, int index) {
    final clientData =
        (booking['client'] as Map?)?.cast<String, dynamic>() ?? {};
    final status = booking['state'] ?? 'en_cour';
    final isAccepted = status == 'accepted';
    final isCanceled = status == 'canceled';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
            border:
                isAccepted
                    ? Border.all(color: Colors.green.withOpacity(0.3), width: 2)
                    : isCanceled
                    ? Border.all(color: Colors.red.withOpacity(0.3), width: 2)
                    : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                if (isAccepted)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green, Colors.greenAccent],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'ACCEPTED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                if (isCanceled)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red, Colors.redAccent],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'CANCELED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildClientInfo(booking, clientData),
                      const SizedBox(height: 20),
                      _buildBookingActions(booking),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClientInfo(
    Map<String, dynamic> booking,
    Map<String, dynamic> clientData,
  ) {
    final profileImageUrl =
        clientData['image_url']?.isNotEmpty == true
            ? clientData['image_url']
            : 'https://ui-avatars.com/api/?name=${clientData['name']?.substring(0, 1) ?? 'C'}&background=random';

    return Row(
      children: [
        Hero(
          tag: 'client-${booking['id']}',
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundImage: NetworkImage(profileImageUrl),
              onBackgroundImageError: (exception, stackTrace) {
                debugPrint('Failed to load profile image: $exception');
              },
              child:
                  profileImageUrl.contains('ui-avatars.com')
                      ? Text(
                        clientData['name']?.substring(0, 1) ?? 'C',
                        style: const TextStyle(fontSize: 24),
                      )
                      : null,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                clientData['name'] ?? 'Unknown Client',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                clientData['phone_number'] ?? 'No phone',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.greenAccent],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.greenAccent,
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.phone, color: Colors.white),
            onPressed: () => _showContactOptions(clientData),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingActions(Map<String, dynamic> booking) {
    final status = booking['state'] ?? 'en_cour';
    final isAccepted = status == 'accepted';
    final isCanceled = status == 'canceled';

    if (isAccepted || isCanceled) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          isAccepted ? 'Booking Accepted' : 'Booking Canceled',
          style: TextStyle(
            color: isAccepted ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => _cancelBooking(booking['id'].toString()),
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Reject'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => _acceptBooking(booking['id'].toString()),
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Accept'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
