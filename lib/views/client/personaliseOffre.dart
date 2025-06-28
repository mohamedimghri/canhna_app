import 'package:another_flushbar/flushbar.dart';
import 'package:canhna_app/models/Offre.dart';
import 'package:canhna_app/services/auth/auth_gate.dart';
import 'package:canhna_app/services/stripe_service.dart';
import 'package:canhna_app/views/constants.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ModalOffre extends StatefulWidget {
  final Offre? existingOffre;
  final VoidCallback? onOfferSaved;

  const ModalOffre({super.key, this.existingOffre, this.onOfferSaved});

  @override
  State<ModalOffre> createState() => _ModalOffreState();
}

class _ModalOffreState extends State<ModalOffre> {
  double totale = 0;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  File? _image;
  String? _existingImageUrl;
  bool _hasMatch = false;
  bool _hasHotel = false;
  bool _hasTransport = false;
  bool _hasPlace = false;
  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    // Initialize form with existing offer data if in edit mode
    if (widget.existingOffre != null) {
      _isEditMode = true;
      _titleController.text = widget.existingOffre!.titre;
      _descriptionController.text = widget.existingOffre!.description ?? '';
      _priceController.text = widget.existingOffre!.prix.toString();
      _existingImageUrl = widget.existingOffre!.imageUrl;
      _hasMatch = widget.existingOffre!.match;
      _hasHotel = widget.existingOffre!.hotel;
      _hasTransport = widget.existingOffre!.transport;
      _hasPlace = widget.existingOffre!.place;
    }
  }

  void _updateTotal() {
    double total = 0;
    if (_hasMatch) total += 100;
    if (_hasHotel) total += 200;
    if (_hasTransport) total += 150;
    if (_hasPlace) total += 50;
    setState(() {
      totale = total;
    });
  }

  // Form field decorations
  InputDecoration _getInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
      ),
      labelStyle: const TextStyle(color: primaryColor),
      prefixIcon: Icon(icon, color: primaryColor),
      filled: true,
      fillColor: primaryColor.withOpacity(0.1),
    );
  }

  // Flushbar notifications
  void _showFlushbar(String message, Color color, IconData icon) {
    if (!mounted) return;
    Flushbar(
      message: message,
      icon: Icon(icon, size: 28.0, color: color.withOpacity(0.8)),
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: Colors.white,
      messageColor: color,
    ).show(context);
  }

  // Custom checkbox list tile
  Widget _buildCheckboxTile(
    String title,
    bool value,
    Function(bool?) onChanged,
  ) {
    return Column(
      children: [
        CheckboxListTile(
          title: Text(
            title,
            style: const TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          value: value,
          onChanged: onChanged,
          activeColor: primaryColor,
          checkColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        if (title != 'Place') const Divider(color: primaryColor, height: 1),
      ],
    );
  }

Future<void> _saveOffer() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  try {
    final supabase = Supabase.instance.client;
    double total = 0;

    if (_hasMatch) total += 100;
    if (_hasHotel) total += 200;
    if (_hasTransport) total += 150;
    if (_hasPlace) total += 50;

    setState(() {
      totale = total;
    });

    // Créer les données de l'offre
    final offerData = {
      'titre': _titleController.text,
      'prix': totale,
      'match': _hasMatch,
      'hotel': _hasHotel,
      'transport': _hasTransport,
      'place': _hasPlace,
    };

    String? offreId;

    if (_isEditMode) {
      await supabase
          .from('offres')
          .update(offerData)
          .eq('id', widget.existingOffre!.id);

      offreId = widget.existingOffre!.id.toString();

      if (mounted) {
        _showSnackBar(
          'Offer updated successfully!',
          Colors.green,
          Icons.check_circle,
        );
      }
    } else {
      final response = await supabase.from('offres').insert(offerData).select().single();
      offreId = response['id'].toString();

      if (mounted) {
        _showSnackBar(
          'Offer created successfully!',
          Colors.green,
          Icons.check_circle,
        );
      }
    }

    // Si total > 0, lancer le paiement Stripe
    if (totale > 0) {
      try {
        // 🟢 Étape 1 : Lancer le paiement Stripe
        final paymentSuccess = await StripeService.instance.makePayment(
          amount: totale,
        );

        if (!paymentSuccess) {
          if (mounted) {
            _showSnackBar(
              "Le paiement a échoué ou a été annulé.",
              Colors.red,
              Icons.error_outline,
            );
          }
          return;
        }

        // 🟢 Étape 2 : Insérer dans purchases si le paiement a réussi
        final userId = supabase.auth.currentUser?.id;
        if (userId == null) {
          _showSnackBar(
            "Utilisateur non connecté.",
            Colors.red,
            Icons.error_outline,
          );
          return;
        }

        await supabase.from('purchases').insert({
          'user_id': userId,
          'offre_id': offreId,
        });

        if (mounted) {
          _showSnackBar(
            "✅ Offre achetée avec succès !",
            Colors.green,
            Icons.check_circle,
          );
        }

        // 🟢 Étape 3 : Redirection vers AuthGate après un délai
        await Future.delayed(const Duration(milliseconds: 1500));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const AuthGate(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
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
          _showSnackBar(
            "Erreur lors de l'achat : $e",
            Colors.red,
            Icons.error_outline,
          );
        }
      }
    }

    widget.onOfferSaved?.call();
  } catch (e) {
    if (mounted) {
      _showSnackBar(
        'Error saving offer: ${e.toString()}',
        Colors.red,
        Icons.error_outline,
      );
      debugPrint('Error details: $e');
    }
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  void _showSnackBar(String message, Color color, IconData icon) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
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
      body: Container(
        padding: const EdgeInsets.all(kDefaultPadding),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // const Text(
                //   'Choose an offer cover:',
                //   style: TextStyle(
                //     fontSize: 18,
                //     fontWeight: FontWeight.bold,
                //     color: primaryColor,
                //   ),
                // ),
                // const SizedBox(height: 12),
                // _buildImagePicker(),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  decoration: _getInputDecoration('Title', Icons.title),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                // const SizedBox(height: 16),
                // TextFormField(
                //   controller: _descriptionController,
                //   decoration: _getInputDecoration(
                //     'Description',
                //     Icons.description,
                //   ),
                //   maxLines: 3,
                //   validator: (value) {
                //     if (value == null || value.isEmpty) {
                //       return 'Please enter a description';
                //     }
                //     return null;
                //   },
                // ),
                // const SizedBox(height: 16),
                // TextFormField(
                //   controller: _priceController,
                //   decoration: _getInputDecoration('Price', Icons.attach_money),
                //   keyboardType: TextInputType.number,
                //   validator: (value) {
                //     if (value == null || value.isEmpty) {
                //       return 'Please enter a price';
                //     }
                //     if (double.tryParse(value) == null) {
                //       return 'Please enter a valid number';
                //     }
                //     return null;
                //   },
                // ),
                const SizedBox(height: 16),
                const Text(
                  'Included Services:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildCheckboxTile(
                        'Match',
                        _hasMatch,
                        (value) => setState(() {
                          _hasMatch = value ?? false;
                          _updateTotal();
                        }),
                      ),
                      _buildCheckboxTile(
                        'Hotel',
                        _hasHotel,
                        (value) => setState(() {
                          _hasHotel = value ?? false;
                          _updateTotal();
                        }),
                      ),
                      _buildCheckboxTile(
                        'Transport',
                        _hasTransport,
                        (value) => setState(() {
                          _hasTransport = value ?? false;
                          _updateTotal();
                        }),
                      ),
                      _buildCheckboxTile(
                        'Place',
                        _hasPlace,
                        (value) => setState(() {
                          _hasPlace = value ?? false;
                          _updateTotal();

                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text("Total a Payée :$totale"),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _saveOffer,
                  // In the build method, update the button text
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text('Acheter Offer'),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
