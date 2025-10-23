import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});

  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5EBE0),
      body: Column(
        children: [
          // Top Navigation Bar
          Container(
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
                    onTap: () {},
                    child: Image.asset(
                      "assets/images/coffee.png",
                      height: height * 0.06,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.local_cafe, size: 40);
                      },
                    ),
                  ),
                ),
                Row(
                  children: [
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/profile'),
                      child: const CircleAvatar(
                        backgroundColor: Color(0xFF6E3D2C),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
                  _buildChart(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 2,
        selectedItemColor: const Color(0xFF6E3D2C),
        unselectedItemColor: const Color(0xFFA67C52),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/dashboard');
              break;
            case 1:
              Navigator.pushNamed(context, '/coffeelist');
              break;
            case 2:
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
            label: "Drinks",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: "Logs",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: drinks
            .asMap()
            .entries
            .map((entry) => _buildDrinkCard(entry.value, entry.key))
            .toList(),
      ),
    );
  }

  Widget _buildDrinkCard(Map<String, dynamic> drink, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFD5BBA2),
        border: Border.all(color: const Color(0xFFA67C52), width: 1.0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.pushNamed(context, '/drinkinformation');
          },
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.brown[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      drink['image'],
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        drink['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '${drink['caffeine']} • ${drink['size']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF42261D),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (drink['time'].isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6E3D2C),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            drink['time'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -5), // Raise X button by 5 pixels
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.black54,
                      size: 18,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    onPressed: () {
                      _showDeleteDialog(index);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
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
                _buildDropdown(sortBy, ['Weekly', 'Monthly', 'Yearly'], (
                  value,
                ) {
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
        // Wrap DropdownButton with Center
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

  Widget _buildChart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 200,
        child: CustomPaint(painter: CaffeineChartPainter(), child: Container()),
      ),
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

  void _deleteDrink(int index) {
    setState(() {
      drinks.removeAt(index);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Drink deleted successfully')));
  }
}

class CaffeineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8B6F47)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = const Color(0xFFD5BBA2).withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 0.5;

    // Draw horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      double y = size.height - (i * size.height / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Define the chart points
    final path = Path();
    final points = [
      Offset(0, size.height * 0.6),
      Offset(size.width * 0.14, size.height * 0.55),
      Offset(size.width * 0.28, size.height * 0.5),
      Offset(size.width * 0.42, size.height * 0.45),
      Offset(size.width * 0.56, size.height * 0.4),
      Offset(size.width * 0.70, size.height * 0.5),
      Offset(size.width * 0.84, size.height * 0.35),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    // Fill under the line
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw label
    final labelBg = Paint()
      ..color = const Color(0xFF8B6F47)
      ..style = PaintingStyle.fill;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.25, size.height * 0.35, 100, 25),
      const Radius.circular(8),
    );
    canvas.drawRRect(rect, labelBg);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Americano 85mg',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(size.width * 0.25 + 8, size.height * 0.35 + 5),
    );

    // Y-axis labels
    final yLabels = ['0', '50', '100', '150', '200'];
    for (int i = 0; i < yLabels.length; i++) {
      final labelPainter = TextPainter(
        text: TextSpan(
          text: yLabels[i],
          style: const TextStyle(color: Colors.black54, fontSize: 10),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      labelPainter.layout();
      labelPainter.paint(
        canvas,
        Offset(0, size.height - (i * size.height / 4) - 5),
      );
    }

    // X-axis labels
    final xLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    for (int i = 0; i < xLabels.length; i++) {
      final labelPainter = TextPainter(
        text: TextSpan(
          text: xLabels[i],
          style: const TextStyle(color: Colors.black54, fontSize: 10),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      labelPainter.layout();
      labelPainter.paint(
        canvas,
        Offset((i * size.width / 6) + 10, size.height + 10),
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
