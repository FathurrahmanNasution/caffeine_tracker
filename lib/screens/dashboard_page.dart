import 'package:caffeine_tracker/model/user_model.dart';
import 'package:caffeine_tracker/model/consumption_log.dart';
import 'package:caffeine_tracker/services/consumption_service.dart';
import 'package:caffeine_tracker/widgets/app_bottom_navigation.dart';
import 'package:caffeine_tracker/widgets/app_top_navigation.dart';
import 'package:caffeine_tracker/widgets/caffeine_chart.dart';
import 'package:caffeine_tracker/widgets/consumption_log_card.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Drink {
  final String name;
  final String caffeine;
  final String size;
  final String time;
  final String image;

  Drink({
    required this.name,
    required this.caffeine,
    required this.size,
    required this.time,
    required this.image,
  });
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _auth = AuthService();
  final _consumptionService = ConsumptionService();
  UserModel? _userProfile;
  bool _loading = true;

  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? "";

  Map<int, double> weeklyData = {
    0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0,
  };

  Map<int, List<ConsumptionLog>> weeklyDrinks = {
    0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: [],
  };

  List<Drink> drinks = [
    Drink(
      name: 'Americano',
      caffeine: '83mg',
      size: '240ml',
      time: '09:25 AM',
      image: '☕',
    ),
    Drink(
      name: 'Espresso',
      caffeine: '63mg',
      size: '30ml (shot)',
      time: '02:20 PM',
      image: '☕',
    ),
    Drink(
      name: 'Frappuccino',
      caffeine: '65mg',
      size: '355ml',
      time: '',
      image: '🥤',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadWeeklyData();
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
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _loadWeeklyData() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    final startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endDate = startDate.add(const Duration(days: 7));

    _consumptionService.getUserConsumptions(currentUserId).listen((logs) {
      final weekLogs = logs.where((log) {
        return log.consumedAt.isAfter(startDate) &&
            log.consumedAt.isBefore(endDate);
      }).toList();

      Map<int, double> newWeeklyData = {
        0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0,
      };

      Map<int, List<ConsumptionLog>> newWeeklyDrinks = {
        0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: [],
      };

      for (var log in weekLogs) {
        int dayOfWeek = log.consumedAt.weekday == 7 ? 0 : log.consumedAt.weekday;
        newWeeklyData[dayOfWeek] = (newWeeklyData[dayOfWeek] ?? 0) + log.caffeineContent;
        newWeeklyDrinks[dayOfWeek]?.add(log);
      }

      if (mounted) {
        setState(() {
          weeklyData = newWeeklyData;
          weeklyDrinks = newWeeklyDrinks;
        });
      }
    });
  }

  void _showDrinkDetails(BuildContext context, dynamic dayIndex) {
    final drinks = weeklyDrinks[dayIndex] ?? [];
    final dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

    if (drinks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No drinks consumed on ${dayNames[dayIndex]}'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        double totalCaffeine = drinks.fold(0, (sum, drink) => sum + drink.caffeineContent);

        return AlertDialog(
          title: Text(
            '${dayNames[dayIndex]}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF6E3D2C),
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD5BBA2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Total: ${totalCaffeine.toStringAsFixed(1)}mg',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF6E3D2C),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Drinks consumed:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF6E3D2C),
                  ),
                ),
                const SizedBox(height: 8),
                ...drinks.map((drink) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5EBE0),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFA67C52)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.brown[800],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              drink.drinkName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${drink.caffeineContent.toStringAsFixed(1)}mg • ${drink.servingSize}ml',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6E3D2C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(color: Color(0xFF6E3D2C)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteDrink(int index) {
    setState(() {
      drinks.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Drink deleted successfully'))
    );
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Drink'),
          content: const Text('Are you sure you want to delete this drink?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteDrink(index);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5EBE0),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final displayName = _userProfile?.displayName ?? _userProfile?.username ?? 'User';

    return Scaffold(
      backgroundColor: const Color(0xFFF5EBE0),
      body: Column(
        children: [
          AppTopNavigation(
            userProfile: _userProfile,
          ),
          Expanded(
            child: SingleChildScrollView(
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: const Color(0xff42261d), width: 2),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Text(
                          'Oct 17th, 2025',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xff5b3020),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  const Text(
                    'Track your\nCaffeine Journey',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.2,
                      fontFamily: 'Oswald',
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Caffeine Info
                  const Text(
                    'Today Caffeine in Take: 158mg',
                    style: TextStyle(
                      fontSize: 17,
                      color: Color(0xff6e3d2c),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Chart Widget
                  CaffeineChart(
                    data: weeklyData,
                    type: ChartType.weekly,
                    labels: const ['S', 'M', 'T', 'W', 'T', 'F', 'S'],
                    onTap: (key) => _showDrinkDetails(context, key),
                  ),
                  const SizedBox(height: 40),

                  // Drinks Section
                  const Text(
                    'Drinks of the day',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff4b2c20),
                      fontFamily: 'Oswald',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 42),
                      decoration: BoxDecoration(
                        color: Color(0xFF52796F),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          children: [
                            TextSpan(text: 'You still need '),
                            TextSpan(
                              text: '300 mg ',
                              style: TextStyle(
                                color: Color(0xFFD6CCC2),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(text: 'of caffeine today!'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Drink Cards
                  ...drinks.asMap().entries.map((entry) {
                    int index = entry.key;
                    Drink drink = entry.value;
                    return ConsumptionLogCard(
                      name: drink.name,
                      caffeine: drink.caffeine,
                      size: drink.size,
                      time: drink.time,
                      image: drink.image,
                      onTap: () => Navigator.pushNamed(context, '/drinkinformation'),
                      onDelete: () => _showDeleteDialog(index),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 0),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/coffeelist'),
        backgroundColor: Colors.brown[800],
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}