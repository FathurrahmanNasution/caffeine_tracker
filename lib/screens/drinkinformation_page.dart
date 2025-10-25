import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:caffeine_tracker/services/drink_service.dart';
import 'package:caffeine_tracker/services/consumption_service.dart';
import 'package:caffeine_tracker/model/consumption_log.dart';
import 'package:caffeine_tracker/model/drink_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DrinkinformationPage extends StatefulWidget {
  const DrinkinformationPage({super.key});

  @override
  State<DrinkinformationPage> createState() => _DrinkinformationPageState();
}

class _DrinkinformationPageState extends State<DrinkinformationPage> {
  final DrinkService _drinkService = DrinkService();
  final ConsumptionService _consumptionService = ConsumptionService();

  DrinkModel? drink;
  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? "";

  int servingSize = 240;
  double caffeineContent = 0;
  bool isCaffeineEdited = false;
  DateTime selectedDateTime = DateTime.now();

  late TextEditingController _servingController;
  late TextEditingController _caffeineController;

  @override
  void initState() {
    super.initState();
    _servingController = TextEditingController();
    _caffeineController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (drink == null) {
      drink = ModalRoute.of(context)!.settings.arguments as DrinkModel?;

      if (drink != null) {
        // Set initial values dari drink
        servingSize = drink!.standardVolume;

        // Hitung caffeine per mL dari drink
        double caffeinePerMl = drink!.caffeineinMg / drink!.standardVolume;
        caffeineContent = caffeinePerMl * servingSize;

        _servingController.text = servingSize.toString();
        _caffeineController.text = caffeineContent.toStringAsFixed(1);
      }
    }
  }

  double _calculateCaffeine(int serving) {
    if (drink == null) return 0;
    double caffeinePerMl = drink!.caffeineinMg / drink!.standardVolume;
    return caffeinePerMl * serving;
  }

  @override
  void dispose() {
    _servingController.dispose();
    _caffeineController.dispose();
    super.dispose();
  }

  void _increment() {
    setState(() {
      servingSize++;
      _servingController.text = servingSize.toString();

      if (!isCaffeineEdited) {
        caffeineContent = _calculateCaffeine(servingSize);
        _caffeineController.text = caffeineContent.toStringAsFixed(1);
      }
    });
  }

  void _decrement() {
    setState(() {
      if (servingSize > 1) {
        servingSize--;
        _servingController.text = servingSize.toString();

        if (!isCaffeineEdited) {
          caffeineContent = _calculateCaffeine(servingSize);
          _caffeineController.text = caffeineContent.toStringAsFixed(1);
        }
      }
    });
  }

  void _onServingChanged(String value) {
    final number = int.tryParse(value.trim());
    if (number != null && number > 0) {
      setState(() {
        servingSize = number;
        if (!isCaffeineEdited) {
          caffeineContent = _calculateCaffeine(servingSize);
          _caffeineController.text = caffeineContent.toStringAsFixed(1);
        }
      });
    }
  }

