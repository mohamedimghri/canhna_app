import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/offre.dart';
import 'package:another_flushbar/flushbar.dart';
import '../../../views/constants.dart';

class ModalOffre extends StatefulWidget {
  final Offre? existingOffre;
  final VoidCallback? onOfferSaved;

  const ModalOffre({super.key, this.existingOffre, this.onOfferSaved});

  @override
  State<ModalOffre> createState() => _ModalOffreState();
}

class _ModalOffreState extends State<ModalOffre> {
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

  // Image picker widget
  Widget _buildImagePicker() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: primaryColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: _image != null
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _image!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _image = null),
                    color: Colors.white,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ),
              ],
            )
          : _existingImageUrl != null && _existingImageUrl!.isNotEmpty
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _existingImageUrl!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _existingImageUrl = null),
                        color: Colors.white,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ),
                  ],
                )
              : InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 48,
                          color: primaryColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Click to upload',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _image = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        _showFlushbar(
          'Error picking image: ${e.toString()}',
          Colors.red,
          Icons.error_outline,
        );
      }
    }
  }

  Future<String> _uploadImage() async {
    try {
      final supabase = Supabase.instance.client;

      // Verify user is authenticated
      if (supabase.auth.currentUser == null) {
        throw Exception('User must be authenticated to upload images');
      }

      // Read image file
      final bytes = await _image!.readAsBytes();
      final fileExt = _image!.path.split('.').last.toLowerCase();
      final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
      final mimeType = 'image/$fileExt';

      // Validate file type
      if (!['jpg', 'jpeg', 'png', 'webp'].contains(fileExt)) {
        throw Exception('Unsupported image format');
      }

      // Upload the file
      await supabase.storage
          .from('offres')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(contentType: mimeType),
          );

      // Get public URL
      return supabase.storage.from('offres').getPublicUrl(fileName);
    } catch (e) {
      if (mounted) {
        _showFlushbar(
          'Error uploading image: ${e.toString()}',
          Colors.red,
          Icons.error_outline,
        );
      }
      rethrow;
    }
  }

  Future<void> _saveOffer() async {
    if (!_formKey.currentState!.validate()) return;
    if (_image == null && _existingImageUrl == null) {
      _showFlushbar(
        'Please select an image for the offer',
        Colors.orange,
        Icons.warning_amber_rounded,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      String imageUrl = _existingImageUrl ?? '';
      
      // Upload new image if selected
      if (_image != null) {
        imageUrl = await _uploadImage();
      }

      // Create offer data
      final offerData = {
        'titre': _titleController.text,
        'description': _descriptionController.text,
        'prix': double.parse(_priceController.text),
        'image_url': imageUrl,
        'match': _hasMatch,
        'hotel': _hasHotel,
        'transport': _hasTransport,
        'place': _hasPlace,
      };

      if (_isEditMode) {
        // Update existing offer
        await supabase
            .from('offres')
            .update(offerData)
            .eq('id', widget.existingOffre!.id);
            
        if (mounted) {
          Navigator.of(context).pop();
          _showFlushbar(
            'Offer updated successfully!',
            Colors.green,
            Icons.check_circle,
          );
        }
      } else {
        // Create new offer
        await supabase.from('offres').insert(offerData);
        
        if (mounted) {
          Navigator.of(context).pop();
          _showFlushbar(
            'Offer created successfully!',
            Colors.green,
            Icons.check_circle,
          );
        }
      }
      
      // Call the callback to refresh the offers list
      widget.onOfferSaved?.call();
    } catch (e) {
      if (mounted) {
        _showFlushbar(
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

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
              const Text(
                'Choose an offer cover:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              _buildImagePicker(),
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: _getInputDecoration(
                  'Description',
                  Icons.description,
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: _getInputDecoration('Price', Icons.attach_money),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
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
                      (value) => setState(() => _hasMatch = value ?? false),
                    ),
                    _buildCheckboxTile(
                      'Hotel',
                      _hasHotel,
                      (value) => setState(() => _hasHotel = value ?? false),
                    ),
                    _buildCheckboxTile(
                      'Transport',
                      _hasTransport,
                      (value) => setState(() => _hasTransport = value ?? false),
                    ),
                    _buildCheckboxTile(
                      'Place',
                      _hasPlace,
                      (value) => setState(() => _hasPlace = value ?? false),
                    ),
                  ],
                ),
              ),
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
                onPressed: _isLoading ? null : _saveOffer,
                // In the build method, update the button text
                child: _isLoading
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
                        child: Text(_isEditMode ? 'Update Offer' : 'Save Offer'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
