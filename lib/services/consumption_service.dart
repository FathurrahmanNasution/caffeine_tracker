import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:caffeine_tracker/model/consumption_log.dart';

class ConsumptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'consumptionLogs';

  // Add consumption log
  Future<void> addConsumption(ConsumptionLog log) async {
    await _firestore.collection(_collection).add(log.toMap());
  }

  // Get user's consumption logs (untuk Logs page nanti)
  Stream<List<ConsumptionLog>> getUserConsumptions(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('consumedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ConsumptionLog.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Get today's total caffeine (untuk Home page nanti)
  Future<double> getTodayCaffeine(String userId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('consumedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .get();

    double total = 0;
    for (var doc in snapshot.docs) {
      total += (doc.data()['caffeineContent'] ?? 0).toDouble();
    }
    return total;
  }

  // Delete log
  Future<void> deleteLog(String logId) async {
    await _firestore.collection(_collection).doc(logId).delete();
  }
}