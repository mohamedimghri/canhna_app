import 'package:canhna_app/services/auth/auth_gate.dart';
import 'package:canhna_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:canhna_app/views/auth/Register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {

    final primaryColor = Color.fromARGB(255, 46, 125, 4);
    final accentColor = Color.fromARGB(255, 249, 168, 37);

  late AnimationController _controller;
  late Animation<double> _fadeIn;

  late AnimationController _logoController;
  late Animation<Offset> _logoSlide;
  late Animation<double> _logoFade;

  late AnimationController _formController;
  late Animation<double> _formScale;

  bool _obscurePassword = true;
  final authService = AuthService();


  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    ));

    _formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _formScale = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOutBack,
    ));

    // Séquence d'animations
    _controller.forward().then((_) {
      _logoController.forward().then((_) {
        _formController.forward();
      });
    });
  }

    void login() async {
    // Validation des champs
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    // setState(() {
    //   _isLoading = true;
    // });
    if (_formKey.currentState!.validate()) {
                                        // Traitement de la connexion ici
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Connexion en cours...',
                                              style: GoogleFonts.poppins(),
                                            ),
                                            backgroundColor: primaryColor,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),

                                        );
                                      }

    final email = emailController.text;
    final password = passwordController.text;


    try {
      final response = await authService.signInWithEmailPassword(email, password);


      if (response.session != null && mounted) {
        // Rebuild the widget tree and let AuthGate handle navigation
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthGate()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    //finally {
    //   if (mounted) {
    //     setState(() {
    //       _isLoading = false;
    //     });
    //   }
    // }
  }

  @override
  void dispose() {
    _controller.dispose();
    _logoController.dispose();
    _formController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
     // Bleu clair

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [primaryColor, const Color.fromARGB(255, 253, 205, 115)],
                      ),
                    ),
                    child: FadeTransition(
                      opacity: _fadeIn,
                      child: Stack(
                        children: [
                          // Cercles décoratifs
                          Positioned(
                            top: -constraints.maxHeight * 0.1,
                            right: -constraints.maxWidth * 0.2,
                            child: Container(
                              width: constraints.maxWidth * 0.6,
                              height: constraints.maxWidth * 0.6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: accentColor.withOpacity(0.2),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -constraints.maxHeight * 0.05,
                            left: -constraints.maxWidth * 0.1,
                            child: Container(
                              width: constraints.maxWidth * 0.4,
                              height: constraints.maxWidth * 0.4,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: accentColor.withOpacity(0.15),
                              ),
                            ),
                          ),

                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                                  padding: const EdgeInsets.all(30),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                                  ),
                                  width: constraints.maxWidth * 0.9,
                                  child: ScaleTransition(
                                    scale: _formScale,
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          FadeTransition(
                                            opacity: _logoFade,
                                            child: SlideTransition(
                                              position: _logoSlide,
                                              child: SvgPicture.asset(
                                                'assets/images/logo.svg',
                                                height: 200,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 25),
                                          Text(
                                            "Bienvenue",
                                            style: GoogleFonts.poppins(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                              color: primaryColor,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            "Connectez-vous pour continuer",
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              color: Colors.grey[700],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 35),
                                          //const SizedBox(height: 35),
                                    // Champ email avec design amélioré
                                    TextFormField(
                                      controller: emailController,
                                      decoration: InputDecoration(
                                        labelText: 'Email',
                                        hintText: 'exemple@email.com',
                                        prefixIcon: Icon(Icons.email_outlined, color: primaryColor),
                                        filled: true,
                                        fillColor: Colors.grey[100],
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: BorderSide(color: primaryColor, width: 1.5),
                                        ),
                                        labelStyle: TextStyle(color: Colors.grey[700]),
                                        contentPadding: EdgeInsets.symmetric(vertical: 18),
                                      ),
                                      style: GoogleFonts.poppins(fontSize: 16),
                                      validator: (value) =>
                                      value != null && value.contains('@') ? null : 'Email invalide',
                                    ),
                                    const SizedBox(height: 20),
                                    // Champ mot de passe avec design amélioré
                                    TextFormField(
                                      controller: passwordController,
                                      obscureText: _obscurePassword,
                                      decoration: InputDecoration(
                                        labelText: 'Mot de passe',
                                        hintText: '••••••••',
                                        prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                            color: Colors.grey[600],
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword = !_obscurePassword;
                                            });
                                          },
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[100],
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: BorderSide(color: primaryColor, width: 1.5),
                                        ),
                                        labelStyle: TextStyle(color: Colors.grey[700]),
                                        contentPadding: EdgeInsets.symmetric(vertical: 18),
                                      ),
                                      style: GoogleFonts.poppins(fontSize: 16),
                                      validator: (value) => value != null && value.length >= 6
                                          ? null
                                          : 'Mot de passe trop court',
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () {},
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                                        ),
                                        child: Text(
                                          "Mot de passe oublié ?",
                                          style: GoogleFonts.poppins(
                                            color: primaryColor,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 25),
                                    // Bouton de connexion amélioré
                                    SizedBox(
                                      width: double.infinity,
                                      height: 55,
                                      child: ElevatedButton(
                                        onPressed: login,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryColor,
                                          foregroundColor: Colors.white,
                                          elevation: 5,
                                          shadowColor: primaryColor.withOpacity(0.5),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                        ),
                                        child: Text(
                                          "Connexion",
                                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 1),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 25),
                                    // Option d'inscription
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Pas encore de compte ?",
                                          style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 14),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => RegisterScreen()),
                                            );
                                          },
                                          child: Text(
                                            "S'inscrire",
                                            style: GoogleFonts.poppins(
                                              color: accentColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

  }
}
