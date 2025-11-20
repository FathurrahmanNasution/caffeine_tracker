import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../model/user_model.dart';
import '../widgets/admin_action_card.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final _auth = AuthService();
  UserModel? _userProfile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/signin');
      }
      return;
    }

    try {
      final doc = await _auth.getProfileDoc(user.uid);
      if (mounted) {
        setState(() {
          _userProfile = UserModel.fromMap(user.uid, doc.data());
          _loading = false;
        });

        // Check if user is actually admin
        if (_userProfile?.isAdmin != true) {
          _showSnackBar('Access denied. Admin privileges required.');
          await _auth.signOut();
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/landing');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _handleSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF5EBE0),
          title: const Text(
            'Sign Out',
            style: TextStyle(
              color: Color(0xFF42261D),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to sign out?',
            style: TextStyle(color: Color(0xFF6E3D2C)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF6E3D2C)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _auth.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/landing');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF6E3D2C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5EBE0),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6E3D2C)),
          ),
        ),
      );
    }

    final displayName = _userProfile?.displayName ?? _userProfile?.username ?? 'Admin';

    return Scaffold(
      backgroundColor: const Color(0xFFF5EBE0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD5BBA2),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Image.asset(
            "assets/images/coffee.png",
            height: 45,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: _handleSignOut,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hi there,',
                      style: TextStyle(
                        fontSize: 19,
                        color: Color(0xff42261d),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 19,
                        color: Color(0xff42261d),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            const Text(
              'Manage Your\nApp Data',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.2,
                fontFamily: 'Oswald',
              ),
            ),

            const SizedBox(height: 40),

            AdminActionCard(
              icon: Icons.local_drink,
              title: 'Manage Drinks',
              subtitle: 'Add, edit, or remove drinks',
              onTap: () {
                Navigator.pushNamed(context, '/admin_managedrinks');
              },
            ),

            AdminActionCard(
              icon: Icons.people,
              title: 'View Users',
              subtitle: 'Manage user accounts',
              onTap: () {
                _showSnackBar('Feature coming soon');
              },
            ),
          ],
        ),
      ),
    );
  }
}