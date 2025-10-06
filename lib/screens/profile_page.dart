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
    await _load();
  }

  @override
  void dispose() {
    _displayNameCtrl.dispose();
    _photoUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          if ((_profile?.photoUrl ?? '').isNotEmpty)
            CircleAvatar(radius: 40, backgroundImage: NetworkImage(_profile!.photoUrl!))
          else
            CircleAvatar(radius: 40, child: const Icon(Icons.person, size: 40)),
          const SizedBox(height: 12),
          Text('Username: ${_profile?.username ?? '-'}'),
          const SizedBox(height: 12),
          TextFormField(controller: _displayNameCtrl, decoration: const InputDecoration(labelText: 'Display Name')),
          const SizedBox(height: 12),
          TextFormField(controller: _photoUrlCtrl, decoration: const InputDecoration(labelText: 'Profile Photo URL (optional)')),
          const SizedBox(height: 18),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ]),
      ),
    );
  }
}
