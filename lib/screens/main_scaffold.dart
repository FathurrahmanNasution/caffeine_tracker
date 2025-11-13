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
  final GlobalKey<TrackerPageState> _trackerKey = GlobalKey(); // ✅ Added

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _refreshDashboard() {
    _dashboardKey.currentState?.refreshData();
  }

  void _refreshTracker() { // ✅ Added
    _trackerKey.currentState?.refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardPage(key: _dashboardKey),
          const CoffeeListPage(),
          TrackerPage(key: _trackerKey), // ✅ Added key
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != _currentIndex) {
            setState(() => _currentIndex = index);

            // ✅ Refresh based on tab
            if (index == 0) {
              _refreshDashboard();
            } else if (index == 2) {
              _refreshTracker();
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