import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:caffeine_tracker/model/consumption_log.dart';

class ConsumptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all user consumptions (descending order - newest first)
  Stream<List<ConsumptionLog>> getUserConsumptions(String userId) {
    return _firestore
        .collection('consumptions')
        .where('userId', isEqualTo: userId)
        .orderBy('consumedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ConsumptionLog.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get user consumptions for a specific date (now uses descending order too)
  Stream<List<ConsumptionLog>> getUserConsumptionsForDate(String userId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _firestore
        .collection('consumptions')
        .where('userId', isEqualTo: userId)
        .orderBy('consumedAt', descending: true) // ✅ Changed to descending
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ConsumptionLog.fromMap(doc.data(), doc.id))
          .where((log) {
        // Filter in-memory for the specific date range
        return log.consumedAt.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
            log.consumedAt.isBefore(endOfDay.add(const Duration(seconds: 1)));
      }).toList();
    });
  }

  // Add a new consumption
  Future<void> addConsumption(ConsumptionLog log) async {
    await _firestore.collection('consumptions').add(log.toMap());
  }

  // Update an existing consumption
  Future<void> updateConsumption(String id, ConsumptionLog log) async {
    await _firestore.collection('consumptions').doc(id).update(log.toMap());
  }

  // Delete a consumption
  Future<void> deleteConsumption(String id) async {
    await _firestore.collection('consumptions').doc(id).delete();
  }

  // Get a single consumption by ID
  Future<ConsumptionLog?> getConsumptionById(String id) async {
    final doc = await _firestore.collection('consumptions').doc(id).get();
    if (doc.exists) {
      return ConsumptionLog.fromMap(doc.data()!, doc.id);
    }
    return null;
  }
}