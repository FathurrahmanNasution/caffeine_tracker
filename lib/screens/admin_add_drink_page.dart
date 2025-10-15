import 'package:flutter/material.dart';
import 'package:caffeine_tracker/model/drink_model.dart';
import 'package:caffeine_tracker/services/drink_service.dart';

class AdminAddDrinkPage extends StatefulWidget {
  const AdminAddDrinkPage({super.key});

  @override
  State<AdminAddDrinkPage> createState() => _AdminAddDrinkPageState();
}

class _AdminAddDrinkPageState extends State<AdminAddDrinkPage> {
  final _formKey = GlobalKey<FormState>();
  final _drinkService = DrinkService();

  final _nameController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _caffeineController = TextEditingController();
  final _volumeController = TextEditingController();
  final _infoController = TextEditingController();
  bool _isFavorite = false;

  void _saveDrink() async {
    if (_formKey.currentState!.validate()) {
      final drink = DrinkModel(
        id: '', // auto generated
        name: _nameController.text,
        imageUrl: _imageUrlController.text,
        caffeineinMg: double.parse(_caffeineController.text),
        standardVolume: int.parse(_volumeController.text),
        information: _infoController.text,
        isFavorite: _isFavorite,
      );

      await _drinkService.addDrink(drink);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Drink added successfully!')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Drink'),
        backgroundColor: const Color(0xFFD5BBA2),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Image URL',
                hintText: 'assets/images/coffee.png or https://...',
              ),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _caffeineController,
              decoration: const InputDecoration(labelText: 'Caffeine in mg'),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _volumeController,
              decoration: const InputDecoration(labelText: 'Standard Volume (mL)'),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _infoController,
              decoration: const InputDecoration(labelText: 'Information'),
              maxLines: 3,
            ),
            SwitchListTile(
              title: const Text('Is Favorite'),
              value: _isFavorite,
              onChanged: (v) => setState(() => _isFavorite = v),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveDrink,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4E8D7C),
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('Save Drink', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}