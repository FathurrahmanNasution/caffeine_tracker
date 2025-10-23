import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;
  
  const EmailVerificationPage({
    super.key,
    required this.email,
  });

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final _auth = AuthService();
  bool _isChecking = false;
  bool _canResend = true;
  int _resendTimer = 0;
  Timer? _timer;
  Timer? _checkTimer;

  @override
  void initState() {
    super.initState();
    _startAutoCheck();
  }

  void _startAutoCheck() {
    _checkTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) return;
      await _checkVerification(showMessage: false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _checkTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkVerification({bool showMessage = true}) async {
    if (_isChecking) return;
    
    setState(() => _isChecking = true);

    try {
      final isVerified = await _auth.checkEmailVerified();
      
      if (!mounted) return;

      if (isVerified) {
        _checkTimer?.cancel();
        _showSnackBar('Email verified successfully!', isError: false);
        
        await Future.delayed(const Duration(seconds: 1));
        
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/signin');
        }
      } else if (showMessage) {
        _showSnackBar('Email not verified yet. Please check your inbox.');
      }
    } catch (e) {
      if (mounted && showMessage) {
        _showSnackBar('Error checking verification: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  Future<void> _resendEmail() async {
    if (!_canResend) return;

    setState(() {
      _canResend = false;
      _resendTimer = 60;
    });

    try {
      await _auth.resendVerificationEmail();
      _showSnackBar('Verification email sent! Check your inbox.', isError: false);

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        
        setState(() {
          if (_resendTimer > 0) {
            _resendTimer--;
          } else {
            _canResend = true;
            timer.cancel();
          }
        });
      });
    } catch (e) {
      _showSnackBar('Failed to resend email: ${e.toString()}');
      setState(() {
        _canResend = true;
        _resendTimer = 0;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFF5D4037) : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8B899),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mail_outline,
                    size: 80,
                    color: Color(0xFF5D4037),
                  ),
                ),

                const SizedBox(height: 40),

                const Text(
                  'Verify Your Email',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3D2920),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'We\'ve sent a verification link to',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.brown[700],
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.email,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3D2920),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildStep(1, 'Check your email inbox'),
                      const SizedBox(height: 12),
                      _buildStep(2, 'Click the verification link'),
                      const SizedBox(height: 12),
                      _buildStep(3, 'Return to this app'),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

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
                      elevation: 2,
                    ),
                    onPressed: _isChecking ? null : () => _checkVerification(showMessage: true),
                    child: _isChecking
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            "I've Verified My Email",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: _canResend ? _resendEmail : null,
                  child: Text(
                    _canResend
                        ? 'Resend Verification Email'
                        : 'Resend in $_resendTimer seconds',
                    style: TextStyle(
                      color: _canResend ? const Color(0xFF5D4037) : Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5D4037)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Auto-checking verification status...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.brown[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/signin');
                  },
                  child: const Text(
                    'Back to Sign In',
                    style: TextStyle(
                      color: Color(0xFF3D2920),
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(int number, String text) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFF5D4037),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF3D2920),
            ),
          ),
        ),
      ],
    );
  }
}