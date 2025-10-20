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

  final List<Map<String, String>> _pages = [
    {
      "title": "Track Your Caffeine",
      "subtitle": "Easily log your coffee, tea, or energy drinks every day.",
    },
    {
      "title": "Stay Healthy",
      "subtitle": "Keep your caffeine intake balanced for better sleep.",
    },
    {
      "title": "Reach Your Goals",
      "subtitle": "Monitor daily, weekly, and monthly caffeine stats.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _controller,
        itemCount: _pages.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_cafe, size: 100, color: Colors.brown[400]),
                const SizedBox(height: 40),
                Text(
                  _pages[index]["title"]!,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Text(
                  _pages[index]["subtitle"]!,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
      bottomSheet: _currentIndex == _pages.length - 1
          ? Container(
              height: 60,
              width: double.infinity,
              color: Colors.brown,
              child: TextButton(
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .update({'hasCompletedOnboarding': true});
                  }
                  if (mounted) {
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  }
                },
                child: const Text(
                  "Get Started",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            )
          : Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      _controller.jumpToPage(_pages.length - 1);
                    },
                    child: const Text("Skip"),
                  ),
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentIndex == index
                              ? Colors.brown
                              : Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    },
                    child: const Text("Next"),
                  ),
                ],
              ),
            ),
    );
  }
}
