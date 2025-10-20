import 'package:caffeine_tracker/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fire = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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
            'authProvider': 'email',
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

  Future<UserModel?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user == null) return null;

      // Check if this is a new user
      final userRef = _fire.collection('users').doc(user.uid);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        // Create new user document for first-time Google sign in
        final email = user.email ?? '';
        final displayName = user.displayName ?? '';
        
        // Generate a username from email or displayName
        String generatedUsername = _generateUsernameFromEmail(email);
        
        // Ensure username is unique
        generatedUsername = await _ensureUniqueUsername(generatedUsername);

        await userRef.set({
          'uid': user.uid,
          'email': email,
          'displayName': displayName,
          'username': generatedUsername,
          'photoUrl': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'authProvider': 'google',
          'hasCompletedOnboarding': false,
        });

        // Create username mapping
        await _fire.collection('usernames').doc(generatedUsername).set({
          'uid': user.uid,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Update existing user's photo if changed
        if (user.photoURL != null) {
          await userRef.update({
            'photoUrl': user.photoURL,
          });
        }
      }

      final updatedDoc = await userRef.get();
      return UserModel.fromMap(user.uid, updatedDoc.data());
    } on FirebaseAuthException catch (e) {
      throw Exception('Google Sign In failed: ${e.message}');
    } catch (e) {
      throw Exception('Google Sign In error: $e');
    }
  }

  String _generateUsernameFromEmail(String email) {
    // Extract username part from email (before @)
    String username = email.split('@')[0];
    
    // Remove any non-alphanumeric characters except underscore
    username = username.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    
    // Convert to lowercase
    username = username.toLowerCase();
    
    // Ensure it's between 3-30 characters
    if (username.length < 3) {
      username = '${username}_user';
    }
    if (username.length > 30) {
      username = username.substring(0, 30);
    }
    
    return username;
  }

  Future<String> _ensureUniqueUsername(String baseUsername) async {
    String username = baseUsername;
    int counter = 1;
    
    while (true) {
      final unameDoc = await _fire.collection('usernames').doc(username).get();
      if (!unameDoc.exists) {
        return username;
      }
      
      // Username exists, try with a number suffix
      username = '${baseUsername}_$counter';
      counter++;
      
      // Ensure it doesn't exceed 30 characters
      if (username.length > 30) {
        username = '${baseUsername.substring(0, 25)}_$counter';
      }
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

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