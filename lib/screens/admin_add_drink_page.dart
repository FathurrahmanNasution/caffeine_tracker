import 'package:flutter/material.dart';
import 'package:caffeine_tracker/model/drink_model.dart';
import 'package:caffeine_tracker/services/admin_drink_service.dart';

class AdminAddDrinkPage extends StatefulWidget {
  const AdminAddDrinkPage({super.key});

  @override
  State<AdminAddDrinkPage> createState() => _AdminAddDrinkPageState();
}

class _AdminAddDrinkPageState extends State<AdminAddDrinkPage> {
  final _formKey = GlobalKey<FormState>();
  final _adminDrinkService = AdminDrinkService();

  final _nameController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _caffeineController = TextEditingController();
  final _volumeController = TextEditingController();
  final _infoController = TextEditingController();
  bool _isFavorite = false;

  void _saveDrink() async {
    if (_formKey.currentState!.validate()) {
      final drink = DrinkModel(
        id: '',
        name: _nameController.text,
        imageUrl: _imageUrlController.text,
        caffeineinMg: double.parse(_caffeineController.text),
        standardVolume: int.parse(_volumeController.text),
        information: _infoController.text,
        isFavorite: _isFavorite,
      );

      await _adminDrinkService.addDrink(drink);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Drink added successfully!'),
            backgroundColor: Color(0xFF4E8D7C),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EBE0),
      appBar: AppBar(
        title: const Text(
          'Add New Drink',
          style: TextStyle(
            color: Color(0xFF42261D),
            fontWeight: FontWeight.bold,
          ),
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
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: const TextStyle(color: Color(0xFF6E3D2C)),
                filled: true,
                fillColor: const Color(0xFFD6CCC2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFA67C52)),
                ),
              ),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _imageUrlController,
              decoration: InputDecoration(
                labelText: 'Image URL',
                hintText: 'assets/images/coffee.png or https://...',
                labelStyle: const TextStyle(color: Color(0xFF6E3D2C)),
                filled: true,
                fillColor: const Color(0xFFD6CCC2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFA67C52)),
                ),
              ),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _caffeineController,
              decoration: InputDecoration(
                labelText: 'Caffeine in mg',
                labelStyle: const TextStyle(color: Color(0xFF6E3D2C)),
                filled: true,
                fillColor: const Color(0xFFD6CCC2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFA67C52)),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _volumeController,
              decoration: InputDecoration(
                labelText: 'Standard Volume (mL)',
                labelStyle: const TextStyle(color: Color(0xFF6E3D2C)),
                filled: true,
                fillColor: const Color(0xFFD6CCC2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFA67C52)),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _infoController,
              decoration: InputDecoration(
                labelText: 'Information',
                labelStyle: const TextStyle(color: Color(0xFF6E3D2C)),
                filled: true,
                fillColor: const Color(0xFFD6CCC2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFA67C52)),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFD6CCC2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA67C52)),
              ),
              child: SwitchListTile(
                title: const Text(
                  'Is Favorite',
                  style: TextStyle(
                    color: Color(0xFF42261D),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                value: _isFavorite,
                activeColor: const Color(0xFF4E8D7C),
                onChanged: (v) => setState(() => _isFavorite = v),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveDrink,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4E8D7C),
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save Drink',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
    _imageUrlController.dispose();
    _caffeineController.dispose();
    _volumeController.dispose();
    _infoController.dispose();
    super.dispose();
  }
}