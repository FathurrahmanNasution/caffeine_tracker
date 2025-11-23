import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:caffeine_tracker/model/drink_model.dart';
import 'package:caffeine_tracker/services/admin_drink_service.dart';

class AdminAddDrinkPage extends StatefulWidget {
  final DrinkModel? drinkToEdit;

  const AdminAddDrinkPage({super.key, this.drinkToEdit});

  @override
  State<AdminAddDrinkPage> createState() => _AdminAddDrinkPageState();
}

class _AdminAddDrinkPageState extends State<AdminAddDrinkPage> {
  final _formKey = GlobalKey<FormState>();
  final _adminDrinkService = AdminDrinkService();
  final _imagePicker = ImagePicker();

  final _nameController = TextEditingController();
  final _caffeineController = TextEditingController();
  final _volumeController = TextEditingController();
  final _infoController = TextEditingController();

  File? _selectedImage;
  bool _isUploading = false;
  bool get _isEditMode => widget.drinkToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _nameController.text = widget.drinkToEdit!.name;
      _caffeineController.text = widget.drinkToEdit!.caffeineinMg.toString();
      _volumeController.text = widget.drinkToEdit!.standardVolume.toString();
      _infoController.text = widget.drinkToEdit!.information;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;

    setState(() => _isUploading = true);

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_nameController.text.replaceAll(' ', '_').toLowerCase()}.png';
      final ref = FirebaseStorage.instance.ref().child('drink_images/$fileName');

      await ref.putFile(_selectedImage!);
      final downloadUrl = await ref.getDownloadURL();

      setState(() => _isUploading = false);
      return downloadUrl;
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red),
        );
      }
      return null;
    }
  }

  void _saveDrink() async {
    if (_formKey.currentState!.validate()) {
      if (!_isEditMode && _selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image!'), backgroundColor: Colors.red),
        );
        return;
      }

      String? imageUrl;

      if (_selectedImage != null) {
        imageUrl = await _uploadImage();
        if (imageUrl == null) return;
      } else if (_isEditMode) {
        imageUrl = widget.drinkToEdit!.imageUrl;
      }

      final drinkData = {
        'name': _nameController.text,
        'imageUrl': imageUrl!,
        'caffeineinMg': double.parse(_caffeineController.text),
        'standardVolume': int.parse(_volumeController.text),
        'information': _infoController.text,
      };

      if (_isEditMode) {
        await _adminDrinkService.updateDrink(widget.drinkToEdit!.id, drinkData);
      } else {
        final drink = DrinkModel(
          id: '',
          name: drinkData['name'] as String,
          imageUrl: drinkData['imageUrl'] as String,
          caffeineinMg: drinkData['caffeineinMg'] as double,
          standardVolume: drinkData['standardVolume'] as int,
          information: drinkData['information'] as String,
        );
        await _adminDrinkService.addDrink(drink);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? 'Drink updated successfully!' : 'Drink added successfully!'),
            backgroundColor: const Color(0xFF6E3D2C),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  // Widget helper untuk reduce repetition
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF6E3D2C)),
        filled: true,
        fillColor: const Color(0xB3FFFFFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFA67C52)),
        ),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EBE0),
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Drink' : 'Add New Drink',
          style: const TextStyle(color: Color(0xFF42261D), fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFD5BBA2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF42261D)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image Picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xB3FFFFFF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFA67C52)),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                )
                    : _isEditMode && widget.drinkToEdit!.imageUrl.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: widget.drinkToEdit!.imageUrl.startsWith('http')
                      ? Image.network(widget.drinkToEdit!.imageUrl, fit: BoxFit.cover)
                      : Image.asset(widget.drinkToEdit!.imageUrl, fit: BoxFit.cover),
                )
                    : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate, size: 50, color: Color(0xFF6E3D2C)),
                    SizedBox(height: 8),
                    Text('Tap to select image', style: TextStyle(color: Color(0xFF6E3D2C))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _nameController,
              label: 'Name',
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _caffeineController,
              label: 'Caffeine in mg',
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _volumeController,
              label: 'Standard Volume (mL)',
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _infoController,
              label: 'Information',
              maxLines: 3,
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _isUploading ? null : _saveDrink,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6E3D2C),
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              ),
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                _isEditMode ? 'Update Drink' : 'Save Drink',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caffeineController.dispose();
    _volumeController.dispose();
    _infoController.dispose();
    super.dispose();
  }
}