import 'package:caffeine_tracker/model/user_model.dart';
import 'package:caffeine_tracker/model/consumption_log.dart';
import 'package:caffeine_tracker/services/auth_service.dart';
import 'package:caffeine_tracker/widgets/app_bottom_navigation.dart';
import 'package:caffeine_tracker/widgets/app_top_navigation.dart';
import 'package:caffeine_tracker/widgets/consumption_log_card.dart';
import 'package:caffeine_tracker/widgets/caffeine_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});

  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
  final _auth = AuthService();
  final _firestore = FirebaseFirestore.instance;
  UserModel? _userProfile;
  bool _loading = true;
  List<ConsumptionLog> _consumptions = [];

  DateTime selectedDate = DateTime.now();
  String sortBy = 'Weekly';
  String filterWeek = 'First Week';
  String filterMonth = 'January';
  int filterYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadConsumptions();
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

  Future<void> _loadConsumptions() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('consumptions')
          .where('userId', isEqualTo: user.uid)
          .orderBy('consumedAt', descending: true)
          .get();

      if (mounted) {
        setState(() {
          _consumptions = snapshot.docs
              .map((doc) => ConsumptionLog.fromMap(doc.data(), doc.id))
              .toList();
        });
      }
    } catch (e) {
      print('Error loading consumptions: $e');
    }
  }

  List<ConsumptionLog> _getConsumptionsForDate(DateTime date) {
    return _consumptions.where((log) {
      return log.consumedAt.year == date.year &&
          log.consumedAt.month == date.month &&
          log.consumedAt.day == date.day;
    }).toList();
  }

  // Data untuk chart berdasarkan sortBy
  Map<dynamic, double> _getChartData() {
    if (sortBy == 'Weekly') {
      return _getWeeklyData();
    } else if (sortBy == 'Monthly') {
      return _getMonthlyData();
    } else {
      return _getYearlyData();
    }
  }

  Map<int, double> _getWeeklyData() {
    final now = DateTime.now();
    final currentDay = now.day;

    int weekStart = _getWeekStart(filterWeek);
    int weekEnd = _getWeekEnd(filterWeek, filterYear, _getMonthNumber(filterMonth));

    Map<int, double> weeklyData = {};

    // Initialize all days in the week
    for (int i = weekStart; i <= weekEnd; i++) {
      weeklyData[i] = 0;
    }

    // Calculate actual data from consumptions
    for (var consumption in _consumptions) {
      final consumedDate = consumption.consumedAt;
      if (consumedDate.year == filterYear &&
          consumedDate.month == _getMonthNumber(filterMonth) &&
          consumedDate.day >= weekStart &&
          consumedDate.day <= weekEnd &&
          consumedDate.day < currentDay) {
        weeklyData[consumedDate.day] =
            (weeklyData[consumedDate.day] ?? 0) + consumption.caffeineContent;
      }
    }

    return weeklyData;
  }

  Map<int, double> _getMonthlyData() {
    final now = DateTime.now();
    final currentDay = now.day;
    final monthNumber = _getMonthNumber(filterMonth);
    final daysInMonth = DateTime(filterYear, monthNumber + 1, 0).day;

    Map<int, double> monthlyData = {};

    List<Map<String, dynamic>> weeks = [
      {'week': 1, 'start': 1, 'end': 7},
      {'week': 2, 'start': 8, 'end': 14},
      {'week': 3, 'start': 15, 'end': 21},
      {'week': 4, 'start': 22, 'end': 28},
      if (daysInMonth > 28) {'week': 5, 'start': 29, 'end': daysInMonth},
    ];

    // Initialize all weeks
    for (var week in weeks) {
      monthlyData[week['week']] = 0;
    }

    // Calculate actual data from consumptions
    for (var consumption in _consumptions) {
      final consumedDate = consumption.consumedAt;
      if (consumedDate.year == filterYear &&
          consumedDate.month == monthNumber) {

        for (var week in weeks) {
          int weekStart = week['start'];
          int weekEnd = week['end'];

          if (consumedDate.day >= weekStart &&
              consumedDate.day <= weekEnd &&
              weekEnd < currentDay) {
            monthlyData[week['week']] =
                (monthlyData[week['week']] ?? 0) + consumption.caffeineContent;
            break;
          }
        }
      }
    }

    return monthlyData;
  }

  Map<int, double> _getYearlyData() {
    final now = DateTime.now();
    final currentMonth = now.month;

    Map<int, double> yearlyData = {};

    // Initialize all 12 months
    for (int i = 1; i <= 12; i++) {
      yearlyData[i] = 0;
    }

    // Calculate actual data from consumptions
    for (var consumption in _consumptions) {
      final consumedDate = consumption.consumedAt;
      if (consumedDate.year == filterYear && consumedDate.month < currentMonth) {
        yearlyData[consumedDate.month] =
            (yearlyData[consumedDate.month] ?? 0) + consumption.caffeineContent;
      }
    }

    return yearlyData;
  }

  int _getWeekStart(String week) {
    switch (week) {
      case 'First Week': return 1;
      case 'Second Week': return 8;
      case 'Third Week': return 15;
      case 'Fourth Week': return 22;
      case 'Fifth Week': return 29;
      default: return 1;
    }
  }

  int _getWeekEnd(String week, int year, int month) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    switch (week) {
      case 'First Week': return 7;
      case 'Second Week': return 14;
      case 'Third Week': return 21;
      case 'Fourth Week': return 28;
      case 'Fifth Week': return daysInMonth;
      default: return 7;
    }
  }

  int _getMonthNumber(String monthName) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];
    return months.indexOf(monthName) + 1;
  }

  ChartType _getChartType() {
    if (sortBy == 'Weekly') {
      return ChartType.weekly;
    } else if (sortBy == 'Monthly') {
      return ChartType.monthly;
    } else {
      return ChartType.yearly;
    }
  }

  List<String> _getChartLabels() {
    if (sortBy == 'Weekly') {
      return _getWeeklyLabels();
    } else if (sortBy == 'Monthly') {
      return _getMonthlyLabels();
    } else {
      return ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
    }
  }

  List<String> _getWeeklyLabels() {
    int weekStart = _getWeekStart(filterWeek);
    int weekEnd = _getWeekEnd(filterWeek, filterYear, _getMonthNumber(filterMonth));

    List<String> labels = [];
    for (int i = weekStart; i <= weekEnd; i++) {
      labels.add('$i');
    }
    return labels;
  }

  List<String> _getMonthlyLabels() {
    final monthNumber = _getMonthNumber(filterMonth);
    final daysInMonth = DateTime(filterYear, monthNumber + 1, 0).day;

    List<String> labels = ['Week-1', 'Week-2', 'Week-3', 'Week-4'];
    if (daysInMonth > 28) {
      labels.add('Week-5');
    }
    return labels;
  }

  bool _hasDataToShow() {
    final data = _getChartData();
    return data.values.any((value) => value > 0);
  }

  void _handleChartTap(dynamic key) {
    _showDetailsDialog(key);
  }

  void _showDetailsDialog(dynamic key) {
    String title;
    double totalCaffeine;
    String description;
    List<Map<String, dynamic>>? drinksList;

    if (sortBy == 'Weekly') {
      // Weekly: show list of drinks for specific day
      title = 'Day $key';

      // Get consumptions for that specific day
      final targetDate = DateTime(
        filterYear,
        _getMonthNumber(filterMonth),
        key as int,
      );

      final dayConsumptions = _consumptions.where((log) {
        return log.consumedAt.year == targetDate.year &&
            log.consumedAt.month == targetDate.month &&
            log.consumedAt.day == targetDate.day;
      }).toList();

      if (dayConsumptions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No drinks at that day'),
              duration: Duration(seconds: 1)
          ),
        );
        return;
      }

      drinksList = dayConsumptions.map((log) => {
        'name': log.drinkName,
        'caffeine': log.caffeineContent,
        'size': log.servingSize,
      }).toList();

      totalCaffeine = dayConsumptions.fold<double>(
          0.0,
              (sum, log) => sum + log.caffeineContent
      );
      description = '';

    } else if (sortBy == 'Monthly') {
      // Monthly: show week summary
      final weekNames = ['First Week', 'Second Week', 'Third Week', 'Fourth Week', 'Fifth Week'];
      title = weekNames[key - 1];

      // Calculate total for that week
      final monthNumber = _getMonthNumber(filterMonth);
      final weekStart = _getWeekStart(weekNames[key - 1]);
      final weekEnd = _getWeekEnd(weekNames[key - 1], filterYear, monthNumber);

      totalCaffeine = _consumptions.where((log) {
        return log.consumedAt.year == filterYear &&
            log.consumedAt.month == monthNumber &&
            log.consumedAt.day >= weekStart &&
            log.consumedAt.day <= weekEnd;
      }).fold<double>(0.0, (sum, log) => sum + log.caffeineContent);

      description = 'Total caffeine consumed during $title';

    } else {
      // Yearly: show month summary
      final months = ['January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'];
      title = '${months[key - 1]} $filterYear';

      totalCaffeine = _consumptions.where((log) {
        return log.consumedAt.year == filterYear &&
            log.consumedAt.month == key;
      }).fold<double>(0.0, (sum, log) => sum + log.caffeineContent);

      description = 'Total caffeine consumed during ${months[key - 1]} $filterYear';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF6E3D2C),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFFFFF),
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD5BBA2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${totalCaffeine.toStringAsFixed(1)}mg',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF6E3D2C),
                  ),
                ),
              ),
            ],
          ),
          content: drinksList != null
              ? SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: drinksList.length,
              itemBuilder: (context, index) {
                final d = drinksList![index];
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
                              d['name'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              '${(d['caffeine'] as double).toStringAsFixed(1)}mg ~ ${d['size']}ml',
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
          )
              : Text(
            description,
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  List<DateTime> _generateMonthDates() {
    final year = selectedDate.year;
    final month = selectedDate.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;

    return List.generate(
      daysInMonth,
          (index) => DateTime(year, month, index + 1),
    );
  }

  List<DateTime> _getVisibleDates() {
    final monthDates = _generateMonthDates();
    final currentIndex = selectedDate.day - 1;

    // Show 5 dates at a time
    final startIndex = (currentIndex ~/ 5) * 5;
    final endIndex = (startIndex + 5).clamp(0, monthDates.length);

    return monthDates.sublist(startIndex, endIndex);
  }

  void _navigateToPreviousDates() {
    setState(() {
      final currentDay = selectedDate.day;

      if (currentDay <= 5) {
        // Go to previous month
        final prevMonth = DateTime(
          selectedDate.year,
          selectedDate.month - 1,
          1,
        );
        final daysInPrevMonth = DateTime(
          prevMonth.year,
          prevMonth.month + 1,
          0,
        ).day;

        // Calculate which "page" to show in previous month
        final lastPageStart = ((daysInPrevMonth - 1) ~/ 5) * 5 + 1;
        selectedDate = DateTime(prevMonth.year, prevMonth.month, lastPageStart);
      } else {
        // Go to previous 5 dates in current month
        final newDay = ((currentDay - 6) ~/ 5) * 5 + 1;
        selectedDate = DateTime(selectedDate.year, selectedDate.month, newDay);
      }
    });
  }

  void _navigateToNextDates() {
    setState(() {
      final monthDates = _generateMonthDates();
      final currentDay = selectedDate.day;
      final currentPageStart = ((currentDay - 1) ~/ 5) * 5 + 1;
      final nextPageStart = currentPageStart + 5;

      if (nextPageStart > monthDates.length) {
        // Go to next month
        selectedDate = DateTime(selectedDate.year, selectedDate.month + 1, 1);
      } else {
        // Go to next 5 dates in current month
        selectedDate = DateTime(
          selectedDate.year,
          selectedDate.month,
          nextPageStart,
        );
      }
    });
  }

  void _showMonthYearPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int tempYear = selectedDate.year;
        int tempMonth = selectedDate.month;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFF5EBE0),
              title: const Text(
                'Select Month and Year',
                style: TextStyle(color: Color(0xFF4B2C20)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<int>(
                    value: tempMonth,
                    dropdownColor: const Color(0xFFD5BBA2),
                    isExpanded: true,
                    items: List.generate(12, (index) {
                      return DropdownMenuItem(
                        value: index + 1,
                        child: Text(
                          DateFormat.MMMM().format(DateTime(2000, index + 1)),
                          style: const TextStyle(color: Color(0xFF4B2C20)),
                        ),
                      );
                    }),
                    onChanged: (value) {
                      setDialogState(() {
                        tempMonth = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButton<int>(
                    value: tempYear,
                    dropdownColor: const Color(0xFFD5BBA2),
                    isExpanded: true,
                    items: List.generate(10, (index) {
                      final year = DateTime.now().year - 5 + index;
                      return DropdownMenuItem(
                        value: year,
                        child: Text(
                          year.toString(),
                          style: const TextStyle(color: Color(0xFF4B2C20)),
                        ),
                      );
                    }),
                    onChanged: (value) {
                      setDialogState(() {
                        tempYear = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF6E3D2C)),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedDate = DateTime(tempYear, tempMonth, 1);
                    });
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Color(0xFF6E3D2C)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteConsumption(String consumptionId) async {
    try {
      await _firestore.collection('consumptions').doc(consumptionId).delete();
      await _loadConsumptions(); // Reload data
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Drink deleted successfully'))
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting drink: $e'))
        );
      }
    }
  }

  void _showDeleteDialog(String consumptionId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF5EBE0),
          title: const Text(
            'Delete Drink',
            style: TextStyle(color: Color(0xFF4B2C20)),
          ),
          content: const Text(
            'Are you sure you want to delete this drink?',
            style: TextStyle(color: Color(0xFF6E3D2C)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF6E3D2C)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteConsumption(consumptionId);
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5EBE0),
      body: Column(
        children: [
          AppTopNavigation(
            userProfile: _userProfile,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCalendarSection(),
                  const SizedBox(height: 20),
                  _buildDrinksList(),
                  const SizedBox(height: 20),
                  _buildSortBySection(),
                  const SizedBox(height: 10),
                  if (_hasDataToShow())
                    CaffeineChart(
                      data: _getChartData(),
                      type: _getChartType(),
                      labels: _getChartLabels(),
                      onTap: _handleChartTap,
                    )
                  else
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD5BBA2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Not enough data to load ${sortBy.toLowerCase()} chart',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6E3D2C),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    final visibleDates = _getVisibleDates();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _showMonthYearPicker,
                child: Row(
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(selectedDate),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4B2C20),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_drop_down, color: Color(0xFF6E3D2C)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 70,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.chevron_left,
                    color: Color(0xFF6E3D2C),
                    size: 20,
                  ),
                  onPressed: _navigateToPreviousDates,
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: visibleDates.length,
                    itemBuilder: (context, index) {
                      final date = visibleDates[index];
                      final isSelected =
                          date.day == selectedDate.day &&
                              date.month == selectedDate.month &&
                              date.year == selectedDate.year;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDate = date;
                          });
                        },
                        child: Container(
                          width: 50,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            children: [
                              Text(
                                DateFormat('E').format(date).substring(0, 3),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? const Color(0xFF6E3D2C)
                                      : Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF52796F)
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF6E3D2C),
                    size: 20,
                  ),
                  onPressed: _navigateToNextDates,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrinksList() {
    final todayConsumptions = _getConsumptionsForDate(selectedDate);

    if (todayConsumptions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFD5BBA2).withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'No drinks logged for this day',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6E3D2C),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: todayConsumptions.map((log) {
          return ConsumptionLogCard(
            name: log.drinkName,
            caffeine: '${log.caffeineContent.toStringAsFixed(0)}mg',
            size: '${log.servingSize}ml',
            time: DateFormat('hh:mm a').format(log.consumedAt),
            image: '☕', // Default icon, bisa disesuaikan
            onTap: () => Navigator.pushNamed(context, '/drinkinformation'),
            onDelete: () => _showDeleteDialog(log.id),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSortBySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sort by',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4B2C20),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildDropdown(sortBy, ['Weekly', 'Monthly', 'Yearly'], (value) {
                  setState(() {
                    sortBy = value!;
                  });
                }),
                const SizedBox(width: 8),
                if (sortBy == 'Weekly') ...[
                  _buildDropdown(
                    filterWeek,
                    ['First Week', 'Second Week', 'Third Week', 'Fourth Week', 'Fifth Week'],
                        (value) {
                      setState(() => filterWeek = value!);
                    },
                  ),
                  const SizedBox(width: 8),
                ],
                if (sortBy != 'Yearly') ...[
                  _buildDropdown(
                    filterMonth,
                    [
                      'January',
                      'February',
                      'March',
                      'April',
                      'May',
                      'June',
                      'July',
                      'August',
                      'September',
                      'October',
                      'November',
                      'December',
                    ],
                        (value) {
                      setState(() => filterMonth = value!);
                    },
                  ),
                  const SizedBox(width: 8),
                ],
                _buildDropdown(
                  '$filterYear',
                  ['2023', '2024', '2025', '2026'],
                      (value) {
                    setState(() => filterYear = int.parse(value!));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
      String value,
      List<String> items,
      Function(String?)? onChanged,
      ) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF6E3D2C),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF6E3D2C),
          underline: const SizedBox(),
          isDense: true,
          icon: const Icon(
            Icons.arrow_drop_down,
            color: Colors.white,
            size: 20,
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          alignment: Alignment.center,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              alignment: Alignment.center,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}