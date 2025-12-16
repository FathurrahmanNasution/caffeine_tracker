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
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            itemCount: drinks.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const Padding(
                  padding: EdgeInsets.fromLTRB(12, 10, 12, 25),
                  child: Text(
                    'Manage Drinks',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.2,
                      fontFamily: 'Oswald',
                    ),
                  ),
                );
              }
              final drink = drinks[index - 1];
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
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDrinkCard(DrinkModel drink) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
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
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 90,
              height: 90,
              child: drink.imageUrl.startsWith('http')
                  ? Image.network(
                drink.imageUrl,
                fit: BoxFit.contain,
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
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.local_drink,
                    size: 40,
                    color: Color(0xFF6E3D2C),
                  );
                },
              ),
            ),
            const SizedBox(width: 14),
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
                  const SizedBox(height: 2),
                  Text(
                    '${drink.caffeineinMg}mg - ${drink.standardVolume}mL',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6E3D2C),
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (drink.information.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      drink.information,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
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
                  icon: const Icon(Icons.edit, color: Color(0xFF4E8D7C), size: 27),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminAddDrinkPage(drinkToEdit: drink),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Color(0xFFFF5151), size: 27),
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
                // Simpan context dan navigator sebelum async
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                try {
                  await _adminDrinkService.deleteDrink(drink.id);

                  if (mounted) {
                    navigator.pop(); // Tutup dialog
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Drink deleted successfully!'),
                        backgroundColor: Color(0xFF6E3D2C),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
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