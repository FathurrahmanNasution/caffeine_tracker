import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController usernameController = TextEditingController();
  final _auth = AuthService();
  final _firestore = FirebaseFirestore.instance;
  bool _loading = false;

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  // Show Google account dialog - Responsive version
  void _showGoogleAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF5EBE0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16), // ✅ Reduced padding
          title: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.orange[700],
                size: 24, // ✅ Smaller icon
              ),
              const SizedBox(width: 10),
              const Expanded( // ✅ Make title responsive
                child: Text(
                  'Google Account',
                  style: TextStyle(
                    color: Color(0xFF42261D),
                    fontWeight: FontWeight.bold,
                    fontSize: 18, // ✅ Smaller font
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView( // ✅ Make scrollable
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This account is signed in with Google.',
                  style: TextStyle(
                    color: Color(0xFF42261D),
                    fontSize: 14, // ✅ Smaller font
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10), // ✅ Reduced spacing
                const Text(
                  'Password reset is not available for Google accounts.',
                  style: TextStyle(
                    color: Color(0xFF6E3D2C),
                    fontSize: 13, // ✅ Smaller font
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12), // ✅ Reduced spacing
                const Text(
                  'To change your password, visit:',
                  style: TextStyle(
                    color: Color(0xFF6E3D2C),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'myaccount.google.com',
                  style: TextStyle(
                    color: Color(0xFF4A7C59),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF6E3D2C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20, // ✅ Reduced padding
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Got it',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14, // ✅ Smaller font
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Show success dialog - Responsive version
  void _showSuccessDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF5EBE0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16), // ✅ Reduced padding
          title: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.green[700],
                size: 24, // ✅ Smaller icon
              ),
              const SizedBox(width: 10),
              const Expanded( // ✅ Make responsive
                child: Text(
                  'Reset Email Sent',
                  style: TextStyle(
                    color: Color(0xFF42261D),
                    fontWeight: FontWeight.bold,
                    fontSize: 18, // ✅ Smaller font
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView( // ✅ Make scrollable
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'We have sent a password reset link to:',
                  style: TextStyle(
                    color: Color(0xFF6E3D2C),
                    fontSize: 13, // ✅ Smaller font
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10), // ✅ Reduced padding
                  decoration: BoxDecoration(
                    color: const Color(0xFFD5BBA2).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        color: Color(0xFF6E3D2C),
                        size: 18, // ✅ Smaller icon
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          email,
                          style: const TextStyle(
                            color: Color(0xFF42261D),
                            fontWeight: FontWeight.bold,
                            fontSize: 13, // ✅ Smaller font
                          ),
                          overflow: TextOverflow.ellipsis, // ✅ Handle long emails
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12), // ✅ Reduced spacing
                const Text(
                  'Please check your email and click the link to reset your password.',
                  style: TextStyle(
                    color: Color(0xFF6E3D2C),
                    fontSize: 13, // ✅ Smaller font
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10), // ✅ Reduced spacing
                Container(
                  padding: const EdgeInsets.all(10), // ✅ Reduced padding
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue[200]!,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[700],
                        size: 18, // ✅ Smaller icon
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'The link will expire in 1 hour',
                          style: TextStyle(
                            color: Color(0xFF42261D),
                            fontSize: 11, // ✅ Smaller font
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF6E3D2C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20, // ✅ Reduced padding
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14, // ✅ Smaller font
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleSendResetEmail() async {
    final username = usernameController.text.trim();

    if (username.isEmpty) {
      _showSnackBar("Please enter your username");
      return;
    }

    setState(() => _loading = true);

    try {
      // Get email from username
      final email = await _auth.getEmailFromUsername(username);

      if (email == null) {
        setState(() => _loading = false);
        _showSnackBar("Username not found");
        return;
      }

      // Check if it's a Google account by checking Firestore
      bool isGoogle = false;

      try {
        final userQuery = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (userQuery.docs.isNotEmpty) {
          final userData = userQuery.docs.first.data();
          final authProvider = userData['authProvider'] as String?;

          //  Debug print to see what we're getting
          if (kDebugMode) {
            debugPrint('Found user with email: $email');
            debugPrint('AuthProvider field value: $authProvider');
          }

          //  Check if authProvider is 'google'
          if (authProvider == 'google') {
            isGoogle = true;
            if (kDebugMode) {
              debugPrint('Detected Google account!');
            }
          }
        } else {
          if (kDebugMode) {
            debugPrint('No user found in Firestore with email: $email');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Firestore check error: $e');
        }
      }

      // ✅ If Google account, show dialog and return early
      if (isGoogle) {
        setState(() => _loading = false);
        _showGoogleAccountDialog();
        return; // ✅ IMPORTANT: Stop here, don't send email
      }

      // ✅ Only send email if NOT Google account
      if (kDebugMode) {
        debugPrint('Sending password reset email to: $email');
      }

      await _auth.sendPasswordResetEmail(email);

      if (!mounted) return;
      setState(() => _loading = false);

      // Show success dialog
      _showSuccessDialog(email);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);

      String errorMessage = e.toString().replaceAll('Exception: ', '');

      // Handle specific Firebase errors
      if (errorMessage.contains('user-not-found')) {
        errorMessage = 'No account found with this username';
      } else if (errorMessage.contains('invalid-email')) {
        errorMessage = 'Invalid email address';
      }

      _showSnackBar(errorMessage);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF5D4037),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8B899),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD8B899),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3D2920)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Forgot Password',
          style: TextStyle(
            color: Color(0xFF3D2920),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 30),
            child: Image.asset(
              "assets/images/coffee.png",
              height: 100,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.brown.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.local_cafe,
                    size: 50,
                    color: Colors.brown,
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFE8E8E8),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Reset Your Password",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3D2920),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      "Enter your username and we'll send you a link to reset your password via email.",
                      style: TextStyle(
                        color: Color(0xFF5D4E47),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange[200]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Note: Password reset is not available for Google accounts',
                              style: TextStyle(
                                color: Color(0xFF42261D),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildLabeledTextField(
                      label: "Username",
                      controller: usernameController,
                      hintText: "Enter your username",
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5D4037),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                        ),
                        onPressed: _loading ? null : _handleSendResetEmail,
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                "Send Reset Link",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 18,
                          color: Color(0xFF4A7C59),
                        ),
                        label: const Text(
                          'Back to Sign In',
                          style: TextStyle(
                            color: Color(0xFF4A7C59),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF4A7C59),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(
                  color: Color(0xFF4A7C59),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}