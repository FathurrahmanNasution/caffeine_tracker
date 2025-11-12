import 'package:flutter/material.dart';
import 'package:caffeine_tracker/screens/dashboard_page.dart';
import 'package:caffeine_tracker/screens/coffeelist_page.dart';
import 'package:caffeine_tracker/screens/tracker_page.dart';
import 'package:caffeine_tracker/screens/profile_page.dart';
import 'package:caffeine_tracker/widgets/app_bottom_navigation.dart';

class MainScaffold extends StatefulWidget {
  final int initialIndex;

  const MainScaffold({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _currentIndex;
  final GlobalKey<DashboardPageState> _dashboardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _refreshDashboard() {
    _dashboardKey.currentState?.refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardPage(key: _dashboardKey),
          const CoffeeListPage(),
          const TrackerPage(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != _currentIndex) {
            setState(() => _currentIndex = index);
            if (index == 0) {
              _refreshDashboard();
            }
          }
        },
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
        onPressed: () {
          setState(() => _currentIndex = 1);
        },
        backgroundColor: Colors.brown[800],
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}