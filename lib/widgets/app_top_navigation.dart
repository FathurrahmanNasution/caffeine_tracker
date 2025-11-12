import 'package:flutter/material.dart';
import 'package:caffeine_tracker/model/user_model.dart';

class AppTopNavigation extends StatelessWidget {
  final UserModel? userProfile;
  final VoidCallback? onLogoTap;
  final VoidCallback? onProfileTap;
  final bool showBackButton; // control back button visibility

  const AppTopNavigation({
    super.key,
    this.userProfile,
    this.onLogoTap,
    this.onProfileTap,
    this.showBackButton = false, // default false buat main pages
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
                : const SizedBox(), // empty kalo ga perlu back button
          ),

          // Center: Logo
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: onLogoTap ?? () {
                  // Navigate ke dashboard (MainScaffold index 0)
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

          // Right: Profile avatar
          GestureDetector(
            onTap: onProfileTap ?? () {
              // Navigate ke profile (MainScaffold index 3)
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/profile',
                    (route) => false,
              );
            },
            child: CircleAvatar(
              radius: 20,
              backgroundImage: userProfile?.photoUrl != null
                  ? NetworkImage(userProfile!.photoUrl!)
                  : null,
              child: userProfile?.photoUrl == null
                  ? const Icon(Icons.person, size: 20)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}