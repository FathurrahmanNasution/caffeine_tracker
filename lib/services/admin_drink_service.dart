import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:caffeine_tracker/model/drink_model.dart';
import 'dart:developer' as developer;

class AdminDrinkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _drinksCollection = 'drinks';

  // Get all drinks (for admin)
  Stream<List<DrinkModel>> getAllDrinks() {
    return _firestore.collection(_drinksCollection).snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => DrinkModel.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }

  // Add new drink
  Future<void> addDrink(DrinkModel drink) async {
    await _firestore.collection(_drinksCollection).add(drink.toMap());
  }

  // Update drink
  Future<void> updateDrink(String id, Map<String, dynamic> data) async {
    await _firestore.collection(_drinksCollection).doc(id).update(data);
  }

  // Delete drink
  Future<void> deleteDrink(String id) async {
    // Delete the drink document
    await _firestore.collection(_drinksCollection).doc(id).delete();

    // Optional: Clean up all user favorites for this drink
    await _deleteFromAllUserFavorites(id);
  }

  // Private helper to remove drink from all user favorites
  Future<void> _deleteFromAllUserFavorites(String drinkId) async {
    try {
      final userFavoritesSnapshot = await _firestore.collection('userFavorites').get();

      for (var userDoc in userFavoritesSnapshot.docs) {
        await _firestore
            .collection('userFavorites')
            .doc(userDoc.id)
            .collection('favorites')
            .doc(drinkId)
            .delete();
      }
    } catch (e) {
      // If error occurs, just log it (don't block the main delete operation)
      developer.log('Error cleaning up favorites: $e', name: 'AdminDrinkService');
    }
  }

  // Get drink by ID
  Future<DrinkModel?> getDrinkById(String id) async {
    try {
      final doc = await _firestore.collection(_drinksCollection).doc(id).get();
      if (doc.exists) {
        return DrinkModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      developer.log('Error getting drink: $e', name: 'AdminDrinkService');
      return null;
    }
  }

  // Search drinks by name
  Stream<List<DrinkModel>> searchDrinks(String query) {
    return _firestore.collection(_drinksCollection).snapshots().map(
          (snapshot) {
        final drinks = snapshot.docs
            .map((doc) => DrinkModel.fromMap(doc.data(), doc.id))
            .toList();

        if (query.isEmpty) {
          return drinks;
        }

        final lowerQuery = query.toLowerCase();
        return drinks.where((drink) {
          return drink.name.toLowerCase().contains(lowerQuery);
        }).toList();
      },
    );
  }
}