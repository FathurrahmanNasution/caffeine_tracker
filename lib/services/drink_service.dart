import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:caffeine_tracker/model/drink_model.dart';

class DrinkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _drinksCollection = 'drinks';
  final String _favoritesCollection = 'userFavorites';

  // Get all drinks with favorite status for specific user
  Stream<List<DrinkModel>> getAllDrinksForUser(String userId) async* {
    await for (var drinksSnapshot in _firestore.collection(_drinksCollection).snapshots()) {
      final drinks = drinksSnapshot.docs
          .map((doc) => DrinkModel.fromMap(doc.data(), doc.id))
          .toList();

      // Get user's favorites
      final favSnapshot = await _firestore
          .collection(_favoritesCollection)
          .doc(userId)
          .collection('favorites')
          .get();

      final favIds = favSnapshot.docs.map((doc) => doc.id).toSet();

      // Set isFavorite for each drink (TANPA FILTER)
      for (var drink in drinks) {
        drink.isFavorite = favIds.contains(drink.id);
      }

      yield drinks; // Yield semua drinks
    }
  }

  // Get favorites only for specific user
  Stream<List<DrinkModel>> getFavoriteDrinksForUser(String userId) async* {
    await for (var favSnapshot in _firestore
        .collection(_favoritesCollection)
        .doc(userId)
        .collection('favorites')
        .snapshots()) {

      final favIds = favSnapshot.docs.map((doc) => doc.id).toList();

      if (favIds.isEmpty) {
        yield [];
        return;
      }

      // Get drink details
      final drinks = <DrinkModel>[];
      for (var drinkId in favIds) {
        final drinkDoc = await _firestore.collection(_drinksCollection).doc(drinkId).get();
        if (drinkDoc.exists) {
          final drink = DrinkModel.fromMap(drinkDoc.data()!, drinkDoc.id);
          drink.isFavorite = true;
          drinks.add(drink);
        }
      }

      yield drinks;
    }
  }

  // Get non-favorite drinks only
  Stream<List<DrinkModel>> getNonFavoriteDrinksForUser(String userId) async* {
    await for (var drinksSnapshot in _firestore.collection(_drinksCollection).snapshots()) {
      final drinks = drinksSnapshot.docs
          .map((doc) => DrinkModel.fromMap(doc.data(), doc.id))
          .toList();

      final favSnapshot = await _firestore
          .collection(_favoritesCollection)
          .doc(userId)
          .collection('favorites')
          .get();

      final favIds = favSnapshot.docs.map((doc) => doc.id).toSet();

      final nonFavoriteDrinks = <DrinkModel>[];
      for (var drink in drinks) {
        drink.isFavorite = favIds.contains(drink.id);
        if (!drink.isFavorite) {
          nonFavoriteDrinks.add(drink);
        }
      }

      yield nonFavoriteDrinks;
    }
  }

  // Get single drink by ID with favorite status
  Stream<DrinkModel?> getDrinkByIdForUser(String drinkId, String userId) async* {
    await for (var drinkDoc in _firestore.collection(_drinksCollection).doc(drinkId).snapshots()) {
      if (!drinkDoc.exists) {
        yield null;
        return;
      }

      final drink = DrinkModel.fromMap(drinkDoc.data()!, drinkDoc.id);

      // Check if favorite
      final favDoc = await _firestore
          .collection(_favoritesCollection)
          .doc(userId)
          .collection('favorites')
          .doc(drinkId)
          .get();

      drink.isFavorite = favDoc.exists;
      yield drink;
    }
  }

  // Toggle favorite
  Future<void> toggleFavorite(String userId, String drinkId, bool currentStatus) async {
    final favRef = _firestore
        .collection(_favoritesCollection)
        .doc(userId)
        .collection('favorites')
        .doc(drinkId);

    if (currentStatus) {
      // Remove from favorites
      await favRef.delete();
    } else {
      // Add to favorites
      await favRef.set({
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Add new drink (admin only)
  Future<void> addDrink(DrinkModel drink) async {
    await _firestore.collection(_drinksCollection).add(drink.toMap());
  }

  // Update drink (admin only)
  Future<void> updateDrink(String id, Map<String, dynamic> data) async {
    await _firestore.collection(_drinksCollection).doc(id).update(data);
  }

  // Delete drink (admin only)
  Future<void> deleteDrink(String id) async {
    await _firestore.collection(_drinksCollection).doc(id).delete();
  }

  // Check if drink is favorite
  Future<bool> isFavorite(String userId, String drinkId) async {
    final doc = await _firestore
        .collection(_favoritesCollection)
        .doc(userId)
        .collection('favorites')
        .doc(drinkId)
        .get();
    return doc.exists;
  }
}