import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:caffeine_tracker/model/consumption_log.dart';

class ConsumptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addConsumption(ConsumptionLog log) async {
    await _firestore.collection('consumptions').add(log.toMap());
  }

  Stream<List<ConsumptionLog>> getUserConsumptions(String userId) {
    return _firestore
        .collection('consumptions')
        .where('userId', isEqualTo: userId)
        .orderBy('consumedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ConsumptionLog.fromMap(doc.data(), doc.id))
        .toList());
  }
}