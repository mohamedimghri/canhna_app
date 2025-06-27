import 'package:canhna_app/models/Matche.dart';
import 'package:canhna_app/views/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  final _supabase = Supabase.instance.client;
  late Future<List<Matche>> _matchesFuture;
  String searchQuery = '';
  List<Matche> allMatches = [];


  @override
  void initState() {
    super.initState();
    _matchesFuture = fetchMatches();
  }
List<Matche> get filteredMatches {
  if (searchQuery.isEmpty) return allMatches;
  return allMatches.where((matche) {
    final query = searchQuery.toLowerCase();
    return matche.equipe1.name.toLowerCase().contains(query) ||
           matche.equipe2.name.toLowerCase().contains(query);
  }).toList();
}

  Future<List<Matche>> fetchMatches() async {
    final response = await _supabase.from('matche').select('''
      id, dateheure, stade, lien_ticket,
      equipe1:equipe!equipe1(id, name, image_url),
      equipe2:equipe!equipe2(id, name, image_url)
    ''');

    return (response as List)
        .map((json) => Matche.fromJson(json))
        .toList();
  }

  void showMatchDetails(Matche matche) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accentColor,
                primaryColor,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // En-tête avec les équipes
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                            ),
                            child: matche.equipe1.imageUrl != null
                                ? ClipOval(
                                    child: Image.network(
                                      matche.equipe1.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Icon(Icons.sports_soccer, size: 30),
                                    ),
                                  )
                                : Icon(Icons.sports_soccer, size: 30),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            matche.equipe1.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'VS',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                            ),
                            child: matche.equipe2.imageUrl != null
                                ? ClipOval(
                                    child: Image.network(
                                      matche.equipe2.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Icon(Icons.sports_soccer, size: 30),
                                    ),
                                  )
                                : Icon(Icons.sports_soccer, size: 30),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            matche.equipe2.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 32),
              
              // Informations du match
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Date',
                      DateFormat('dd/MM/yyyy à HH:mm').format(matche.dateHeure.toLocal()),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.stadium,
                      'Stade',
                      matche.stade,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Boutons d'action
              Row(
                children: [
                  if (matche.lienTicket != null)
                    Expanded(
                      child: ElevatedButton.icon(
                         onPressed: () async {
    final url = matche.lienTicket;
    if (url != null && await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir le lien')),
      );
    }
  },
                        icon: const Icon(Icons.confirmation_number),
                        label: const Text('Acheter Ticket'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  if (matche.lienTicket != null) const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Fermer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // appBar: AppBar(
      //   title: const Text(
      //     'Matches',
      //     style: TextStyle(fontWeight: FontWeight.bold),
      //   ),
      //   backgroundColor: Colors.white,
      //   foregroundColor: Colors.black,
      //   elevation: 0,
      //   bottom: PreferredSize(
      //     preferredSize: const Size.fromHeight(1),
      //     child: Container(
      //       height: 1,
      //       color: Colors.grey[200],
      //     ),
      //   ),
      // ),
      body: FutureBuilder<List<Matche>>(
  future: _matchesFuture,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Chargement des matches...'),
          ],
        ),
      );
    } else if (snapshot.hasError) {
      return Center(
        child: Text('Erreur: ${snapshot.error}'),
      );
    } else {
      // Assurez-vous que allMatches contient les données
      allMatches = snapshot.data ?? [];

      final List<Matche> matchesToShow = filteredMatches;

      return RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _matchesFuture = fetchMatches();
          });
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // 🔍 Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher par équipe...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // 📝 Match list
            if (matchesToShow.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Text(
                    'Aucun match trouvé',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              )
            else
              ...matchesToShow.map((matche) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => showMatchDetails(matche),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            // 📅 Date + Stade
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    DateFormat('dd/MM').format(
                                        matche.dateHeure.toLocal()),
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Icon(Icons.stadium,
                                    size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  matche.stade,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // 🆚 Teams
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 25,
                                        backgroundColor: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.1),
                                        backgroundImage:
                                            matche.equipe1.imageUrl != null
                                                ? NetworkImage(
                                                    matche.equipe1.imageUrl!)
                                                : null,
                                        child: matche.equipe1.imageUrl == null
                                            ? const Icon(Icons.sports_soccer)
                                            : null,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        matche.equipe1.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 16),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Text(
                                    'VS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 25,
                                        backgroundColor: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.1),
                                        backgroundImage:
                                            matche.equipe2.imageUrl != null
                                                ? NetworkImage(
                                                    matche.equipe2.imageUrl!)
                                                : null,
                                        child: matche.equipe2.imageUrl == null
                                            ? const Icon(Icons.sports_soccer)
                                            : null,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        matche.equipe2.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (matche.lienTicket != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.green[200]!,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.confirmation_number,
                                        size: 16, color: Colors.green[700]),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Tickets disponibles',
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
          ],
        ),
      );
    }
  },
),

    );
  }
}