  void _onCaffeineChanged(String value) {
    final number = double.tryParse(value.trim());
    if (number != null) {
      setState(() {
        caffeineContent = number;
        isCaffeineEdited = true; // tandai kalau user edit manual
      });
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final DateFormat dateFormatter = DateFormat('EEEE, dd MMM yyyy');
    final DateFormat timeFormatter = DateFormat('hh:mm a');
    return '${dateFormatter.format(dateTime)}   ${timeFormatter.format(dateTime)}';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5EBE0),
      body: Column(
        children: [
          // Fixed top navigation bar
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 0,
              right: 0,
              bottom: 8,
            ),
            color: const Color(0xFFD5BBA2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.menu, color: Colors.black),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Image.asset(
                    "assets/images/coffee.png",
                    height: height * 0.06,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: IconButton(
                    onPressed: () {},
                    icon: const CircleAvatar(
                      backgroundImage:
                      AssetImage("assets/images/profile.png"),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header dengan background dan gambar kopi
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Background AppBar
                      Container(
                        height: height * 0.15,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD5BBA2),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(70),
                            bottomRight: Radius.circular(70),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.2),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                      ),

                      // Lingkaran background
                      Positioned(
                        bottom: -height * 0.1,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: height * 0.23,
                          width: height * 0.23,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF5EBE0),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),

                      // Gambar minuman
                      Positioned(
                        bottom: -height * 0.05,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: drink != null
                              ? (drink!.imageUrl.startsWith('http')
                              ? Image.network(drink!.imageUrl, height: height * 0.15, fit: BoxFit.contain)
                              : Image.asset(drink!.imageUrl, height: height * 0.15, fit: BoxFit.contain))
                              : Image.asset("assets/images/coffee.png", height: height * 0.15, fit: BoxFit.contain),
                        ),
                      ),
                    ],
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: height * 0.05),

                        // Nama minuman + favorit
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                drink?.name ?? "Unknown Drink",
                                style: const TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF000000),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                if (drink != null) {
                                  await _drinkService.toggleFavorite(
                                      currentUserId,
                                      drink!.id,
                                      drink!.isFavorite
                                  );
                                  setState(() {
                                    drink!.isFavorite = !drink!.isFavorite;
                                  });
                                }
                              },
                              icon: Icon(
                                drink?.isFavorite ?? false ? Icons.favorite : Icons.favorite_border,
                                color: Colors.red,
                                size: 32,
                              ),
                            ),
                          ],
                        ),

                        const Divider(
                          color: Color(0xFF61412D),
                          thickness: 1.6,
                        ),
                        const SizedBox(height: 7),

                        // Information
                        const Row(
                          children: [
                            Chip(
                              label: Text("Information"),
                              backgroundColor: Color(0xFF4E8D7C),
                              labelStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              shape: StadiumBorder(),
                              elevation: 0,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          drink?.information ?? "No information available",
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 34),

                        // Serving size
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Enter serving size",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF42261D),
                              ),
                            ),
                            Container(
                              width: width * 0.37,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFA67C52),
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: _decrement,
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: _servingController,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      onChanged: _onServingChanged,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                  const Text("mL", style: TextStyle(fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: _increment,
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Caffeine content
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Caffeine Content",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF42261D),
                              ),
                            ),
                            Container(
                              width: width * 0.37,
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 18),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD6CCC2),
                                border: Border.all(
                                  color: const Color(0xFFA67C52),
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.coffee, size: 23),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _caffeineController,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      onChanged: _onCaffeineChanged,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                  const Text("mg", style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // Time taken
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.access_time, size: 18, color: Colors.black),
                                  SizedBox(width: 4),
                                  Text(
                                    "Time taken",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () async {
                                final DateTime? selectedDate = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDateTime,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );

                                if (selectedDate != null) {
                                  final TimeOfDay? selectedTime = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                                  );

                                  if (selectedTime != null) {
                                    setState(() {
                                      selectedDateTime = DateTime(
                                        selectedDate.year,
                                        selectedDate.month,
                                        selectedDate.day,
                                        selectedTime.hour,
                                        selectedTime.minute,
                                      );
                                    });
                                  }
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(255, 255, 255, 0.5),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: const Color(0xFFE8DDD4),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      _formatDateTime(selectedDateTime),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF786656),
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Color(0xFF6E3D2C),
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Save button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFA67C52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onPressed: () async {
                              if (drink != null) {
                                final log = ConsumptionLog(
                                  id: '',
                                  userId: currentUserId,
                                  drinkId: drink!.id,
                                  drinkName: drink!.name,
                                  servingSize: servingSize,
                                  caffeineContent: caffeineContent,
                                  consumedAt: selectedDateTime,
                                );

                                await _consumptionService.addConsumption(log);

                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Consumption saved!')),
                                  );
                                  Navigator.pop(context);
                                }
                              }
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Save",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        selectedItemColor: const Color(0xFF6E3D2C),
        unselectedItemColor: const Color(0xFFA67C52),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_food_beverage_outlined),
            label: "Add Drinks",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: "Logs",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}