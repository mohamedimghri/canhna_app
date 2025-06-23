import 'package:canhna_app/services/auth/auth_service.dart';
import 'package:canhna_app/views/auth/Login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
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
  bool _obscureConfirmPassword = true;


final authService = AuthService();


  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

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

  @override
  void dispose() {
    _controller.dispose();
    _logoController.dispose();
    _formController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

void signUp() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmpassword = confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmpassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs"),backgroundColor: Colors.red,),
      );
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez entrer une adresse email valide")),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le mot de passe doit contenir au moins 6 caractères")),
      );
      return;
    }
    if(password != confirmpassword){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le mot de passe not match")),
      );
      return;

    }
if (_formKey.currentState!.validate()) {
                                        // Traitement de l'inscription ici
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Inscription en cours...', 
                                              style: GoogleFonts.poppins(),
                                            ),
                                            backgroundColor: primaryColor,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                        );
                                      }
    

    // setState(() {
    //   _isLoading = true;
    // });

    try {
      final response = await authService.signUpWithEmailPassword(
        email,
        password,
        name,
        "client",
      );

      if (response.user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Échec de l'inscription: $e")),
        );
      }
    } 
    // finally {
    //   if (mounted) {
    //     setState(() {
    //       _isLoading = false;
    //     });
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
     // Bleu clair
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryColor, accentColor],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeIn,
          child: Stack(
            children: [
              // Cercles décoratifs en arrière-plan
              Positioned(
                top: -size.height * 0.1,
                right: -size.width * 0.2,
                child: Container(
                  width: size.width * 0.6,
                  height: size.width * 0.6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withOpacity(0.2),
                  ),
                ),
              ),
              Positioned(
                bottom: -size.height * 0.05,
                left: -size.width * 0.1,
                child: Container(
                  width: size.width * 0.4,
                  height: size.width * 0.4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withOpacity(0.15),
                  ),
                ),
              ),
              
              // Contenu principal
              Center(
                child: SingleChildScrollView(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: Offset(0, 10)),
                          ],
                          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                        ),
                        width: size.width * 0.9,
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
                                      'assets/images/3.svg',
                                      height: 120,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  "Créer un compte",
                                  style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Inscrivez-vous pour commencer",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 30),
                                // Champ nom avec design amélioré
                                TextFormField(
                                  controller: nameController,
                                  decoration: InputDecoration(
                                    labelText: 'Nom complet',
                                    hintText: 'Jean Dupont',
                                    prefixIcon: Icon(Icons.person_outline, color: primaryColor),
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
                                      value != null && value.length >= 3 ? null : 'Nom trop court',
                                ),
                                const SizedBox(height: 15),
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
                                const SizedBox(height: 15),
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
                                const SizedBox(height: 15),
                                // Champ confirmation mot de passe avec design amélioré
                                TextFormField(
                                  controller: confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  decoration: InputDecoration(
                                    labelText: 'Confirmer le mot de passe',
                                    hintText: '••••••••',
                                    prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                        color: Colors.grey[600],
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword = !_obscureConfirmPassword;
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
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez confirmer votre mot de passe';
                                    }
                                    if (value != passwordController.text) {
                                      return 'Les mots de passe ne correspondent pas';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 25),
                                // Bouton d'inscription amélioré
                                Container(
                                  width: double.infinity,
                                  height: 55,
                                  child: ElevatedButton(
                                    onPressed: signUp,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      foregroundColor: Colors.white,
                                      elevation: 5,
                                      shadowColor: primaryColor.withOpacity(0.5),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    ),
                                    child: Text(
                                      "S'inscrire",
                                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 1),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Option de connexion
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Déjà un compte ?",
                                      style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 14),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
                                      },
                                      child: Text(
                                        "Se connecter",
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}