import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LanguageRegionScreen extends StatefulWidget {
  const LanguageRegionScreen({super.key});

  @override
  State<LanguageRegionScreen> createState() => _LanguageRegionScreenState();
}

class _LanguageRegionScreenState extends State<LanguageRegionScreen> {
  String _selectedLanguage = 'English';
  String _selectedCountry = 'United States';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  // Supported languages with locale codes and flags
  final List<Map<String, String>> _languages = [
    {'name': 'English', 'code': 'en', 'flag': '🇬🇧'},
    {'name': 'Arabic', 'code': 'ar', 'flag': '🇸🇦'},
    {'name': 'French', 'code': 'fr', 'flag': '🇫🇷'},
  ];

  // Countries with flags
  final List<Map<String, String>> _countries = [
    {'name': 'United States', 'flag': '🇺🇸'},
    {'name': 'United Kingdom', 'flag': '🇬🇧'},
    {'name': 'Canada', 'flag': '🇨🇦'},
    {'name': 'France', 'flag': '🇫🇷'},
    {'name': 'Germany', 'flag': '🇩🇪'},
    {'name': 'Saudi Arabia', 'flag': '🇸🇦'},
    {'name': 'United Arab Emirates', 'flag': '🇦🇪'},
    {'name': 'Egypt', 'flag': '🇪🇬'},
    {'name': 'Morocco', 'flag': '🇲🇦'},
    {'name': 'Tunisia', 'flag': '🇹🇳'},
    {'name': 'Algeria', 'flag': '🇩🇿'},
  ];

  List<Map<String, String>> _filteredCountries = [];

  @override
  void initState() {
    super.initState();
    _filteredCountries = _countries;
    _searchController.addListener(_filterCountries);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCountries() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCountries = _countries.where((country) {
        return country['name']!.toLowerCase().contains(query);
      }).toList();
      _isSearching = query.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: _isSearching 
              ? CrossFadeState.showSecond 
              : CrossFadeState.showFirst,
          firstChild: const Text(
            'Language & Region',
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          secondChild: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Search country...',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
            ),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () {
            if (_isSearching) {
              _searchController.clear();
              setState(() => _isSearching = false);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close, color: Color(0xFF9CA3AF)),
              onPressed: () {
                _searchController.clear();
                setState(() => _isSearching = false);
              },
            ),
        ],
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language Selection
              const Padding(
                padding: EdgeInsets.only(left: 16, bottom: 12, top: 8),
                child: Text(
                  'APP LANGUAGE',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: _languages.map((language) {
                    return RadioListTile<String>(
                      title: Row(
                        children: [
                          Text(
                            language['flag']!,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            language['name']!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                      value: language['name']!,
                      groupValue: _selectedLanguage,
                      onChanged: (value) {
                        setState(() {
                          _selectedLanguage = value!;
                        });
                      },
                      activeColor: const Color(0xFF4CAF50),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              // Country Selection
              const Padding(
                padding: EdgeInsets.only(left: 16, bottom: 12, top: 8),
                child: Text(
                  'COUNTRY/REGION',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (!_isSearching) ...[
                // Current Selection
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Text(
                      _countries.firstWhere(
                        (c) => c['name'] == _selectedCountry,
                        orElse: () => {'flag': '🌍'},
                      )['flag']!,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(
                      _selectedCountry,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    trailing: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                    onTap: () {
                      setState(() => _isSearching = true);
                      FocusScope.of(context).requestFocus(FocusNode());
                      Future.delayed(Duration.zero, () {
                        FocusScope.of(context).requestFocus(FocusNode());
                      });
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ] else ...[
                // Country List
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  child: _filteredCountries.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'No countries found',
                              style: TextStyle(color: Color(0xFF6B7280)),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemCount: _filteredCountries.length,
                          itemBuilder: (context, index) {
                            final country = _filteredCountries[index];
                            return ListTile(
                              leading: Text(
                                country['flag']!,
                                style: const TextStyle(fontSize: 24),
                              ),
                              title: Text(
                                country['name']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              trailing: _selectedCountry == country['name']
                                  ? const Icon(Icons.check, 
                                      color: Color(0xFF4CAF50), size: 20)
                                  : null,
                              onTap: () {
                                setState(() {
                                  _selectedCountry = country['name']!;
                                  _isSearching = false;
                                  _searchController.clear();
                                });
                              },
                              contentPadding: 
                                  const EdgeInsets.symmetric(horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            );
                          },
                        ),
                ),
              ],
              const SizedBox(height: 32),
              // Save Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _saveSettings(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text(
                      'SAVE CHANGES',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveSettings() {
    // Get the language code for the selected language
    final languageCode = _languages.firstWhere(
      (lang) => lang['name'] == _selectedLanguage,
      orElse: () => {'code': 'en'},
    )['code'];

    debugPrint('Selected Language: $_selectedLanguage ($languageCode)');
    debugPrint('Selected Country: $_selectedCountry');
    
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Settings saved: $_selectedLanguage, $_selectedCountry'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    // Close the screen after saving
    Navigator.pop(context);
    
    // Here you would typically:
    // 1. Save the settings to SharedPreferences
    // 2. Update app language using localization
    // 3. Trigger UI rebuild with new language
  }
}