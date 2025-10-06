import 'package:caffeine_tracker/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fire = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  String _normalize(String username) => username.trim().toLowerCase();

  Future<UserModel?> signUpWithUsername({
    required String username,
    required String email,
    required String password,
    String? displayName,
  }) async {
    final uname = _normalize(username);
    final emailNorm = email.trim();

    final usernameValid = RegExp(r'^[a-z0-9_]{3,30}$').hasMatch(uname);
    if (!usernameValid) {
      throw Exception('Username invalid. Use 3-30 chars: a-z, 0-9, underscore.');
    }

    // Create Auth user
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: emailNorm,
        password: password,
      );
      final user = cred.user;
      if (user == null) return null;

      final unameRef = _fire.collection('usernames').doc(uname);
      final userRef = _fire.collection('users').doc(user.uid);

      try {
        await _fire.runTransaction((tx) async {
          final unameSnap = await tx.get(unameRef);
          if (unameSnap.exists) {
            throw Exception('username-taken');
          }
          tx.set(userRef, {
            'uid': user.uid,
            'email': emailNorm,
            'displayName': displayName ?? '',
            'username': uname,
            'photoUrl': null,
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          tx.set(unameRef, {
            'uid': user.uid,
            'email': emailNorm,
            'createdAt': FieldValue.serverTimestamp(),
          });
        });
      } catch (e) {
        // Delete auth user so we don't leave orphaned account
        try {
          await user.delete();
        } catch (_) {}
        if (e.toString().contains('username-taken')) {
          throw Exception('Username already taken.');
        }
        rethrow;
      }

      if (displayName != null && displayName.isNotEmpty) {
        await user.updateDisplayName(displayName);
        await user.reload();
      }

      final doc = await userRef.get();
      return UserModel.fromMap(user.uid, doc.data());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') throw Exception('Email already in use.');
      rethrow;
    }
  }

  Future<UserModel?> signInWithUsername(String username, String password) async {
    final uname = _normalize(username);
    final unameRef = _fire.collection('usernames').doc(uname);
    final unameDoc = await unameRef.get();
    if (!unameDoc.exists) throw Exception('Username not found.');
    final data = unameDoc.data();
    final email = (data?['email'] as String?)?.trim();
    if (email == null || email.isEmpty) throw Exception('Internal mapping missing email.');
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final user = cred.user;
    if (user == null) return null;
    final userDoc = await _fire.collection('users').doc(user.uid).get();
    return UserModel.fromMap(user.uid, userDoc.data());
  }

  Future<void> signOut() => _auth.signOut();

  Future<DocumentSnapshot<Map<String, dynamic>>> getProfileDoc(String uid) {
    return _fire.collection('users').doc(uid).get();
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await _fire.collection('users').doc(uid).set(data, SetOptions(merge: true));
    final user = _auth.currentUser;
    if (user != null && data.containsKey('displayName')) {
      await user.updateDisplayName(data['displayName'] as String?);
      await user.reload();
    }
  }
}
