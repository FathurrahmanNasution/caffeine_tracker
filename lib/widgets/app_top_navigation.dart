import 'package:flutter/material.dart';
import 'package:caffeine_tracker/model/user_model.dart';

class AppTopNavigation extends StatelessWidget {
  final UserModel? userProfile;
  final VoidCallback? onLogoTap;
  final VoidCallback? onProfileTap;

  const AppTopNavigation({
    super.key,
    this.userProfile,
    this.onLogoTap,
    this.onProfileTap,
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
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: GestureDetector(
              onTap: onLogoTap ?? () => Navigator.pushNamed(context, '/dashboard'),
              child: Image.asset(
                "assets/images/coffee.png",
                height: height * 0.05,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.local_cafe, size: 40),
              ),
            ),
          ),
          Row(
            children: [
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onProfileTap ?? () => Navigator.pushNamed(context, '/profile'),
                child: CircleAvatar(
                  backgroundImage: userProfile?.photoUrl != null
                      ? NetworkImage(userProfile!.photoUrl!)
                      : null,
                  child: userProfile?.photoUrl == null
                      ? const Icon(Icons.person)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}