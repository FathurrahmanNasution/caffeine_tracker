import 'package:caffeine_tracker/widgets/consumption_form.dart';
import 'package:flutter/material.dart';
import 'package:caffeine_tracker/services/consumption_service.dart';
import 'package:caffeine_tracker/model/consumption_log.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/app_top_navigation.dart';

class AddotherdrinkPage extends StatefulWidget {
  const AddotherdrinkPage({super.key});

  @override
  State<AddotherdrinkPage> createState() => _AddotherdrinkPageState();
}

class _AddotherdrinkPageState extends State<AddotherdrinkPage> {
  final ConsumptionService _consumptionService = ConsumptionService();

  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? "";

  int servingSize = 240;
  double caffeineContent = 0;
  bool isCaffeineEdited = false;
  DateTime selectedDateTime = DateTime.now();

  late TextEditingController _servingController;
  late TextEditingController _caffeineController;
  late TextEditingController _drinkNameController;

  @override
  void initState() {
    super.initState();
    caffeineContent = (50 / 200) * servingSize;

    _servingController = TextEditingController(text: "$servingSize");
    _caffeineController =
        TextEditingController(text: caffeineContent.toStringAsFixed(1));
    _drinkNameController = TextEditingController();
  }

  @override
  void dispose() {
    _servingController.dispose();
    _caffeineController.dispose();
    _drinkNameController.dispose();
    super.dispose();
  }

  void _increment() {
    setState(() {
      servingSize++;
      _servingController.text = servingSize.toString();

      if (!isCaffeineEdited) {
        caffeineContent = (50 / 200) * servingSize;
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
          caffeineContent = (50 / 200) * servingSize;
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
          caffeineContent = (50 / 200) * servingSize;
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
        isCaffeineEdited = true;
      });
    }
  }

  Future<void> _selectDateTime() async {
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
  }

  Future<void> _saveDrink() async {
    if (_drinkNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter drink name')),
      );
      return;
    }

    final log = ConsumptionLog(
      id: '',
      userId: currentUserId,
      drinkId: 'other',
      drinkName: _drinkNameController.text.trim(),
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5EBE0),
      body: Column(
        children: [
          const AppTopNavigation(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(height),
                  _buildContent(height),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double height) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
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
        Positioned(
          bottom: -height * 0.05,
          left: 0,
          right: 0,
          child: Center(
            child: Image.asset(
              "assets/images/coffee.png",
              height: height * 0.15,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.local_cafe, size: 80),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(double height) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: height * 0.07),
          const Text(
            "Other Drinks",
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.bold,
              color: Color(0xFF000000),
            ),
          ),
          const Divider(color: Color(0xFF61412D), thickness: 1.6),
          const SizedBox(height: 20),

          // Drink Name Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Drink Name",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF42261D),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 0.7),
                  border: Border.all(
                    color: const Color(0xFFD6CCC2),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _drinkNameController,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter drink name",
                          hintStyle: TextStyle(
                            color: Color(0xFF9E8B7B),
                            fontSize: 16,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.edit,
                      color: Color(0xFFD6CCC2),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Consumption Form Widget
          ConsumptionForm(
            servingSize: servingSize,
            caffeineContent: caffeineContent,
            selectedDateTime: selectedDateTime,
            servingController: _servingController,
            caffeineController: _caffeineController,
            onIncrement: _increment,
            onDecrement: _decrement,
            onServingChanged: _onServingChanged,
            onCaffeineChanged: _onCaffeineChanged,
            onSelectDateTime: _selectDateTime,
          ),
          const SizedBox(height: 30),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA67C52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: _saveDrink,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}