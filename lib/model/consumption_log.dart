import 'package:cloud_firestore/cloud_firestore.dart';

class ConsumptionLog {
  final String id;
  final String userId;
  final String drinkId;
  final String drinkName;
  final int servingSize; // mL
  final double caffeineContent; // mg
  final DateTime consumedAt;

  ConsumptionLog({
    required this.id,
    required this.userId,
    required this.drinkId,
    required this.drinkName,
    required this.servingSize,
    required this.caffeineContent,
    required this.consumedAt,
  });

  factory ConsumptionLog.fromMap(Map<String, dynamic> map, String documentId) {
    return ConsumptionLog(
      id: documentId,
      userId: map['userId'] ?? '',
      drinkId: map['drinkId'] ?? '',
      drinkName: map['drinkName'] ?? '',
      servingSize: map['servingSize'] ?? 0,
      caffeineContent: (map['caffeineContent'] ?? 0).toDouble(),
      consumedAt: (map['consumedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'drinkId': drinkId,
      'drinkName': drinkName,
      'servingSize': servingSize,
      'caffeineContent': caffeineContent,
      'consumedAt': Timestamp.fromDate(consumedAt),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}