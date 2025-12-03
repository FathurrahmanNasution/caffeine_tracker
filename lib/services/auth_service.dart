import 'package:caffeine_tracker/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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

    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: emailNorm,
        password: password,
      );
      final user = cred.user;
      if (user == null) {
        return null;
      }

      final unameRef = _firestore.collection('usernames').doc(uname);
      final userRef = _firestore.collection('users').doc(user.uid);

      try {
        await _firestore.runTransaction((tx) async {
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
            'emailVerified': false,
          }, SetOptions(merge: true));

          tx.set(unameRef, {
            'uid': user.uid,
            'email': emailNorm,
            'createdAt': FieldValue.serverTimestamp(),
          });
        });

      } catch (e) {
        try {
          await user.delete();
        } catch (deleteError) {
          throw Exception('Could not delete auth user: $deleteError');
        }
        if (e.toString().contains('username-taken')) {
          throw Exception('Username already taken.');
        }
        rethrow;
      }

      if (displayName != null && displayName.isNotEmpty) {
        await user.updateDisplayName(displayName);
        await user.reload();
      }

      try {
        await user.sendEmailVerification();
      } catch (emailError) {
        // Email sending failed, but continue - user can resend from verification page
      }

      final doc = await userRef.get();
      return UserModel.fromMap(user.uid, doc.data());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('Email already in use.');
      }
      rethrow;
    }
  }

  // Check if user is admin
  Future<bool> isAdmin(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      return userDoc.data()?['isAdmin'] as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  // Admin sign in - bypasses email verification
  Future<UserModel?> signInAsAdmin(String username, String password) async {
    final uname = _normalize(username);
    
    final unameRef = _firestore.collection('usernames').doc(uname);
    final unameDoc = await unameRef.get();
    
    if (!unameDoc.exists) {
      throw Exception('Username not found.');
    }
    
    final data = unameDoc.data();
    final email = (data?['email'] as String?)?.trim();
    
    if (email == null || email.isEmpty) {
      throw Exception('Internal mapping missing email.');
    }
    
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final user = cred.user;
    
    if (user == null) {
      return null;
    }

    // Check if user is admin
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data();
    final isAdminUser = userData?['isAdmin'] as bool? ?? false;

    if (!isAdminUser) {
      await _auth.signOut();
      throw Exception('Access denied. Admin privileges required.');
    }

    // Admin doesn't need email verification
    return UserModel.fromMap(user.uid, userData);
  }

  // Regular user sign in - requires email verification
  Future<UserModel?> signInWithUsername(String username, String password) async {
    final uname = _normalize(username);
    
    final unameRef = _firestore.collection('usernames').doc(uname);
    final unameDoc = await unameRef.get();
    
    if (!unameDoc.exists) {
      throw Exception('Username not found.');
    }
    
    final data = unameDoc.data();
    final email = (data?['email'] as String?)?.trim();
    
    if (email == null || email.isEmpty) {
      throw Exception('Internal mapping missing email.');
    }
    
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final user = cred.user;
    
    if (user == null) {
      return null;
    }

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data();
    final isAdminUser = userData?['isAdmin'] as bool? ?? false;

    // If admin, allow login without email verification
    if (isAdminUser) {
      return UserModel.fromMap(user.uid, userData);
    }

    // Regular users need email verification
    if (!user.emailVerified) {
      await _auth.signOut();
      throw Exception('Please verify your email before signing in. Check your inbox.');
    }
    
    await _firestore.collection('users').doc(user.uid).update({
      'emailVerified': true,
    });
    
    return UserModel.fromMap(user.uid, userData);
  }

  // Create admin user (should be called manually or through a secure admin panel)
  Future<UserModel?> createAdminUser({
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

    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: emailNorm,
        password: password,
      );
      final user = cred.user;
      if (user == null) {
        return null;
      }

      final unameRef = _firestore.collection('usernames').doc(uname);
      final userRef = _firestore.collection('users').doc(user.uid);

      try {
        await _firestore.runTransaction((tx) async {
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
            'emailVerified': true,
            'isAdmin': true,
            'hasCompletedOnboarding': true,
          }, SetOptions(merge: true));

          tx.set(unameRef, {
            'uid': user.uid,
            'email': emailNorm,
            'createdAt': FieldValue.serverTimestamp(),
          });
        });

      } catch (e) {
        try {
          await user.delete();
        } catch (deleteError) {
          throw Exception('Could not delete auth user: $deleteError');
        }
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
      if (e.code == 'email-already-in-use') {
        throw Exception('Email already in use.');
      }
      rethrow;
    }
  }

  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    
    if (user == null) {
      throw Exception('No user is currently signed in');
    }
    
    if (user.emailVerified) {
      return;
    }
    
    try {
      await user.sendEmailVerification();
    } catch (e) {
      if (e.toString().contains('too-many-requests')) {
        throw Exception('Too many attempts. Please wait a few minutes before trying again.');
      }
      throw Exception('Failed to send email. Please try again later.');
    }
  }

  Future<bool> checkEmailVerified() async {
    final user = _auth.currentUser;
    
    if (user == null) {
      return false;
    }
    
    await user.reload();
    final updatedUser = _auth.currentUser;
    
    if (updatedUser != null && updatedUser.emailVerified) {
      try {
        await _firestore.collection('users').doc(updatedUser.uid).update({
          'emailVerified': true,
        });
      } catch (e) {
        // Firestore update failed, but email is verified
      }
      return true;
    }
    
    return false;
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user == null) return null;

      final userRef = _firestore.collection('users').doc(user.uid);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        final email = user.email ?? '';
        final displayName = user.displayName ?? '';
        
        String generatedUsername = _generateUsernameFromEmail(email);
        generatedUsername = await _ensureUniqueUsername(generatedUsername);

        await userRef.set({
          'uid': user.uid,
          'email': email,
          'displayName': displayName,
          'username': generatedUsername,
          'photoUrl': user.photoURL,
          'authProvider': 'google',
          'emailVerified': true,
          'isAdmin': false,
          'createdAt': FieldValue.serverTimestamp(),
        });

        await _firestore.collection('usernames').doc(generatedUsername).set({
          'uid': user.uid,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        
        await userRef.update({
          'photoUrl': user.photoURL,
          'authProvider': 'google',
          'emailVerified': true,
        });
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
    String username = email.split('@')[0];
    username = username.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    username = username.toLowerCase();
    
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
      final unameDoc = await _firestore.collection('usernames').doc(username).get();
      if (!unameDoc.exists) {
        return username;
      }
      
      username = '${baseUsername}_$counter';
      counter++;
      
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
    return _firestore.collection('users').doc(uid).get();
  }

  Stream<UserModel?> getUserProfileStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) {
          if (doc.exists && doc.data() != null) {
            return UserModel.fromMap(uid, doc.data()!);
          }
          return null;
        });
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).set(data, SetOptions(merge: true));
    final user = _auth.currentUser;
    if (user != null && data.containsKey('displayName')) {
      await user.updateDisplayName(data['displayName'] as String?);
      await user.reload();
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found with this email address.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Invalid email address.');
      } else if (e.code == 'too-many-requests') {
        throw Exception('Too many requests. Please try again later.');
      }
      throw Exception('Failed to send password reset email: ${e.message}');
    }
  }

  // Verify password reset code
  Future<bool> verifyPasswordResetCode(String code) async {
    try {
      await _auth.verifyPasswordResetCode(code);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Confirm password reset with code
  Future<void> confirmPasswordReset(String code, String newPassword) async {
    try {
      await _auth.confirmPasswordReset(code: code, newPassword: newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'expired-action-code') {
        throw Exception('Reset link has expired. Please request a new one.');
      } else if (e.code == 'invalid-action-code') {
        throw Exception('Invalid or already used reset link.');
      } else if (e.code == 'weak-password') {
        throw Exception('Password is too weak. Please use a stronger password.');
      }
      throw Exception('Failed to reset password: ${e.message}');
    }
  }

  // Get email from username (for forgot password flow)
  Future<String?> getEmailFromUsername(String username) async {
    try {
      final uname = _normalize(username);
      final unameRef = _firestore.collection('usernames').doc(uname);
      final unameDoc = await unameRef.get();
      
      if (!unameDoc.exists) {
        return null;
      }
      
      final data = unameDoc.data();
      return data?['email'] as String?;
    } catch (e) {
      return null;
    }
  }

  // Update password for logged-in user (for dashboard change password)
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }
      
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception('Please sign out and sign in again before changing your password.');
      } else if (e.code == 'weak-password') {
        throw Exception('Password is too weak. Please use a stronger password.');
      }
      throw Exception('Failed to update password: ${e.message}');
    }
  }
}