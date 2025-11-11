import 'package:flutter/material.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFF6E3D2C),
      unselectedItemColor: const Color(0xFFA67C52),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      onTap: (int index) {
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/dashboard');
            break;
          case 1:
            Navigator.pushNamed(context, '/coffeelist');
            break;
          case 2:
            Navigator.pushNamed(context, '/logs');
            break;
          case 3:
            Navigator.pushNamed(context, '/profile');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.emoji_food_beverage_outlined),
          label: "Add Drinks",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_outlined),
          label: "Logs",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ),
      ],
    );
  }
}