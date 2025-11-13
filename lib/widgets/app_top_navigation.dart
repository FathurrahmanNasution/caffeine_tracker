import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:caffeine_tracker/model/user_model.dart';

class AppTopNavigation extends StatelessWidget {
  final UserModel? userProfile;
  final VoidCallback? onLogoTap;
  final bool showBackButton;

  const AppTopNavigation({
    super.key,
    this.userProfile,
    this.onLogoTap,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;

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
                onTap:
                    onLogoTap ??
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

          GestureDetector(
            onTap: () {
              print('Profile icon tapped');
              _showProfileMenu(context);
            },
            child: CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFE8DED1),
              backgroundImage: userProfile?.photoUrl != null
                  ? NetworkImage(userProfile!.photoUrl!)
                  : null,
              child: userProfile?.photoUrl == null
                  ? const Icon(Icons.person, size: 20, color: Color(0xFF42261D))
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    print('Showing profile menu');

    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    final email = user?.email ?? 'No email';
    final displayName =
        userProfile?.displayName ?? userProfile?.username ?? 'User';

    showDialog(
      context: context,
      barrierColor: Colors.black26,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          alignment: Alignment.topRight,
          insetPadding: const EdgeInsets.only(top: 80, right: 20),
          backgroundColor: Colors.transparent,
          child: Container(
            width: 280,
            decoration: BoxDecoration(
              color: const Color(0xFFD6CCC2),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Profile Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFD6CCC2),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF000000),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF42261D),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFD6CCC2),
                ),

                _buildMenuItem(
                  context: context,
                  icon: Icons.lock_outline,
                  label: 'Change Password',
                  backgroundColor: const Color(0xFFF5EBE0),
                  textColor: const Color(0xFF000000),
                  iconColor: const Color(0xFF5B3020),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    Navigator.pushNamed(context, '/changepassword');
                  },
                ),

                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFD6CCC2),
                ),

                _buildMenuItem(
                  context: context,
                  icon: Icons.logout_outlined,
                  label: 'Logout',
                  backgroundColor: const Color(0xFFF5EBE0),
                  textColor: const Color(0xFF000000),
                  iconColor: const Color(0xFF5B3020),
                  onTap: () async {
                    Navigator.pop(dialogContext);
                    await auth.signOut();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/signin');
                    }
                  },
                  isLast: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? backgroundColor,
    Color? textColor,
    Color? iconColor,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: isLast
              ? const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: iconColor ?? Colors.grey[800]),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: textColor ?? Colors.grey[800],
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
