import 'package:canhna_app/models/Hotel.dart';
import 'package:canhna_app/views/constants.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math' as Math;


class HotelsScreen extends StatefulWidget {
  const HotelsScreen({super.key});

  @override
  State<HotelsScreen> createState() => _HotelsScreenState();
}

class _HotelsScreenState extends State<HotelsScreen> 
    with TickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  late Future<List<Hotel>> _hotelsFuture;
  late AnimationController _headerController;
  late AnimationController _listController;
  late Animation<double> _headerAnimation;
  late Animation<double> _listAnimation;
  
  String _selectedFilter = 'Tous';
  final List<String> _filterOptions = ['Tous', 'Luxe', 'Économique', 'Standard'];

  @override
  void initState() {
    super.initState();
    _hotelsFuture = fetchHotels();
    
    // Animations setup
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _listController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.elasticOut,
    );
    _listAnimation = CurvedAnimation(
      parent: _listController,
      curve: Curves.easeOutQuart,
    );
    
    // Start animations
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _listController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _listController.dispose();
    super.dispose();
  }

  Future<List<Hotel>> fetchHotels() async {
    final response = await supabase.from('hotel').select();
    return (response as List).map((e) => Hotel.fromJson(e)).toList();
  }

  List<Hotel> _filterHotels(List<Hotel> hotels) {
    if (_selectedFilter == 'Tous') return hotels;
    
    return hotels.where((hotel) {
      switch (_selectedFilter) {
        case 'Luxe':
          return hotel.prixParNuit > 1000;
        case 'Économique':
          return hotel.prixParNuit < 500;
        case 'Standard':
          return hotel.prixParNuit >= 500 && hotel.prixParNuit <= 1000;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor,
              Colors.white,
              accentColor,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // Custom App Bar with animation
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: AnimatedBuilder(
                  animation: _headerAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _headerAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              primaryColor,
                              primaryColor.withOpacity(0.6),
                              primaryColor.withOpacity(0.3),
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Animated background pattern
                            Positioned.fill(
                              child: AnimatedBuilder(
                                animation: _headerController,
                                builder: (context, child) {
                                  return CustomPaint(
                                    painter: WavePainter(_headerController.value),
                                  );
                                },
                              ),
                            ),
                            // Content
                            SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: const Icon(
                                            Icons.hotel,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Découvrez',
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(0.9),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                              const Text(
                                                'Nos Hôtels',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.bold,
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
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Filter chips
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _listAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - _listAnimation.value)),
                    child: Opacity(
                      opacity: _listAnimation.value,
                      child: Container(
                        height: 80,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _filterOptions.length,
                          itemBuilder: (context, index) {
                            final option = _filterOptions[index];
                            final isSelected = _selectedFilter == option;
                            
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(right: 12, top: 20, bottom: 20),
                              child: FilterChip(
                                label: Text(
                                  option,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : primaryColor.withOpacity(0.6),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedFilter = option;
                                  });
                                },
                                backgroundColor: Colors.white,
                                selectedColor: primaryColor,
                                checkmarkColor: Colors.white,
                                elevation: isSelected ? 6 : 2,
                                shadowColor: primaryColor.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  side: BorderSide(
                                    color: isSelected ? Colors.transparent : primaryColor.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Hotels list
            SliverToBoxAdapter(
              child: FutureBuilder<List<Hotel>>(
                future: _hotelsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 400,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Chargement des hôtels...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return SizedBox(
                      height: 400,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Erreur de chargement',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${snapshot.error}',
                              style: TextStyle(color: Colors.grey.shade600),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return SizedBox(
                      height: 400,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.hotel_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun hôtel trouvé',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Les hôtels apparaîtront ici une fois ajoutés',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final allHotels = snapshot.data!;
                  final filteredHotels = _filterHotels(allHotels);

                  return AnimatedBuilder(
                    animation: _listAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 30 * (1 - _listAnimation.value)),
                        child: Opacity(
                          opacity: _listAnimation.value,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(20),
                            itemCount: filteredHotels.length,
                            itemBuilder: (context, index) {
                              return AnimatedHotelCard(
                                hotel: filteredHotels[index],
                                index: index,
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedHotelCard extends StatefulWidget {
  final Hotel hotel;
  final int index;

  const AnimatedHotelCard({
    super.key,
    required this.hotel,
    required this.index,
  });

  @override
  State<AnimatedHotelCard> createState() => _AnimatedHotelCardState();
}

class _AnimatedHotelCardState extends State<AnimatedHotelCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Delayed animation start
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              child: MouseRegion(
                onEnter: (_) => setState(() => _isHovered = true),
                onExit: (_) => setState(() => _isHovered = false),
                child: GestureDetector(
                  onTap: () => _showHotelDetails(context),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    transform: Matrix4.identity()
                      ..scale(_isHovered ? 1.02 : 1.0)
                      ..translate(0.0, _isHovered ? -5.0 : 0.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: _isHovered 
                              ? primaryColor
                              : Colors.black.withOpacity(0.1),
                          blurRadius: _isHovered ? 20 : 10,
                          spreadRadius: _isHovered ? 2 : 0,
                          offset: Offset(0, _isHovered ? 8 : 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image with gradient overlay
                          Stack(
                            children: [
                              Hero(
                                tag: 'hotel_${widget.hotel.id}',
                                child: SizedBox(
                                  height: 200,
                                  width: double.infinity,
                                  child: widget.hotel.imageUrl != null
                                      ? Image.network(
                                          widget.hotel.imageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              Container(
                                                color: Colors.grey[300],
                                                child: const Icon(Icons.image, size: 50),
                                              ),
                                        )
                                      : Container(
                                          color: Colors.grey[200],
                                          child: const Icon(
                                            Icons.image_not_supported,
                                            size: 50,
                                          ),
                                        ),
                                ),
                              ),
                              // Gradient overlay
                              Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.3),
                                    ],
                                  ),
                                ),
                              ),
                              // Price badge
                              Positioned(
                                top: 16,
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    '${widget.hotel.prixParNuit.toStringAsFixed(0)} MAD',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          // Content
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.hotel.nom,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 18,
                                      color: primaryColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        widget.hotel.lieu,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: primaryColor,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.nights_stay,
                                            size: 16,
                                            color: accentColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'par nuit',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    if (widget.hotel.lienHotel != null)
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        child: ElevatedButton.icon(
                                          onPressed: () async {
                                            final url = Uri.parse(widget.hotel.lienHotel!);
                                            if (await canLaunchUrl(url)) {
                                              await launchUrl(
                                                url,
                                                mode: LaunchMode.externalApplication,
                                              );
                                            }
                                          },
                                          icon: const Icon(Icons.open_in_new, size: 18),
                                          label: const Text('Réserver'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryColor,
                                            foregroundColor: Colors.white,
                                            elevation: 4,
                                            shadowColor: primaryColor.withOpacity(0.3),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showHotelDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HotelDetailsSheet(hotel: widget.hotel),
    );
  }
}

class HotelDetailsSheet extends StatelessWidget {
  final Hotel hotel;

  const HotelDetailsSheet({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  Hero(
                    tag: 'hotel_${hotel.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: hotel.imageUrl != null
                            ? Image.network(
                                hotel.imageUrl!,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: primaryColor,
                                child: const Icon(Icons.image_not_supported, size: 50),
                              ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Title
                  Text(
                    hotel.nom,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        hotel.lieu,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Price
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.attach_money, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        Text(
                          '${hotel.prixParNuit.toStringAsFixed(2)} MAD par nuit',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Reserve button
                  if (hotel.lienHotel != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final url = Uri.parse(hotel.lienHotel!);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        },
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Réserver maintenant'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = 20.0;
    final waveLength = size.width / 2;

    path.moveTo(0, size.height * 0.7);

    for (double i = 0; i <= size.width; i++) {
      final waveY = size.height * 0.7 +
          waveHeight * 
          Math.sin((i / waveLength + animationValue * 2) * 2 * Math.pi) * 
          animationValue;
      path.lineTo(i, waveY);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

