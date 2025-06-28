import 'package:canhna_app/models/Offre.dart';
import 'package:canhna_app/services/auth/auth_gate.dart';
import 'package:canhna_app/services/stripe_service.dart';
import 'package:canhna_app/views/client/personaliseOffre.dart';
import 'package:canhna_app/views/constants.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OffresScreen extends StatefulWidget {
  const OffresScreen({super.key});

  @override
  State<OffresScreen> createState() => _OffresScreenState();
}

class _OffresScreenState extends State<OffresScreen>
    with TickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  late Future<List<Offre>> _offresFuture;
  late AnimationController _animationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _offresFuture = fetchOffres();

    // Initialize animation controllers
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    // Start animations
    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _fabAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<List<Offre>> fetchOffres() async {
  final response = await supabase
      .from('offres')
      .select()
      .eq('type', 'standard');

  return (response as List).map((e) => Offre.fromJson(e)).toList();
}


  Future<void> handlePurchase(Offre offre) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      _showAnimatedSnackBar(
        "Vous devez être connecté pour acheter une offre.",
        isError: true,
      );
      return;
    }

    // Afficher loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("Traitement de votre achat..."),
                  ],
                ),
              ),
            ),
          ),
    );

    try {
      // 🟢 Étape 1 : Lancer le paiement Stripe
      final paymentSuccess = await StripeService.instance.makePayment(
        amount: offre.prix,
      );

      if (!paymentSuccess) {
        if (mounted) {
          Navigator.pop(context);
          _showAnimatedSnackBar(
            "Le paiement a échoué ou a été annulé.",
            isError: true,
          );
        }
        return;
      }

      // 🟢 Étape 2 : Insérer dans purchases seulement si le paiement a réussi
      await Supabase.instance.client.from('purchases').insert({
        'user_id': userId,
        'offre_id': offre.id,
      });

      if (!mounted) return;
      Navigator.pop(context); // Fermer le loading

      _showAnimatedSnackBar("✅ Offre achetée avec succès !");

      // 🟢 Étape 3 : Rediriger avec animation vers AuthGate après délai
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => const AuthGate(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOutCubic,
                  ),
                ),
                child: child,
              );
            },
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Fermer le loading
        _showAnimatedSnackBar("Erreur lors de l'achat : $e", isError: true);
      }
    }
  }

  void _showAnimatedSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Offres Disponibles',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryColor, primaryColor.withOpacity(0.8)],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor.withOpacity(0.1), Colors.white],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<List<Offre>>(
            future: _offresFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chargement des offres...',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
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
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune offre disponible',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Revenez plus tard pour découvrir nos nouvelles offres',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                );
              }

              final offres = snapshot.data!;
              return AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: offres.length,
                        itemBuilder: (context, index) {
                          return AnimatedContainer(
                            duration: Duration(
                              milliseconds: 600 + (index * 100),
                            ),
                            curve: Curves.easeOutQuart,
                            child: _buildOffreCard(offres[index], index),
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
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimationController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
              heroTag: "refreshBtn",
              onPressed: () {
                setState(() {
                  _offresFuture = fetchOffres();
                });
              },
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Actualiser',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: primaryColor,
            ),
            const SizedBox(height: 12),
            FloatingActionButton.extended(
              heroTag: "addBtn",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ModalOffre()),
                );
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Personalise offre',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: accentColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOffreCard(Offre offre, int index) {
    final theme = Theme.of(context);

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + (index * 200)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: Hero(
                tag: 'offre_${offre.id}',
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 8,
                  shadowColor: theme.primaryColor.withOpacity(0.3),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            primaryColor.withOpacity(0.02),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (offre.imageUrl != null)
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      offre.imageUrl!,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (
                                        context,
                                        child,
                                        loadingProgress,
                                      ) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          color: Colors.grey.shade200,
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      },
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          color: Colors.grey.shade200,
                                          child: const Icon(
                                            Icons.image_not_supported,
                                            size: 48,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.1),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        offre.titre,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.green.shade400,
                                            Colors.green.shade600,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.green.withOpacity(
                                              0.3,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        '${offre.prix.toStringAsFixed(2)} MAD',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (offre.description != null) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    offre.description!,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey.shade600,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () => handlePurchase(offre),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      foregroundColor: Colors.white,
                                      elevation: 6,
                                      shadowColor: theme.primaryColor
                                          .withOpacity(0.4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.shopping_cart_checkout_rounded,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Acheter cette offre',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
}
