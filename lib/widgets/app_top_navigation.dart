import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:caffeine_tracker/model/user_model.dart';
import 'package:caffeine_tracker/services/auth_service.dart';

class AppTopNavigation extends StatelessWidget {
  final VoidCallback? onLogoTap;
  final bool showBackButton;

  const AppTopNavigation({
    super.key,
    this.onLogoTap,
    this.showBackButton = false,
  });

  Widget _buildProfileAvatar(UserModel? userProfile) {
    // Jika ada photo URL, gunakan CachedNetworkImage
    if (userProfile?.photoUrl != null && userProfile!.photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: const Color(0xFFE8DED1),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: userProfile.photoUrl!,
            key: ValueKey(userProfile.photoUrl), // Force reload on URL change
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF42261D)),
                ),
              ),
            ),
            errorWidget: (context, url, error) => _buildDefaultAvatar(userProfile),
          ),
        ),
      );
    }

    return _buildDefaultAvatar(userProfile);
  }

  Widget _buildDefaultAvatar(UserModel? userProfile) {
    String name = userProfile?.displayName ?? userProfile?.username ?? '';
    name = name.trim();
    String initial = (name.isNotEmpty) ? name[0].toUpperCase() : 'U';

    return CircleAvatar(
      radius: 20,
      backgroundColor: const Color(0xFFE8DED1),
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF42261D),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final auth = FirebaseAuth.instance;
    final authService = AuthService();

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      color: const Color(0xFFD5BBA2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Back button or empty space
          SizedBox(
            width: 40,
            child: showBackButton
                ? IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Color(0xFF42261D),
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                  )
                : const SizedBox(),
          ),

          // Center: Logo
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: onLogoTap ??
                    () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/dashboard',
                        (route) => false,
                      );
                    },
                child: Image.asset(
                  "assets/images/coffee.png",
                  height: height * 0.05,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.local_cafe, size: 40),
                ),
              ),
            ),
          ),

          // Right: Profile Menu Button with StreamBuilder
          StreamBuilder<UserModel?>(
            stream: auth.currentUser != null
                ? authService.getUserProfileStream(auth.currentUser!.uid)
                : null,
            builder: (context, snapshot) {
              final userProfile = snapshot.data;

              return PopupMenuButton<String>(
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white,
                child: _buildProfileAvatar(userProfile),
                itemBuilder: (BuildContext context) {
                  final user = auth.currentUser;
                  final email = user?.email ?? 'No email';
                  final displayName = userProfile?.displayName ??
                      userProfile?.username ??
                      'User';

                  return [
                    // Profile Header (non-clickable)
                    PopupMenuItem<String>(
                      enabled: false,
                      padding: EdgeInsets.zero,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFD6CCC2),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildProfileAvatar(userProfile),
                            const SizedBox(height: 12),
                            Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF000000),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF42261D),
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Divider
                    const PopupMenuItem<String>(
                      enabled: false,
                      height: 1,
                      padding: EdgeInsets.zero,
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFD6CCC2),
                      ),
                    ),

                    // Change Password
                    const PopupMenuItem<String>(
                      value: 'change_password',
                      padding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 2),
                          Icon(
                            Icons.lock_outline,
                            size: 22,
                            color: Color(0xFF5B3020),
                          ),
                          SizedBox(width: 16),
                          Text(
                            'Change Password',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF000000),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Divider
                    const PopupMenuItem<String>(
                      enabled: false,
                      height: 1,
                      padding: EdgeInsets.zero,
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFD6CCC2),
                      ),
                    ),

                    // Logout
                    const PopupMenuItem<String>(
                      value: 'logout',
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 2),
                          Icon(
                            Icons.logout_outlined,
                            size: 22,
                            color: Color(0xFF5B3020),
                          ),
                          SizedBox(width: 16),
                          Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF000000),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ];
                },
                onSelected: (String value) async {
                  if (value == 'change_password') {
                    Navigator.pushNamed(context, '/change-password');
                  } else if (value == 'logout') {
                    await auth.signOut();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/signin');
                    }
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
