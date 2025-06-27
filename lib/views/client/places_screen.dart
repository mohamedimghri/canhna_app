import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class PlacesScreen extends StatefulWidget {
  const PlacesScreen({super.key});

  @override
  State<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _selectedCategory = 'All';
  String _selectedLanguage = 'English';

  final List<String> _categories = [
    'All',
    'Stadiums',
    'Historical',
    'Cultural',
    'Restaurants',
    'Shopping'
  ];

  final List<Map<String, dynamic>> _places = [
    {
      'id': 1,
      'name': 'Grand Stade de Casablanca',
      'name_ar': 'الملعب الكبير للدار البيضاء',
      'name_fr': 'Grand Stade de Casablanca',
      'category': 'Stadiums',
      'description': 'The main stadium for CAN 2025 with capacity of 80,000 seats',
      'description_ar': 'الملعب الرئيسي لكأس الأمم الأفريقية 2025 بسعة 80،000 مقعد',
      'description_fr': 'Le stade principal de la CAN 2025 d\'une capacité de 80 000 places',
      'location': 'Casablanca',
      'rating': 4.8,
      'image': 'https://images.unsplash.com/photo-1575408264798-b50b252663e6',
      'isFavorite': false,
      'distance': '5 km from city center',
      'opening_hours': '9:00 AM - 10:00 PM',
      'entry_fee': 'Match days only',
    },
    {
      'id': 2,
      'name': 'Hassan II Mosque',
      'name_ar': 'مسجد الحسن الثاني',
      'name_fr': 'Mosquée Hassan II',
      'category': 'Historical',
      'description': 'Iconic mosque with the world\'s tallest minaret',
      'description_ar': 'مسجد أيقوني بأطول مئذنة في العالم',
      'description_fr': 'Mosquée emblématique avec le plus haut minaret du monde',
      'location': 'Casablanca',
      'rating': 4.9,
      'image': 'https://images.unsplash.com/photo-1575408264798-b50b252663e6',
      'isFavorite': true,
      'distance': '3 km from city center',
      'opening_hours': '9:00 AM - 5:00 PM',
      'entry_fee': '120 MAD',
    },
    {
      'id': 3,
      'name': 'Jamaa El Fna Square',
      'name_ar': 'ساحة جامع الفناء',
      'name_fr': 'Place Jamaa El Fna',
      'category': 'Cultural',
      'description': 'Vibrant square with street performers and food stalls',
      'description_ar': 'ساحة نابضة بالحياة مع عروض الشارع وأكشاك الطعام',
      'description_fr': 'Place animée avec des artistes de rue et des stands de nourriture',
      'location': 'Marrakech',
      'rating': 4.7,
      'image': 'https://images.unsplash.com/photo-1575408264798-b50b252663e6',
      'isFavorite': false,
      'distance': 'City center',
      'opening_hours': '24/7',
      'entry_fee': 'Free',
    },
    {
      'id': 4,
      'name': 'Stade Moulay Abdellah',
      'name_ar': 'ملعب مولاي عبد الله',
      'name_fr': 'Stade Moulay Abdellah',
      'category': 'Stadiums',
      'description': 'Historic stadium hosting several CAN 2025 matches',
      'description_ar': 'ملعب تاريخي يستضيف عدة مباريات في كأس الأمم الأفريقية 2025',
      'description_fr': 'Stade historique accueillant plusieurs matchs de la CAN 2025',
      'location': 'Rabat',
      'rating': 4.5,
      'image': 'https://images.unsplash.com/photo-1575408264798-b50b252663e6',
      'isFavorite': false,
      'distance': '7 km from city center',
      'opening_hours': 'Match days only',
      'entry_fee': 'Match ticket required',
    },
    {
      'id': 5,
      'name': 'Chefchaouen Medina',
      'name_ar': 'مدينة شفشاون',
      'name_fr': 'Médina de Chefchaouen',
      'category': 'Cultural',
      'description': 'Famous blue-painted streets in the Rif Mountains',
      'description_ar': 'شوارع زرقاء شهيرة في جبال الريف',
      'description_fr': 'Célèbres rues peintes en bleu dans les montagnes du Rif',
      'location': 'Chefchaouen',
      'rating': 4.8,
      'image': 'https://images.unsplash.com/photo-1575408264798-b50b252663e6',
      'isFavorite': true,
      'distance': '120 km from Tangier',
      'opening_hours': '24/7',
      'entry_fee': 'Free',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF6F61EF) : const Color(0xFF4CAF50);

    // Filter places based on selected category
    final filteredPlaces = _selectedCategory == 'All'
        ? _places
        : _places.where((place) => place['category'] == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFD),
      appBar: _buildAppBar(isDark),
      body: Column(
        children: [
          _buildSearchAndFilters(isDark, primaryColor),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildCategories(isDark, primaryColor),
                  const SizedBox(height: 16),
                  _buildPlacesList(filteredPlaces, isDark, primaryColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Column(
        children: [
          Text('CAN 2025 MOROCCO',
              style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : const Color(0xFF606A85),
                  letterSpacing: 1.2)),
          const SizedBox(height: 4),
          Text(_getLocalizedText('Explore Morocco', 'استكشف المغرب', 'Explorer le Maroc'),
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF15161E))),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.language),
          onPressed: _changeLanguage,
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(bool isDark, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: _getLocalizedText(
                  'Search places...',
                  'ابحث عن أماكن...',
                  'Rechercher des lieux...'
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[900] : Colors.white,
                prefixIcon: Icon(Icons.search,
                    color: isDark ? Colors.grey[400] : const Color(0xFF606A85)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(bool isDark, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final category = _categories[index];
            final selected = category == _selectedCategory;
            return FilterChip(
              label: Text(_getLocalizedCategory(category)),
              selected: selected,
              onSelected: (_) => setState(() => _selectedCategory = category),
              selectedColor: primaryColor.withOpacity(0.2),
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
              labelStyle: TextStyle(
                color: selected ? primaryColor : (isDark ? Colors.white : const Color(0xFF606A85)),
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: selected ? primaryColor : (isDark ? Colors.grey[600]! : const Color(0xFFE5E7EB)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlacesList(List<Map<String, dynamic>> places, bool isDark, Color primaryColor) {
    if (places.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            _getLocalizedText(
              'No places found',
              'لم يتم العثور على أماكن',
              'Aucun lieu trouvé'
            ),
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[400] : const Color(0xFF606A85)),
            ),
          ),
        );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: places.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final place = places[index];
          return _buildPlaceCard(place, isDark, primaryColor);
        },
      ),
    );
  }

  Widget _buildPlaceCard(Map<String, dynamic> place, bool isDark, Color primaryColor) {
    return GestureDetector(
      onTap: () => _showPlaceDetails(place, isDark, primaryColor),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    '${place['image']}?auto=format&fit=crop&w=800&q=80',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(
                      place['isFavorite'] ? Icons.favorite : Icons.favorite_border,
                      color: place['isFavorite'] ? Colors.red : Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        place['isFavorite'] = !place['isFavorite'];
                      });
                    },
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      place['category'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _getLocalizedName(place),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF15161E)),
                        ),
                      ),
                      RatingBarIndicator(
                        rating: place['rating'],
                        itemBuilder: (context, index) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 16,
                        direction: Axis.horizontal,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: isDark ? Colors.grey[400] : const Color(0xFF606A85)),
                      const SizedBox(width: 4),
                      Text(
                        place['location'],
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : const Color(0xFF606A85)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getLocalizedDescription(place),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : const Color(0xFF606A85)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        place['distance'],
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : const Color(0xFF606A85)),
                      ),
                      TextButton(
                        onPressed: () => _showPlaceDetails(place, isDark, primaryColor),
                        style: TextButton.styleFrom(
                          backgroundColor: primaryColor.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: Text(
                          _getLocalizedText('View', 'عرض', 'Voir'),
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
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
    );
  }

  void _showPlaceDetails(Map<String, dynamic> place, bool isDark, Color primaryColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return SingleChildScrollView(
              controller: controller,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        '${place['image']}?auto=format&fit=crop&w=800&q=80',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _getLocalizedName(place),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF15161E)),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            place['isFavorite'] ? Icons.favorite : Icons.favorite_border,
                            color: place['isFavorite'] ? Colors.red : primaryColor,
                          ),
                          onPressed: () {
                            setState(() {
                              place['isFavorite'] = !place['isFavorite'];
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          place['location'],
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : const Color(0xFF606A85)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    RatingBarIndicator(
                      rating: place['rating'],
                      itemBuilder: (context, index) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 20,
                      direction: Axis.horizontal,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getLocalizedDescription(place),
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.grey[400] : const Color(0xFF606A85)),
                    ),
                    const SizedBox(height: 24),
                    _buildDetailRow(
                      Icons.access_time,
                      _getLocalizedText('Opening Hours', 'ساعات العمل', 'Heures d\'ouverture'),
                      place['opening_hours'],
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.monetization_on,
                      _getLocalizedText('Entry Fee', 'رسوم الدخول', 'Frais d\'entrée'),
                      place['entry_fee'],
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.category,
                      _getLocalizedText('Category', 'الفئة', 'Catégorie'),
                      place['category'],
                      isDark,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Implement navigation or booking functionality
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          _getLocalizedText('Get Directions', 'احصل على الاتجاهات', 'Obtenir des directions'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? Colors.grey[400] : const Color(0xFF606A85)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF15161E)),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : const Color(0xFF606A85)),
            ),
          ],
        ),
      ],
    );
  }

  void _changeLanguage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_getLocalizedText('Select Language', 'اختر اللغة', 'Choisir la langue')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                trailing: _selectedLanguage == 'English' ? const Icon(Icons.check) : null,
                onTap: () {
                  setState(() {
                    _selectedLanguage = 'English';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('العربية'),
                trailing: _selectedLanguage == 'Arabic' ? const Icon(Icons.check) : null,
                onTap: () {
                  setState(() {
                    _selectedLanguage = 'Arabic';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Français'),
                trailing: _selectedLanguage == 'French' ? const Icon(Icons.check) : null,
                onTap: () {
                  setState(() {
                    _selectedLanguage = 'French';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper methods for localization
  String _getLocalizedText(String english, String arabic, String french) {
    switch (_selectedLanguage) {
      case 'Arabic':
        return arabic;
      case 'French':
        return french;
      default:
        return english;
    }
  }

  String _getLocalizedCategory(String category) {
    if (_selectedLanguage == 'Arabic') {
      switch (category) {
        case 'Stadiums': return 'ملاعب';
        case 'Historical': return 'تاريخي';
        case 'Cultural': return 'ثقافي';
        case 'Restaurants': return 'مطاعم';
        case 'Shopping': return 'تسوق';
        default: return 'الكل';
      }
    } else if (_selectedLanguage == 'French') {
      switch (category) {
        case 'Stadiums': return 'Stades';
        case 'Historical': return 'Historique';
        case 'Cultural': return 'Culturel';
        case 'Restaurants': return 'Restaurants';
        case 'Shopping': return 'Shopping';
        default: return 'Tous';
      }
    }
    return category;
  }

  String _getLocalizedName(Map<String, dynamic> place) {
    switch (_selectedLanguage) {
      case 'Arabic':
        return place['name_ar'];
      case 'French':
        return place['name_fr'];
      default:
        return place['name'];
    }
  }

  String _getLocalizedDescription(Map<String, dynamic> place) {
    switch (_selectedLanguage) {
      case 'Arabic':
        return place['description_ar'];
      case 'French':
        return place['description_fr'];
      default:
        return place['description'];
    }
  }
}