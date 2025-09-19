import 'package:caffeine_tracker/screens/onboarding_page.dart';
import 'package:caffeine_tracker/screens/tracker_page.dart';
import 'package:flutter/material.dart';
import 'screens/landing_page.dart';
import 'screens/signup_page.dart';
import 'screens/signin_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/signup': (context) => const SignUpPage(),
        '/signin': (context) => const SignInPage(),
        '/onboarding': (context) => const OnboardingPage(),
        '/tracker': (context) => const TrackerPage()
      },
    );
  }
}
