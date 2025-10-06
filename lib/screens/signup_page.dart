import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _auth = AuthService();

  bool _isPasswordVisible = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8B899),
      body: Column(
        children: [
          // Logo section with fixed height
          Container(
            padding: const EdgeInsets.only(top: 40, bottom: 30),
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

          // Card Container - Expanded to fill remaining space
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
                    const Center(
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3D2920),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Center(
                      child: Text(
                        "We are so excited you're ready to become apart of our coffee network! don't forget check out your perks!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF5D4E47),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Username Field
                    _buildLabeledTextField(
                      label: "Username",
                      controller: usernameController,
                      hintText: "Enter username",
                      icon: Icons.person_outline,
                    ),

                    const SizedBox(height: 18),

                    // Email Field
                    _buildLabeledTextField(
                      label: "Email",
                      controller: emailController,
                      hintText: "Type your email",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 18),

                    // Password Field
                    _buildLabeledTextField(
                      label: "Password",
                      controller: passwordController,
                      hintText: "Type your password",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      isVisible: _isPasswordVisible,
                      onVisibilityToggle: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),

                    const SizedBox(height: 28),

                    // Register Button
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
                        onPressed: _loading ? null : _handleSignUp,
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                "Register",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Already have account
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account? ",
                            style: TextStyle(
                              color: Color(0xFF6D6D6D),
                              fontSize: 13,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                context,
                                '/signin',
                              );
                            },
                            child: const Text(
                              "Sign In",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3D2920),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Google Sign In Button
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          icon: Image.asset(
                            "assets/images/google_logo.png",
                            height: 24,
                            width: 24,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.g_mobiledata,
                                size: 32,
                                color: Colors.red,
                              );
                            },
                          ),
                          onPressed: () {
                            _handleGoogleSignIn();
                          },
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
    required IconData icon,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onVisibilityToggle,
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
            keyboardType: keyboardType,
            obscureText: isPassword && !isVisible,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        isVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                      onPressed: onVisibilityToggle,
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
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

  Future<void> _handleSignUp() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar("Please fill in all fields");
      return;
    }

    if (password.length < 6) {
      _showSnackBar("Password must be at least 6 characters");
      return;
    }

    setState(() => _loading = true);

    try {
      final user = await _auth.signUpWithUsername(
        username: username,
        email: email,
        password: password,
        displayName: null,
      );
      if (!mounted) return;

      if (user != null) {
        _showSnackBar("Account created successfully! Please sign in.");
        Navigator.pushReplacementNamed(context, '/signin');
      } else {
        _showSnackBar("Sign up failed. Please try again.");
      }
    } catch (err) {
      if (!mounted) return;
      
      final msg = err.toString();
      if (msg.contains('Username already taken')) {
        _showSnackBar('Username already taken. Choose another.');
      } else if (msg.contains('Email already in use')) {
        _showSnackBar('Email already in use.');
      } else if (msg.contains('Username invalid')) {
        _showSnackBar('Username must be 3-30 characters (a-z, 0-9, underscore)');
      } else {
        _showSnackBar(msg.replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _handleGoogleSignIn() {
    _showSnackBar("Google Sign In coming soon");
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF5D4037),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}