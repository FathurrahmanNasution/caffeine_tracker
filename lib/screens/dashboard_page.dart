import 'package:caffeine_tracker/model/user_model.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

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
  UserModel? _userProfile;
  bool _loading = true;

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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreeting(),
                  const SizedBox(height: 20),
                  _buildTitle(),
                  const SizedBox(height: 10),
                  _buildCaffeineInfo(),
                  const SizedBox(height: 30),
                  _buildChart(),
                  const SizedBox(height: 30),
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
                fontSize: 16,
                color: const Color(0xff42261d),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              displayName,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.transparent, // or any background color you want
            border: Border.all(
              color: const Color(0xff42261d), // border color
              width: 2, // adjust border thickness
            ),
            borderRadius: BorderRadius.circular(15),
          ),

          child: Text(
            'Oct 17th, 2025',
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xff5b3020),
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
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        height: 1.2,
      ),
    );
  }

  Widget _buildCaffeineInfo() {
    return const Text(
      'Today Caffeine in Take: 158mg',
      style: TextStyle(
        fontSize: 14,
        color: Color(0xff6e3d2c),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildChart() {
    return SizedBox(
      height: 200,
      child: CustomPaint(painter: CaffeineChartPainter(), child: Container()),
    );
  }

  Widget _buildDrinksSection() {
    final caffeineLeft = '30 mg';
    final caffeineColor = const Color(0xffd6ccc2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Drinks of the day',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xff4b2c20),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 47),
            decoration: BoxDecoration(
              color: const Color(0xFF52796F), // background color
              borderRadius: BorderRadius.circular(12),
            ),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 16, // increased font size
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                children: [
                  const TextSpan(text: 'You still need '),
                  TextSpan(
                    text: '30 mg ',
                    style: TextStyle(
                      color: const Color(0xFFD6CCC2), // highlighted color
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: 'of caffeine today!'),
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
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xffd5bba2),
          border: Border.all(
            color: const Color(0xffa67c52), // border color
            width: 1.0, // adjust border thickness
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
                child: Text(drink.image, style: const TextStyle(fontSize: 24)),
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
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${drink.caffeine} • ${drink.size}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: const Color(0xff42261d),
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
                          fontSize: 10,
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
                offset: const Offset(
                  0,
                  -20.0,
                ), // move 6 pixels up (increase for higher)
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
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown[300]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.brown[300]!.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 5; i++) {
      double y = size.height - (i * size.height / 5);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final path = Path();
    final points = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.2, size.height * 0.6),
      Offset(size.width * 0.4, size.height * 0.4),
      Offset(size.width * 0.6, size.height * 0.5),
      Offset(size.width * 0.8, size.height * 0.3),
      Offset(size.width, size.height * 0.35),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Americano 35mg',
        style: TextStyle(
          color: Colors.brown[800],
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width * 0.3, size.height * 0.25));

    final yLabels = ['0', '50', '100', '150', '200'];
    for (int i = 0; i < yLabels.length; i++) {
      final labelPainter = TextPainter(
        text: TextSpan(
          text: yLabels[i],
          style: const TextStyle(color: Colors.black54, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout();
      labelPainter.paint(
        canvas,
        Offset(-30, size.height - (i * size.height / 4) - 5),
      );
    }

    final xLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    for (int i = 0; i < xLabels.length; i++) {
      final labelPainter = TextPainter(
        text: TextSpan(
          text: xLabels[i],
          style: const TextStyle(color: Colors.black54, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout();
      labelPainter.paint(
        canvas,
        Offset((i * size.width / 6) + 5, size.height + 10),
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
