import 'package:caffeine_tracker/model/user_model.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = AuthService();
  bool _loading = true;
  UserModel? _profile;
  final _displayNameCtrl = TextEditingController();
  final _photoUrlCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final u = _auth.currentUser;
    if (u == null) {
      if (mounted) Navigator.pushReplacementNamed(context, '/signin');
      return;
    }
    final doc = await _auth.getProfileDoc(u.uid);
    setState(() {
      _profile = UserModel.fromMap(u.uid, doc.data());
      _displayNameCtrl.text = _profile?.displayName ?? '';
      _photoUrlCtrl.text = _profile?.photoUrl ?? '';
      _loading = false;
    });
  }

  Future<void> _save() async {
    final u = _auth.currentUser;
    if (u == null) return;
    setState(() => _loading = true);
    final name = _displayNameCtrl.text.trim();
    final photo = _photoUrlCtrl.text.trim().isEmpty ? null : _photoUrlCtrl.text.trim();
    await _auth.updateProfile(u.uid, {'displayName': name, 'photoUrl': photo});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully'),
        backgroundColor: Color(0xFF5D4037),
        behavior: SnackBarBehavior.floating,
      ),
    );
    await _load();
  }

  Future<void> _handleSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
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

  @override
  void dispose() {
    _displayNameCtrl.dispose();
    _photoUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5EBE0),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFFD5BBA2),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Photo
            Center(
              child: Stack(
                children: [
                  if ((_profile?.photoUrl ?? '').isNotEmpty)
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(_profile!.photoUrl!),
                    )
                  else
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.brown[200],
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.brown,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Username (non-editable)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_outline, color: Color(0xFF5D4037)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Username',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _profile?.username ?? '-',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Email (non-editable)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.email_outlined, color: Color(0xFF5D4037)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _profile?.email ?? '-',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Display Name Field (editable)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _displayNameCtrl,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Display Name',
                  labelStyle: const TextStyle(color: Color(0xFF5D4037)),
                  prefixIcon: const Icon(
                    Icons.badge_outlined,
                    color: Color(0xFF5D4037),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Photo URL Field (editable)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _photoUrlCtrl,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Profile Photo URL (optional)',
                  labelStyle: const TextStyle(color: Color(0xFF5D4037)),
                  prefixIcon: const Icon(
                    Icons.image_outlined,
                    color: Color(0xFF5D4037),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D4037),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                onPressed: _save,
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Sign Out Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _handleSignOut,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Sign Out',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}