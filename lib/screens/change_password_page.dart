import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ChangePasswordPage extends StatefulWidget {
  final String? resetCode; // Optional - from email link

  const ChangePasswordPage({super.key, this.resetCode});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final _auth = AuthService();

  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _loading = false;
  bool _isResetMode = false;

  @override
  void initState() {
    super.initState();
    _isResetMode = widget.resetCode != null;
    if (_isResetMode) {
      _verifyResetCode();
    }
  }

  Future<void> _verifyResetCode() async {
    if (widget.resetCode == null) return;

    setState(() => _loading = true);

    try {
      final isValid = await _auth.verifyPasswordResetCode(widget.resetCode!);
      if (!isValid) {
        if (!mounted) return;
        _showSnackBar('Invalid or expired reset link');
        Navigator.pushReplacementNamed(context, '/signin');
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error verifying reset link');
      Navigator.pushReplacementNamed(context, '/signin');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSavePassword() async {
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar("Please fill in all fields");
      return;
    }

    if (newPassword.length < 6) {
      _showSnackBar("Password must be at least 6 characters");
      return;
    }

    if (newPassword != confirmPassword) {
      _showSnackBar("Passwords do not match");
      return;
    }

    setState(() => _loading = true);

    try {
      if (_isResetMode && widget.resetCode != null) {
        // Reset password using code from email
        await _auth.confirmPasswordReset(widget.resetCode!, newPassword);

        if (!mounted) return;
        _showSnackBar("Password reset successfully!", isError: false);
      } else {
        // Update password for logged-in user
        await _auth.updatePassword(newPassword);

        if (!mounted) return;
        _showSnackBar("Password changed successfully!", isError: false);
      }

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/signin');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFF5D4037) : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8B899),
      appBar: _isResetMode
          ? null
          : AppBar(
              backgroundColor: const Color(0xFFD8B899),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF3D2920)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
      body: Column(
        children: [
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
                    Text(
                      _isResetMode ? "Reset Password" : "Change Password",
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3D2920),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _isResetMode
                          ? "Enter your new password"
                          : "Please enter your new password",
                      style: const TextStyle(
                        color: Color(0xFF5D4E47),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildLabeledTextField(
                      label: "New Password",
                      controller: newPasswordController,
                      hintText: "Enter new password",
                      isPassword: true,
                      isVisible: _isNewPasswordVisible,
                      onVisibilityToggle: () {
                        setState(() {
                          _isNewPasswordVisible = !_isNewPasswordVisible;
                        });
                      },
                    ),
                    const SizedBox(height: 18),
                    _buildLabeledTextField(
                      label: "Password Confirmation",
                      controller: confirmPasswordController,
                      hintText: "Re-enter new password",
                      isPassword: true,
                      isVisible: _isConfirmPasswordVisible,
                      onVisibilityToggle: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
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
                        onPressed: _loading ? null : _handleSavePassword,
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
                            : Text(
                                _isResetMode
                                    ? "Reset Password"
                                    : "Save New Password",
                                style: const TextStyle(
                                  fontSize: 16,
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
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && !isVisible,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        isVisible ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                      onPressed: onVisibilityToggle,
                    )
                  : null,
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
