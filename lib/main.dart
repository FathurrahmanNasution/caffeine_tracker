import 'package:caffeine_tracker/screens/account_authorization_page.dart';
import 'package:caffeine_tracker/screens/addotherdrink_page.dart';
import 'package:caffeine_tracker/screens/admin_add_drink_page.dart';
import 'package:caffeine_tracker/screens/change_password_page.dart';
import 'package:caffeine_tracker/screens/coffeelist_page.dart';
import 'package:caffeine_tracker/screens/dashboard_page.dart';
import 'package:caffeine_tracker/screens/drinkinformation_page.dart';
import 'package:caffeine_tracker/screens/email_verification_page.dart';
import 'package:caffeine_tracker/screens/landing_page.dart';
import 'package:caffeine_tracker/screens/onboarding_page.dart';
import 'package:caffeine_tracker/screens/profile_page.dart';
import 'package:caffeine_tracker/screens/signin_page.dart';
import 'package:caffeine_tracker/screens/signup_page.dart';
import 'package:caffeine_tracker/screens/splash_screen.dart';
import 'package:caffeine_tracker/screens/tracker_page.dart';
import 'package:caffeine_tracker/screens/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/landing': (context) => const LandingPage(),
        '/signup': (context) => const SignUpPage(),
        '/signin': (context) => const SignInPage(),
        '/accountauthorization': (context) => const AccountAuthorizationPage(),
        '/change-password': (context) => const ChangePasswordPage(),
        '/onboarding': (context) => const OnboardingPage(),
        '/dashboard': (context) => const MainScaffold(initialIndex: 0),
        '/coffeelist': (context) => const MainScaffold(initialIndex: 1),
        '/logs': (context) => const MainScaffold(initialIndex: 2),
        '/profile': (context) => const MainScaffold(initialIndex: 3),
        '/drinkinformation': (context) => const DrinkinformationPage(),
        '/addotherdrink': (context) => const AddotherdrinkPage(),
        '/admin': (context) => const AdminAddDrinkPage(),
      },
      onGenerateRoute: (settings) {
        // Handle email verification route with arguments
        if (settings.name == '/email-verification') {
          final email = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => EmailVerificationPage(email: email),
          );
        }

        // Return null to let the routes map handle it
        return null;
      },
    );
  }
}