import 'package:caffeine_tracker/widgets/consumption_form.dart';
import 'package:flutter/material.dart';
import 'package:caffeine_tracker/services/drink_service.dart';
import 'package:caffeine_tracker/services/consumption_service.dart';
import 'package:caffeine_tracker/model/consumption_log.dart';
import 'package:caffeine_tracker/model/drink_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/app_top_navigation.dart';

class DrinkinformationPage extends StatefulWidget {
  const DrinkinformationPage({super.key});

  @override
  State<DrinkinformationPage> createState() => _DrinkinformationPageState();
}

class _DrinkinformationPageState extends State<DrinkinformationPage> {
  final ConsumptionService _consumptionService = ConsumptionService();
  final DrinkService _drinkService = DrinkService();

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
        servingSize = drink!.standardVolume;
        double caffeinePerMl = drink!.caffeineinMg / drink!.standardVolume;
        caffeineContent = caffeinePerMl * servingSize;

        _servingController.text = servingSize.toString();
        _caffeineController.text = caffeineContent.toStringAsFixed(1);
      }
    }
  }

  @override
  void dispose() {
    _servingController.dispose();
    _caffeineController.dispose();
    super.dispose();
  }

  double _calculateCaffeine(int serving) {
    if (drink == null) return 0;
    double caffeinePerMl = drink!.caffeineinMg / drink!.standardVolume;
    return caffeinePerMl * serving;
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
        isCaffeineEdited = true;
      });
    }
  }

  Future<void> _saveDrink() async {
    if (drink == null) return;

    if (caffeineContent <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Caffeine content must be greater than 0!'),
          backgroundColor: Color(0xFFFF5151),
        ),
      );
      return;
    }

    if (selectedDateTime.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Time cannot be in the future!'),
          backgroundColor: Color(0xFFFF5151),
        ),
      );
      return;
    }

    final log = ConsumptionLog(
      id: '',
      userId: currentUserId,
      drinkId: drink!.id,
      drinkName: drink!.name,
      servingSize: servingSize,
      caffeineContent: caffeineContent,
      consumedAt: selectedDateTime,
    );

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    await _consumptionService.addConsumption(log);

    if (!mounted) return;

    messenger.showSnackBar(
      const SnackBar(content: Text('Consumption saved!')),
    );
    navigator.pop(true);
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5EBE0),
      body: Column(
        children: [
          const AppTopNavigation(showBackButton: true),
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
            child: drink != null
                ? (drink!.imageUrl.startsWith('http')
                    ? Image.network(drink!.imageUrl,
                        height: height * 0.15, fit: BoxFit.contain)
                    : Image.asset(drink!.imageUrl,
                        height: height * 0.15, fit: BoxFit.contain))
                : Image.asset("assets/images/coffee.png",
                    height: height * 0.15, fit: BoxFit.contain),
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
          SizedBox(height: height * 0.05),
          _buildDrinkNameAndFavorite(),
          const Divider(color: Color(0xFF61412D), thickness: 1.6),
          const SizedBox(height: 7),
          _buildInformationSection(),
          const SizedBox(height: 34),
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
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildDrinkNameAndFavorite() {
    return Row(
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
                drink!.isFavorite,
              );
              setState(() {
                drink!.isFavorite = !drink!.isFavorite;
              });
            }
          },
          icon: Icon(
            drink?.isFavorite ?? false
                ? Icons.favorite
                : Icons.favorite_border,
            color: Color(0xFFFF5151),
            size: 32,
          ),
        ),
      ],
    );
  }

  Widget _buildInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFA67C52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
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
    );
  }
}