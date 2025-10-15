import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:caffeine_tracker/model/drink_model.dart';

class DrinkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'drinks';

  // Get all drinks
  Stream<List<DrinkModel>> getAllDrinks() {
    return _firestore
          .collection(_collection)
          .where('isFavorite', isEqualTo: false)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
            .map((doc) => DrinkModel.fromMap(doc.data(), doc.id))
            .toList(),
    );
  }

  // Get favorites only
  Stream<List<DrinkModel>> getFavoriteDrinks() {
    return _firestore
        .collection(_collection)
        .where('isFavorite', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => DrinkModel.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }

  // Get single drink by ID
  Stream<DrinkModel?> getDrinkById(String id) {
    return _firestore.collection(_collection).doc(id).snapshots().map(
          (doc) => doc.exists ? DrinkModel.fromMap(doc.data()!, doc.id) : null,
    );
  }

  // Get single drink by ID (Future - one time fetch)
  Future<DrinkModel?> getDrinkByIdOnce(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    return doc.exists ? DrinkModel.fromMap(doc.data()!, doc.id) : null;
  }

  // Add new drink
  Future<void> addDrink(DrinkModel drink) async {
    await _firestore.collection(_collection).add(drink.toMap());
  }

  // Add drink with custom ID
  Future<void> addDrinkWithId(String id, DrinkModel drink) async {
    await _firestore.collection(_collection).doc(id).set(drink.toMap());
  }

  // Update drink
  Future<void> updateDrink(String id, Map<String, dynamic> data) async {
    await _firestore.collection(_collection).doc(id).update(data);
  }

  // Update entire drink
  Future<void> updateEntireDrink(String id, DrinkModel drink) async {
    await _firestore.collection(_collection).doc(id).set(drink.toMap());
  }

  // Toggle favorite
  Future<void> toggleFavorite(String id, bool currentStatus) async {
    await _firestore.collection(_collection).doc(id).update({
      'isFavorite': !currentStatus,
    });
  }

  // Delete drink
  Future<void> deleteDrink(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  // Search drinks by name
  Stream<List<DrinkModel>> searchDrinks(String query) {
    return _firestore
        .collection(_collection)
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => DrinkModel.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }

  // Get drinks count
  Future<int> getDrinksCount() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs.length;
  }

  // Check if drink exists
  Future<bool> drinkExists(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    return doc.exists;
  }
}