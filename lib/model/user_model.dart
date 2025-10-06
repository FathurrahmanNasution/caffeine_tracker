import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String? username;
  final String? photoUrl;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.username,
    this.photoUrl,
    this.createdAt,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic>? map) {
    if (map == null) {
      return UserModel(uid: uid);
    }
    final ts = map['createdAt'];
    DateTime? created;
    if (ts is Timestamp) {
      created = ts.toDate();
    } else if (ts is DateTime) {
      created = ts;
    }
    return UserModel(
      uid: uid,
      email: map['email'] as String?,
      displayName: map['displayName'] as String?,
      username: map['username'] as String?,
      photoUrl: map['photoUrl'] as String?,
      createdAt: created,
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'displayName': displayName,
        'username': username,
        'photoUrl': photoUrl,
        'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
      };
}