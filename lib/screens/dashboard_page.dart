import 'package:caffeine_tracker/model/consumption_log.dart';
import 'package:caffeine_tracker/services/consumption_service.dart';
import 'package:caffeine_tracker/widgets/app_top_navigation.dart';
import 'package:caffeine_tracker/widgets/caffeine_chart.dart';
import 'package:caffeine_tracker/widgets/consumption_log_card.dart';
import 'package:flutter/material.dart';
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
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  final _consumptionService = ConsumptionService();

  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? "";

  Map<String, dynamic> _getCurrentWeekRange() {
    final now = DateTime.now();
    final dayOfMonth = now.day;

    final weekStart = ((dayOfMonth - 1) ~/ 7) * 7 + 1;
    final weekEnd = weekStart + 6;

    return {
      'start': weekStart,
      'end': weekEnd,
      'currentDay': dayOfMonth,
    };
  }

  bool _shouldShowDataPoint(dynamic key) {
    final now = DateTime.now();
    final targetDay = key as int;
    final targetDate = DateTime(now.year, now.month, targetDay);

    return targetDate.isBefore(now) ||
        (targetDate.year == now.year &&
            targetDate.month == now.month &&
            targetDate.day == now.day);
  }

  Map<int, double> weeklyData = {
    0: 0,
    1: 0,
    2: 0,
    3: 0,
    4: 0,
    5: 0,
    6: 0,
  };

  Map<int, List<ConsumptionLog>> weeklyDrinks = {
    0: [],
    1: [],
    2: [],
    3: [],
    4: [],
    5: [],
    6: [],
  };

  List<String> _getWeekLabels() {
    final weekRange = _getCurrentWeekRange();
    final startDay = weekRange['start'] as int;
    final endDay = weekRange['end'] as int;

    List<String> labels = [];
    for (int i = startDay; i <= endDay; i++) {
      labels.add('$i');
    }
    return labels;
  }

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
    _loadWeeklyData();
  }

  void refreshData() {
    _loadWeeklyData();
  }

  void _loadWeeklyData() {
    final now = DateTime.now();
    final weekRange = _getCurrentWeekRange();
    final startDay = weekRange['start'] as int;
    final endDay = weekRange['end'] as int;
    final currentDay = weekRange['currentDay'] as int;

    final startDate = DateTime(now.year, now.month, startDay);
    final endDate = DateTime(now.year, now.month, endDay, 23, 59, 59);

    _consumptionService.getUserConsumptions(currentUserId).listen((logs) {
      final weekLogs = logs.where((log) {
        return log.consumedAt.isAfter(startDate.subtract(Duration(days: 1))) &&
            log.consumedAt.isBefore(endDate.add(Duration(days: 1)));
      }).toList();

      Map<int, double> newWeeklyData = {};
      Map<int, List<ConsumptionLog>> newWeeklyDrinks = {};

      for (int i = startDay; i <= endDay; i++) {
        newWeeklyData[i] = 0;
        newWeeklyDrinks[i] = [];
      }

      for (var log in weekLogs) {
        final day = log.consumedAt.day;
        if (day <= currentDay) {
          newWeeklyData[day] = (newWeeklyData[day] ?? 0) + log.caffeineContent;
          newWeeklyDrinks[day]!.add(log);
        }
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

    if (drinks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No drinks at that day'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        double totalCaffeine =
            drinks.fold(0, (sum, d) => sum + d.caffeineContent);

        return AlertDialog(
          backgroundColor: const Color(0xFFD6CCC2),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Day $dayIndex',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000000),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.brown[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${totalCaffeine.toStringAsFixed(1)}mg',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: drinks.length,
              itemBuilder: (context, index) {
                final d = drinks[index];
                return Container(
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
                              d.drinkName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              '${d.caffeineContent.toStringAsFixed(1)}mg ~ ${d.servingSize}ml',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6E3D2C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(color: Color(0xFF6E3D2C), fontSize: 16),
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
      const SnackBar(content: Text('Drink deleted successfully')),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5EBE0),
      body: Column(
        children: [
          const AppTopNavigation(),
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
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi there,',
                            style: TextStyle(
                              fontSize: 19,
                              color: Color(0xff42261d),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'User',
                            style: TextStyle(
                              fontSize: 19,
                              color: Color(0xff42261d),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(
                            color: const Color(0xff42261d),
                            width: 2,
                          ),
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
                    labels: _getWeekLabels(),
                    onTap: (key) => _showDrinkDetails(context, key),
                    shouldShowPoint: _shouldShowDataPoint,
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
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 42,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF52796F),
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
                      onTap: () =>
                          Navigator.pushNamed(context, '/drinkinformation'),
                      onDelete: () => _showDeleteDialog(index),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/coffeelist'),
        backgroundColor: Colors.brown[800],
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}