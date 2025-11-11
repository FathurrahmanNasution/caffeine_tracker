import 'package:caffeine_tracker/model/user_model.dart';
import 'package:caffeine_tracker/services/auth_service.dart';
import 'package:caffeine_tracker/widgets/app_bottom_navigation.dart';
import 'package:caffeine_tracker/widgets/app_top_navigation.dart';
import 'package:caffeine_tracker/widgets/consumption_log_card.dart';
import 'package:caffeine_tracker/widgets/caffeine_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});

  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
  final _auth = AuthService();
  UserModel? _userProfile;
  bool _loading = true;

  DateTime selectedDate = DateTime(2026, 8, 15);
  String sortBy = 'Weekly';
  String filterWeek = 'First Week';
  String filterMonth = 'January';
  int filterYear = 2025;

  final List<Map<String, dynamic>> drinks = [
    {
      'name': 'Americano',
      'caffeine': '83mg',
      'size': '240ml',
      'time': '09:25 AM',
      'image': '☕',
    },
    {
      'name': 'Espresso',
      'caffeine': '63mg',
      'size': '30ml (1 shot)',
      'time': '02:00 PM',
      'image': '☕',
    },
    {
      'name': 'Frappuccino',
      'caffeine': '65mg',
      'size': '355ml',
      'time': '',
      'image': '🥤',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
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

  // Data untuk chart berdasarkan sortBy
  Map<dynamic, double> _getChartData() {
    if (sortBy == 'Weekly') {
      // Weekly data (7 days)
      return {
        0: 150.0,
        1: 180.0,
        2: 120.0,
        3: 200.0,
        4: 160.0,
        5: 140.0,
        6: 100.0,
      };
    } else if (sortBy == 'Monthly') {
      // Monthly data (12 months)
      return {
        0: 2500.0,
        1: 2800.0,
        2: 3000.0,
        3: 2700.0,
        4: 3200.0,
        5: 2900.0,
        6: 3100.0,
        7: 2600.0,
        8: 2800.0,
        9: 3000.0,
        10: 2700.0,
        11: 2900.0,
      };
    } else {
      // Yearly data (multiple years)
      return {
        '2023': 30000.0,
        '2024': 35000.0,
        '2025': 32000.0,
        '2026': 28000.0,
      };
    }
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
      return ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    } else if (sortBy == 'Monthly') {
      return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    } else {
      return ['2023', '2024', '2025', '2026'];
    }
  }

  void _handleChartTap(dynamic key) {
    String message = '';
    if (sortBy == 'Weekly') {
      final days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      message = 'Tapped on ${days[key]}';
    } else if (sortBy == 'Monthly') {
      final months = ['January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'];
      message = 'Tapped on ${months[key]}';
    } else {
      message = 'Tapped on year $key';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5EBE0),
      body: Column(
        children: [
          // Top Navigation Bar menggunakan AppTopNavigation widget
          AppTopNavigation(
            userProfile: _userProfile,
          ),
          // Rest of the content
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
                  CaffeineChart(
                    data: _getChartData(),
                    type: _getChartType(),
                    labels: _getChartLabels(),
                    onTap: _handleChartTap,
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 2),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: drinks
            .asMap()
            .entries
            .map((entry) => ConsumptionLogCard(
          name: entry.value['name'],
          caffeine: entry.value['caffeine'],
          size: entry.value['size'],
          time: entry.value['time'],
          image: entry.value['image'],
          onTap: () => Navigator.pushNamed(context, '/drinkinformation'),
          onDelete: () => _showDeleteDialog(entry.key),
        ))
            .toList(),
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
                    ['First Week', 'Second Week', 'Third Week', 'Fourth Week'],
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