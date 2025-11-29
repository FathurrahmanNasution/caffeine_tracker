import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentIndex = 0;
  String _displayName = "";

  @override
  void initState() {
    super.initState();
    _loadDisplayName();
  }

  void _loadDisplayName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.displayName != null) {
      setState(() {
        _displayName = user.displayName!;
      });
    }
  }

  final List<Map<String, String>> _pages = [
    {
      "title": "Record your every day drink",
      "subtitle":
          "Log every coffee, tea, or energy drink with ease—type, amount, and time—all seamlessly synced with your personal calendar.",
    },
    {
      "title": "Visualize your habits",
      "subtitle":
          "Stay on top of your weekly trends with clean graphs that show when you caffeinate the most.",
    },
    {
      "title": "Stay balance insightfully",
      "subtitle":
          "Get personalized reminders and weekly insights that help you enjoy caffeine without overdoing it.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD5BBA2),
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  children: [
                    const SizedBox(height: 80),
                    // Welcome text
                    Text(
                      _displayName.isEmpty
                          ? "Welcome!"
                          : "Welcome, $_displayName!",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4B2C20),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Image container with circle background
                    SizedBox(
                      width: double.infinity,
                      height: 280,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          // Large circle background centered
                          Container(
                            width: MediaQuery.of(context).size.width * 0.85,
                            height: MediaQuery.of(context).size.width * 0.85,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF5EBE0),
                              shape: BoxShape.circle,
                            ),
                          ),
                          // Image centered - now uses index to show different images
                          Image.asset(
                            "assets/images/onboarding${index + 1}.png",
                            height: 150,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback icon if image not found
                              return const Icon(
                                Icons.local_cafe,
                                size: 120,
                                color: Color(0xFF6B4E3D),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    // Title
                    Text(
                      _pages[index]["title"]!,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    // Subtitle
                    Text(
                      _pages[index]["subtitle"]!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4B2C20),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
          // Bottom section with indicators and button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              child: Column(
                children: [
                  // Page indicators (coffee beans)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentIndex >= index
                              ? const Color(0xFF471D12)
                              : const Color(0xFF4A3428).withOpacity(0.3),
                        ),
                        child: Center(
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentIndex >= index
                                  ? const Color(0xFF6E3D2C)
                                  : Colors.transparent,
                            ),
                            child: _currentIndex >= index
                                ? Center(
                                    child: Container(
                                      width: 8,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF874C2B),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(4),
                                        ),
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_currentIndex == _pages.length - 1) {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .update({'hasCompletedOnboarding': true});
                          }
                          if (mounted) {
                            Navigator.pushReplacementNamed(
                              context,
                              '/dashboard',
                            );
                          }
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF874C2B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentIndex == _pages.length - 1
                                ? "Get Started"
                                : "Continue",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
