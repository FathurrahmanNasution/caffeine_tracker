import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String? username;
  final String? photoUrl;
  final DateTime? createdAt;
  final bool isAdmin;
  final bool emailVerified;
  final String? authProvider; 

  UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.username,
    this.photoUrl,
    this.createdAt,
    this.isAdmin = false,
    this.emailVerified = false,
    this.authProvider,
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
      authProvider: map['authProvider'] as String?,
      createdAt: created,
      isAdmin: map['isAdmin'] as bool? ?? false,
      emailVerified: map['emailVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'displayName': displayName,
        'username': username,
        'photoUrl': photoUrl,
        'authProvider': authProvider,
        'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
        'isAdmin': isAdmin,
        'emailVerified': emailVerified,
      };

  
  bool get isGoogleUser => authProvider == 'google';
  bool get isEmailPasswordUser => authProvider == 'email';
}