import 'package:caffeine_tracker/services/drink_service.dart';
import 'package:intl/intl.dart';
import 'package:caffeine_tracker/model/consumption_log.dart';
import 'package:caffeine_tracker/model/user_model.dart';
import 'package:caffeine_tracker/services/consumption_service.dart';
import 'package:caffeine_tracker/widgets/app_top_navigation.dart';
import 'package:caffeine_tracker/widgets/caffeine_chart.dart';
import 'package:caffeine_tracker/widgets/consumption_log_card.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  final _consumptionService = ConsumptionService();
  final DrinkService _drinkService = DrinkService();
  final double maxCaffeineLimit = 400; // Maximum daily caffeine in mg

  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? "";

  Future<String> _getDrinkImage(String drinkId) async {
    try {
      final drink = await _drinkService.getDrinkById(drinkId);
      if (drink != null && drink.imageUrl.isNotEmpty) {
        return drink.imageUrl;
      }
      return '☕';
    } catch (e) {
      return '☕';
    }
  }

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

  // Calculate total caffeine for today
  double _calculateTotalCaffeine(List<ConsumptionLog> logs) {
    return logs.fold(0.0, (sum, log) => sum + log.caffeineContent);
  }

  // Get message based on caffeine intake
  String _getCaffeineMessage(double totalCaffeine) {
    if (totalCaffeine == 0) {
      return "You still need ${maxCaffeineLimit.toInt()} mg";
    } else if (totalCaffeine < maxCaffeineLimit) {
      return "You have drunk ${totalCaffeine.toInt()} mg caffeine today";
    } else if (totalCaffeine == maxCaffeineLimit) {
      return "You have hit the limit for maximum caffeine intake!";
    } else {
      double exceeded = totalCaffeine - maxCaffeineLimit;
      return "Warning! You exceeded the limit by ${exceeded.toInt()} mg!";
    }
  }

  // Get color based on caffeine intake
  Color _getCaffeineColor(double totalCaffeine) {
    if (totalCaffeine == 0) {
      return const Color(0xFF4E8D7C); // Green - no intake
    } else if (totalCaffeine < maxCaffeineLimit * 0.8) {
      return const Color(0xFF4E8D7C); // Green - under 80% limit
    } else if (totalCaffeine < maxCaffeineLimit) {
      return const Color(0xFFF9A825); // Yellow - warning zone (80-100%)
    } else {
      return const Color(0xFFFF5151); // Red - over limit
    }
  }

  // Get icon based on caffeine intake
  IconData _getCaffeineIcon(double totalCaffeine) {
    if (totalCaffeine == 0) {
      return Icons.local_cafe_outlined;
    } else if (totalCaffeine < maxCaffeineLimit) {
      return Icons.check_circle_outline;
    } else if (totalCaffeine == maxCaffeineLimit) {
      return Icons.warning_amber_rounded;
    } else {
      return Icons.error_outline;
    }
  }

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

  String _formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  Future<void> _editConsumption(ConsumptionLog log) async {
    final result = await Navigator.pushNamed(
      context,
      '/drinkinformation',
      arguments: log,
    );

    if (result == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _deleteConsumption(ConsumptionLog log) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Drink'),
          content: Text('Are you sure you want to delete ${log.drinkName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Color(0xFFFF5151)),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _consumptionService.deleteConsumption(log.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Drink deleted successfully')),
        );
      }
    }
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
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(currentUserId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          String displayName = 'User';

                          if (snapshot.hasData && snapshot.data!.exists) {
                            final user = UserModel.fromMap(
                              currentUserId,
                              snapshot.data!.data() as Map<String, dynamic>?,
                            );
                            displayName = user.displayName ?? 'User';
                          }

                          return Column(
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
                          );
                        },
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
                        child: Text(
                          DateFormat('MMM d, y').format(DateTime.now()),
                          style: const TextStyle(
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

                  // Caffeine Info - Dynamic with enhanced logic
                  StreamBuilder<List<ConsumptionLog>>(
                    stream: _consumptionService.getUserConsumptionsForDate(
                      currentUserId,
                      DateTime.now(),
                    ),
                    builder: (context, snapshot) {
                      double todayCaffeine = 0;
                      if (snapshot.hasData) {
                        todayCaffeine = _calculateTotalCaffeine(snapshot.data!);
                      }

                      return Text(
                        'Today Caffeine in Take: ${todayCaffeine.toStringAsFixed(0)}mg',
                        style: const TextStyle(
                          fontSize: 17,
                          color: Color(0xff6e3d2c),
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
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

                  // Enhanced daily caffeine status with icon and color
                  StreamBuilder<List<ConsumptionLog>>(
                    stream: _consumptionService.getUserConsumptionsForDate(
                      currentUserId,
                      DateTime.now(),
                    ),
                    builder: (context, snapshot) {
                      double todayCaffeine = 0;
                      if (snapshot.hasData) {
                        todayCaffeine = _calculateTotalCaffeine(snapshot.data!);
                      }

                      return Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 24,
                          ),
                          decoration: BoxDecoration(
                            color: _getCaffeineColor(todayCaffeine),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getCaffeineIcon(todayCaffeine),
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  _getCaffeineMessage(todayCaffeine),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),

                  // Drink Cards - From Firebase - MODIFIED TO BE SCROLLABLE
                  StreamBuilder<List<ConsumptionLog>>(
                    stream: _consumptionService.getUserConsumptionsForDate(
                      currentUserId,
                      DateTime.now(),
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              'No drinks logged today',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF6E3D2C),
                              ),
                            ),
                          ),
                        );
                      }

                      final todayDrinks = snapshot.data!;

                      // Replaced Column with SizedBox + ListView.builder
                      return SizedBox(
                        height: 250, // Fixed height to allow scrolling
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: todayDrinks.length,
                          itemBuilder: (context, index) {
                            final log = todayDrinks[index];
                            return FutureBuilder<String>(
                              future: _getDrinkImage(log.drinkId),
                              builder: (context, imageSnapshot) {
                                final imageUrl = imageSnapshot.data ?? '☕';

                                return ConsumptionLogCard(
                                  name: log.drinkName,
                                  caffeine:
                                      '${log.caffeineContent.toStringAsFixed(0)}mg',
                                  size: '${log.servingSize}ml',
                                  time: _formatTime(log.consumedAt),
                                  image: imageUrl,
                                  onTap: () => _editConsumption(log),
                                  onDelete: () => _deleteConsumption(log),
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'dashboard_fab',
        onPressed: () => Navigator.pushNamed(context, '/coffeelist'),
        backgroundColor: Colors.brown[800],
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}