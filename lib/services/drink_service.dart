import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:caffeine_tracker/model/drink_model.dart';
import 'package:rxdart/rxdart.dart';

class DrinkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _drinksCollection = 'drinks';
  final String _favoritesCollection = 'userFavorites';

  // Get favorites only for specific user
  Stream<List<DrinkModel>> getFavoriteDrinksForUser(String userId) {
    return Rx.combineLatest2(
      _firestore.collection(_drinksCollection).snapshots(),
      _firestore.collection(_favoritesCollection).doc(userId).collection('favorites').snapshots(),
          (QuerySnapshot drinksSnapshot, QuerySnapshot favSnapshot) {
        final allDrinks = {
          for (var doc in drinksSnapshot.docs)
            doc.id: DrinkModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)
        };

        final favIds = favSnapshot.docs.map((doc) => doc.id).toList();

        final favoriteDrinks = <DrinkModel>[];
        for (var drinkId in favIds) {
          final drink = allDrinks[drinkId];
          if (drink != null) {
            drink.isFavorite = true;
            favoriteDrinks.add(drink);
          }
        }

        return favoriteDrinks;
      },
    );
  }

  Future<DrinkModel?> getDrinkById(String drinkId) async {
    try {
      final doc = await _firestore.collection('drinks').doc(drinkId).get();
      if (doc.exists && doc.data() != null) {
        return DrinkModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting drink by ID: $e');
      return null;
    }
  }

  // Get non-favorite drinks only
  Stream<List<DrinkModel>> getNonFavoriteDrinksForUser(String userId) {
    return Rx.combineLatest2(
      _firestore.collection(_drinksCollection).snapshots(),
      _firestore.collection(_favoritesCollection).doc(userId).collection('favorites').snapshots(),
          (QuerySnapshot drinksSnapshot, QuerySnapshot favSnapshot) {
        final drinks = drinksSnapshot.docs
            .map((doc) => DrinkModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        final favIds = favSnapshot.docs.map((doc) => doc.id).toSet();

        final nonFavoriteDrinks = <DrinkModel>[];
        for (var drink in drinks) {
          drink.isFavorite = favIds.contains(drink.id);
          if (!drink.isFavorite) {
            nonFavoriteDrinks.add(drink);
          }
        }

        return nonFavoriteDrinks;
      },
    );
  }

  Stream<List<DrinkModel>> searchFavoriteDrinks(String userId, String query) {
    return Rx.combineLatest2(
      _firestore.collection(_drinksCollection).snapshots(),
      _firestore.collection(_favoritesCollection).doc(userId).collection('favorites').snapshots(),
          (QuerySnapshot drinksSnapshot, QuerySnapshot favSnapshot) {
        final allDrinks = {
          for (var doc in drinksSnapshot.docs)
            doc.id: DrinkModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)
        };

        final favIds = favSnapshot.docs.map((doc) => doc.id).toList();

        final favoriteDrinks = <DrinkModel>[];
        for (var drinkId in favIds) {
          final drink = allDrinks[drinkId];
          if (drink != null) {
            drink.isFavorite = true;
            favoriteDrinks.add(drink);
          }
        }

        // Filter berdasarkan query
        if (query.isEmpty) {
          return favoriteDrinks;
        }

        final lowerQuery = query.toLowerCase();
        return favoriteDrinks.where((drink) {
          return drink.name.toLowerCase().contains(lowerQuery);
        }).toList();
      },
    );
  }

  Stream<List<DrinkModel>> searchNonFavoriteDrinks(String userId, String query) {
    return Rx.combineLatest2(
      _firestore.collection(_drinksCollection).snapshots(),
      _firestore.collection(_favoritesCollection).doc(userId).collection('favorites').snapshots(),
          (QuerySnapshot drinksSnapshot, QuerySnapshot favSnapshot) {
        final drinks = drinksSnapshot.docs
            .map((doc) => DrinkModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        final favIds = favSnapshot.docs.map((doc) => doc.id).toSet();

        final nonFavoriteDrinks = <DrinkModel>[];
        for (var drink in drinks) {
          drink.isFavorite = favIds.contains(drink.id);
          if (!drink.isFavorite) {
            nonFavoriteDrinks.add(drink);
          }
        }

        // Filter berdasarkan query
        if (query.isEmpty) {
          return nonFavoriteDrinks;
        }

        final lowerQuery = query.toLowerCase();
        return nonFavoriteDrinks.where((drink) {
          return drink.name.toLowerCase().contains(lowerQuery);
        }).toList();
      },
    );
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
}