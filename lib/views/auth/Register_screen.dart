import 'package:canhna_app/services/auth/auth_service.dart';
import 'package:canhna_app/views/auth/Login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final primaryColor = const Color.fromARGB(255, 46, 125, 4);
  final accentColor = const Color.fromARGB(255, 249, 168, 37);

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
  final teleController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeIn = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));

    _formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _formScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeOutBack),
    );

    _controller.forward().then((_) {
      _logoController.forward().then((_) {
        _formController.forward();
      });
    });
  }

  void signUp() async {
    if (_formKey.currentState!.validate()) {
      final name = nameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text;
      final confirmPassword = confirmPasswordController.text;
      final telefone = teleController.text.trim();
      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Les mots de passe ne correspondent pas"),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Inscription en cours...",
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: primaryColor,
        ),
      );

      try {
        final response = await authService.signUpWithEmailPassword(
          email,
          password,
          name,
          telefone,
          "client",
        );

        if (response.user != null && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erreur: $e")));
      }
    }
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
    teleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryColor,
                        const Color.fromARGB(255, 253, 205, 115),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: SizedBox(
                      height:
                          size.height, // 👈 IMPORTANT: Donne une taille finie au Stack
                      child: Stack(
                        children: [
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
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 10,
                                  sigmaY: 10,
                                ),
                                child: Container(
                                  margin: const EdgeInsets.all(20),
                                  padding: const EdgeInsets.all(20),
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
                                  ),
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
                                                height: 120,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 15),
                                          Text(
                                            "Créer un compte",
                                            style: GoogleFonts.poppins(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: primaryColor,
                                            ),
                                          ),
                                          const SizedBox(height: 15),
                                          _buildTextField(
                                            controller: nameController,
                                            label: "Nom complet",
                                            icon: Icons.person,
                                          ),
                                          const SizedBox(height: 10),
                                          _buildTextField(
                                            controller: emailController,
                                            label: "Email",
                                            icon: Icons.email,
                                          ),
                                          const SizedBox(height: 10),
                                          _buildTextField(
                                            controller: teleController,
                                            label: "Telefone",
                                            icon: Icons.phone,
                                          ),
                                          const SizedBox(height: 10),
                                          _buildPasswordField(
                                            controller: passwordController,
                                            label: "Mot de passe",
                                            isConfirm: false,
                                          ),
                                          const SizedBox(height: 10),
                                          _buildPasswordField(
                                            controller:
                                                confirmPasswordController,
                                            label: "Confirmer le mot de passe",
                                            isConfirm: true,
                                          ),
                                          const SizedBox(height: 20),
                                          SizedBox(
                                            width: double.infinity,
                                            height: 50,
                                            child: ElevatedButton(
                                              onPressed: signUp,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: primaryColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                              ),
                                              child: Text(
                                                "S'inscrire",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (_) =>
                                                            const LoginScreen(),
                                                  ),
                                                ),
                                            child: Text(
                                              "Déjà un compte ? Se connecter",
                                              style: GoogleFonts.poppins(
                                                color: accentColor,
                                              ),
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      validator:
          (value) =>
              value != null && value.length >= 3 ? null : "Champ invalide",
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: primaryColor),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isConfirm,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isConfirm ? _obscureConfirmPassword : _obscurePassword,
      validator: (value) {
        if (value == null || value.isEmpty) return "Veuillez remplir ce champ";
        if (value.length < 6) return "Au moins 6 caractères";
        if (isConfirm && value != passwordController.text)
          return "Les mots de passe ne correspondent pas";
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.lock, color: primaryColor),
        suffixIcon: IconButton(
          icon: Icon(
            isConfirm
                ? (_obscureConfirmPassword
                    ? Icons.visibility
                    : Icons.visibility_off)
                : (_obscurePassword ? Icons.visibility : Icons.visibility_off),
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              if (isConfirm) {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              } else {
                _obscurePassword = !_obscurePassword;
              }
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
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: primaryColor),
        ),
      ),
    );
  }
}
