import 'package:caffeine_tracker/model/user_model.dart';
import 'package:caffeine_tracker/model/consumption_log.dart';
import 'package:caffeine_tracker/services/consumption_service.dart';
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

  // Data untuk chart (Sunday - Saturday)
  Map<int, double> weeklyData = {
    0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0,
  };

  // Data detail drinks per hari
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

  void _showDrinkDetails(BuildContext context, int dayIndex) {
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Drink deleted successfully')));
  }

  Future<void> _handleSignOut() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/landing');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;

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
                      child: CircleAvatar(
                        backgroundImage: _userProfile?.photoUrl != null
                            ? NetworkImage(_userProfile!.photoUrl!)
                            : null,
                        child: _userProfile?.photoUrl == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreeting(),
                  const SizedBox(height: 12),
                  _buildTitle(),
                  const SizedBox(height: 10),
                  _buildCaffeineInfo(),
                  const SizedBox(height: 30),
                  _buildChart(),
                  const SizedBox(height: 40),
                  _buildDrinksSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        selectedItemColor: const Color(0xFF6E3D2C),
        unselectedItemColor: const Color(0xFFA67C52),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: (int index) {
          switch (index) {
            case 0:
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
            label: "Drinks",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: "Logs",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/coffeelist');
        },
        backgroundColor: Colors.brown[800],
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildGreeting() {
    final displayName =
        _userProfile?.displayName ?? _userProfile?.username ?? 'User';

    return Row(
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
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Track your\nCaffeine Journey',
      style: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        height: 1.2,
        fontFamily: 'Oswald',
      ),
    );
  }

  Widget _buildCaffeineInfo() {
    return const Text(
      'Today Caffeine in Take: 158mg',
      style: TextStyle(
        fontSize: 17,
        color: Color(0xff6e3d2c),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildChart() {
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 6),
      child: SizedBox(
        height: 200,
        child: GestureDetector(
          onTapDown: (details) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final localPosition = details.localPosition;

            // Hitung tap position relatif terhadap chart
            const double labelOffset = 25.0;
            const double spacingDivisor = 7;
            const double chartPadding = 30.0; // Left padding dari parent

            final chartWidth = box.size.width - chartPadding - 6; // Minus padding

            // Tentukan hari mana yang di-tap
            for (int i = 0; i < 7; i++) {
              double pointX = (i * chartWidth / spacingDivisor) + labelOffset + chartPadding;

              // Area tap: ±20 pixels dari titik
              if ((localPosition.dx - pointX).abs() < 20) {
                _showDrinkDetails(context, i);
                break;
              }
            }
          },
          child: CustomPaint(
            painter: CaffeineChartPainter(weeklyData: weeklyData),
            child: Container(),
          ),
        ),
      ),
    );
  }

  Widget _buildDrinksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        ...drinks.asMap().entries.map((entry) {
          int index = entry.key;
          Drink drink = entry.value;
          return _buildDrinkCard(drink, index);
        }).toList(),
      ],
    );
  }

  Widget _buildDrinkCard(Drink drink, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/drinkinformation');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xffd5bba2),
          border: Border.all(
            color: const Color(0xffa67c52),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.brown[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(drink.image, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        drink.name,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${drink.caffeine} • ${drink.size}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xff42261d),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (drink.time.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xff6e3d2c),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        drink.time,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                _showDeleteDialog(index);
              },
              child: Transform.translate(
                offset: const Offset(5, -30.0),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.close,
                    color: Colors.black54,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
}

class CaffeineChartPainter extends CustomPainter {
  final Map<int, double> weeklyData;

  CaffeineChartPainter({required this.weeklyData});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown[300]!
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.brown[300]!.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 0.7;

    final pointPaint = Paint()
      ..color = Colors.brown[800]!
      ..style = PaintingStyle.fill;

    // Draw grid lines
    for (int i = 0; i <= 5; i++) {
      double y = size.height - (i * size.height / 5);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    const double labelOffset = 25.0;
    const double spacingDivisor = 7;

    // Find max value untuk scaling
    double maxCaffeine = 250;
    final maxFromData = weeklyData.values.fold(0.0, (max, val) => val > max ? val : max);
    if (maxFromData > maxCaffeine) {
      maxCaffeine = ((maxFromData / 50).ceil() * 50).toDouble();
    }

    // Generate points from weekly data
    final path = Path();
    final List<Offset> points = [];

    for (int i = 0; i < 7; i++) {
      double caffeine = weeklyData[i] ?? 0;
      double normalizedValue = maxCaffeine > 0 ? caffeine / maxCaffeine : 0;
      double y = size.height - (normalizedValue * size.height);
      double x = (i * size.width / spacingDivisor) + labelOffset;
      points.add(Offset(x, y));
    }

    // Draw path
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }

      // Fill area
      final fillPath = Path.from(path);
      fillPath.lineTo(size.width, size.height);
      fillPath.lineTo(0, size.height);
      fillPath.close();
      canvas.drawPath(fillPath, fillPaint);
      canvas.drawPath(path, paint);

      // Draw points (circles) on each data point
      for (var point in points) {
        canvas.drawCircle(point, 5, pointPaint);
      }
    }

    // Draw Y-axis labels
    final yLabels = ['0', '50', '100', '150', '200', '250'];
    for (int i = 0; i < yLabels.length; i++) {
      final labelPainter = TextPainter(
        text: TextSpan(
          text: yLabels[i],
          style: const TextStyle(color: Colors.black54, fontSize: 13),
        ),
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout();
      labelPainter.paint(
        canvas,
        Offset(-30, size.height - (i * size.height / 5) - 5),
      );
    }

    // Draw X-axis labels
    final xLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    for (int i = 0; i < xLabels.length; i++) {
      final labelPainter = TextPainter(
        text: TextSpan(
          text: xLabels[i],
          style: const TextStyle(color: Colors.black54, fontSize: 14),
        ),
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout();
      labelPainter.paint(
        canvas,
        Offset((i * size.width / 7) + 20, size.height + 10),
      );
    }
  }

  @override
  bool shouldRepaint(CaffeineChartPainter oldDelegate) {
    return oldDelegate.weeklyData != weeklyData;
  }
}