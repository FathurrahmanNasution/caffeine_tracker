import 'package:flutter/material.dart';
import 'package:caffeine_tracker/model/drink_model.dart';
import 'package:caffeine_tracker/services/admin_drink_service.dart';
import '../screens/admin_add_drink_page.dart';

class ManageDrinksPage extends StatefulWidget {
  const ManageDrinksPage({super.key});

  @override
  State<ManageDrinksPage> createState() => _ManageDrinksPageState();
}

class _ManageDrinksPageState extends State<ManageDrinksPage> {
  final _adminDrinkService = AdminDrinkService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EBE0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD5BBA2),
        elevation: 0,
        title: const Text(
          'Manage Drinks',
          style: TextStyle(
            color: Color(0xFF42261D),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF42261D)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<DrinkModel>>(
        stream: _adminDrinkService.getAllDrinks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6E3D2C)),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Color(0xFF6E3D2C)),
              ),
            );
          }

          final drinks = snapshot.data ?? [];

          if (drinks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_drink_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No drinks available',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: drinks.length,
            itemBuilder: (context, index) {
              final drink = drinks[index];
              return _buildDrinkCard(drink);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminAddDrinkPage(),
            ),
          );
        },
        backgroundColor: const Color(0xFF4E8D7C),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Drink',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDrinkCard(DrinkModel drink) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFD6CCC2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA67C52), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA67C52), width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: drink.imageUrl.startsWith('http')
                    ? Image.network(
                  drink.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.local_drink,
                      size: 40,
                      color: Color(0xFF6E3D2C),
                    );
                  },
                )
                    : Image.asset(
                  drink.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.local_drink,
                      size: 40,
                      color: Color(0xFF6E3D2C),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    drink.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF42261D),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${drink.caffeineinMg}mg - ${drink.standardVolume}mL',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6E3D2C),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  if (drink.information.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      drink.information,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Actions
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF4E8D7C)),
                  onPressed: () {
                    _showEditDialog(drink);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteDialog(drink);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(DrinkModel drink) {
    final nameController = TextEditingController(text: drink.name);
    final imageUrlController = TextEditingController(text: drink.imageUrl);
    final caffeineController = TextEditingController(text: drink.caffeineinMg.toString());
    final volumeController = TextEditingController(text: drink.standardVolume.toString());
    final infoController = TextEditingController(text: drink.information);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF5EBE0),
          title: const Text(
            'Edit Drink',
            style: TextStyle(
              color: Color(0xFF42261D),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(color: Color(0xFF6E3D2C)),
                  ),
                ),
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Image URL',
                    labelStyle: TextStyle(color: Color(0xFF6E3D2C)),
                  ),
                ),
                TextField(
                  controller: caffeineController,
                  decoration: const InputDecoration(
                    labelText: 'Caffeine (mg)',
                    labelStyle: TextStyle(color: Color(0xFF6E3D2C)),
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: volumeController,
                  decoration: const InputDecoration(
                    labelText: 'Volume (mL)',
                    labelStyle: TextStyle(color: Color(0xFF6E3D2C)),
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: infoController,
                  decoration: const InputDecoration(
                    labelText: 'Information',
                    labelStyle: TextStyle(color: Color(0xFF6E3D2C)),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF6E3D2C)),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _adminDrinkService.updateDrink(drink.id, {
                    'name': nameController.text,
                    'imageUrl': imageUrlController.text,
                    'caffeineinMg': double.parse(caffeineController.text),
                    'standardVolume': int.parse(volumeController.text),
                    'information': infoController.text,
                  });

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Drink updated successfully!'),
                        backgroundColor: Color(0xFF4E8D7C),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Color(0xFF4E8D7C), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(DrinkModel drink) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF5EBE0),
          title: const Text(
            'Delete Drink',
            style: TextStyle(
              color: Color(0xFF42261D),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${drink.name}"?',
            style: const TextStyle(color: Color(0xFF6E3D2C)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF6E3D2C)),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _adminDrinkService.deleteDrink(drink.id);

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Drink deleted successfully!'),
                        backgroundColor: Color(0xFF4E8D7C),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}