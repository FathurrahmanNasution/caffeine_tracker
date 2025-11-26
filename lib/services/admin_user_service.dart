import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:caffeine_tracker/model/user_model.dart';

class AdminUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _usersCollection = 'users';

  /// Get all users (Stream)
  Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection(_usersCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Get user count
  Future<int> getUserCount() async {
    final snapshot = await _firestore.collection(_usersCollection).get();
    return snapshot.docs.length;
  }

  /// Get admin count
  Future<int> getAdminCount() async {
    final snapshot = await _firestore
        .collection(_usersCollection)
        .where('isAdmin', isEqualTo: true)
        .get();
    return snapshot.docs.length;
  }

  /// Get regular user count
  Future<int> getRegularUserCount() async {
    final snapshot = await _firestore
        .collection(_usersCollection)
        .where('isAdmin', isEqualTo: false)
        .get();
    return snapshot.docs.length;
  }

  /// Toggle user admin status
  Future<void> toggleAdminStatus(String userId, bool currentStatus) async {
    await _firestore.collection(_usersCollection).doc(userId).update({
      'isAdmin': !currentStatus,
    });
  }

  /// Delete user account
  Future<void> deleteUser(String userId) async {
    // Delete user document
    await _firestore.collection(_usersCollection).doc(userId).delete();

    // Delete user favorites
    await _deleteUserFavorites(userId);

    // Delete user consumptions
    await _deleteUserConsumptions(userId);
  }

  /// Delete all user favorites
  Future<void> _deleteUserFavorites(String userId) async {
    try {
      final favoritesSnapshot = await _firestore
          .collection('userFavorites')
          .doc(userId)
          .collection('favorites')
          .get();

      for (var doc in favoritesSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete userFavorites parent doc
      await _firestore.collection('userFavorites').doc(userId).delete();
    } catch (e) {
      // Ignore error if no favorites exist
    }
  }

  /// Delete all user consumptions
  Future<void> _deleteUserConsumptions(String userId) async {
    try {
      final consumptionsSnapshot = await _firestore
          .collection('consumptions')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in consumptionsSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      // Ignore error if no consumptions exist
    }
  }

  /// Search users by name or email
  Stream<List<UserModel>> searchUsers(String query) {
    return _firestore
        .collection(_usersCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final users = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.id, doc.data()))
          .toList();

      if (query.isEmpty) {
        return users;
      }

      final lowerQuery = query.toLowerCase();
      return users.where((user) {
        final nameMatch = user.displayName?.toLowerCase().contains(lowerQuery) ?? false;
        final usernameMatch = (user.username?.toLowerCase() ?? '').contains(lowerQuery);
        final emailMatch = (user.email?.toLowerCase() ?? '').contains(lowerQuery);
        return nameMatch || usernameMatch || emailMatch;
      }).toList();
    });
  }

  /// Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get user consumption count
  Future<int> getUserConsumptionCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('consumptions')
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  /// Get user total caffeine intake
  Future<double> getUserTotalCaffeine(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('consumptions')
          .where('userId', isEqualTo: userId)
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['caffeineContent'] as num?)?.toDouble() ?? 0;
      }
      return total;
    } catch (e) {
      return 0;
    }
  }
}