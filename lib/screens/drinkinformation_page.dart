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

  // Can receive either DrinkModel (add mode) or ConsumptionLog (edit mode)
  DrinkModel? drink;
  ConsumptionLog? consumptionLog;
  bool isEditMode = false;
  bool isLoadingDrink = false;

  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? "";

  double servingSize = 240;
  double caffeineContent = 0;
  bool isCaffeineManuallyEdited = false; // Changed name for clarity
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

    if (drink == null && consumptionLog == null) {
      final args = ModalRoute.of(context)!.settings.arguments;

      // Check if it's edit mode (ConsumptionLog passed)
      if (args is ConsumptionLog) {
        consumptionLog = args;
        isEditMode = true;

        servingSize = consumptionLog!.servingSize.toDouble();
        caffeineContent = consumptionLog!.caffeineContent;
        selectedDateTime = consumptionLog!.consumedAt;
        // Don't set isCaffeineManuallyEdited to true - let it auto-calculate

        _servingController.text = servingSize.toInt().toString();
        _caffeineController.text = caffeineContent.toStringAsFixed(1);

        // Load drink details for image and calculation
        _loadDrinkDetails(consumptionLog!.drinkId);
      }
      // Add mode (DrinkModel passed)
      else if (args is DrinkModel) {
        drink = args;
        isEditMode = false;

        servingSize = drink!.standardVolume.toDouble();
        double caffeinePerMl = drink!.caffeineinMg / drink!.standardVolume;
        caffeineContent = caffeinePerMl * servingSize;

        _servingController.text = servingSize.toInt().toString();
        _caffeineController.text = caffeineContent.toStringAsFixed(1);
      }
    }
  }

  Future<void> _loadDrinkDetails(String drinkId) async {
    setState(() {
      isLoadingDrink = true;
    });

    try {
      final loadedDrink = await _drinkService.getDrinkById(drinkId);
      if (mounted) {
        setState(() {
          drink = loadedDrink;
          isLoadingDrink = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingDrink = false;
        });
      }
      print('Error loading drink details: $e');
    }
  }

  @override
  void dispose() {
    _servingController.dispose();
    _caffeineController.dispose();
    super.dispose();
  }

  double _calculateCaffeine(double serving) {
    if (drink == null) return 0;
    double caffeinePerMl = drink!.caffeineinMg / drink!.standardVolume;
    return caffeinePerMl * serving;
  }

  void _increment() {
    setState(() {
      servingSize += 50;
      _servingController.text = servingSize.toInt().toString();

      // Auto-calculate caffeine if not manually edited
      if (!isCaffeineManuallyEdited) {
        caffeineContent = _calculateCaffeine(servingSize);
        _caffeineController.text = caffeineContent.toStringAsFixed(1);
      }
    });
  }

  void _decrement() {
    setState(() {
      if (servingSize >= 50) {
        servingSize -= 50;
        _servingController.text = servingSize.toInt().toString();

        // Auto-calculate caffeine if not manually edited
        if (!isCaffeineManuallyEdited) {
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
        servingSize = number.toDouble();
        
        // Auto-calculate caffeine if not manually edited
        if (!isCaffeineManuallyEdited) {
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
        // Mark as manually edited so it won't auto-calculate anymore
        isCaffeineManuallyEdited = true;
      });
    }
  }

  Future<void> _selectDateTime() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6E3D2C),
              onPrimary: Colors.white,
              onSurface: Color(0xFF42261D),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      final TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF6E3D2C),
                onPrimary: Colors.white,
                onSurface: Color(0xFF42261D),
              ),
            ),
            child: child!,
          );
        },
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

  Future<void> _handleSave() async {
    // Validation
    if (servingSize <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Serving size must be greater than 0!'),
          backgroundColor: Color(0xFFFF5151),
        ),
      );
      return;
    }

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

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      if (isEditMode && consumptionLog != null) {
        // Update existing consumption
        final updatedLog = ConsumptionLog(
          id: consumptionLog!.id,
          userId: currentUserId,
          drinkId: consumptionLog!.drinkId,
          drinkName: consumptionLog!.drinkName,
          servingSize: servingSize.toInt(),
          caffeineContent: caffeineContent,
          consumedAt: selectedDateTime,
        );

        await _consumptionService.updateConsumption(consumptionLog!.id, updatedLog);

        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Consumption updated successfully!'),
            backgroundColor: Color(0xFF6E3D2C),
          ),
        );
      } else if (drink != null) {
        // Add new consumption
        final log = ConsumptionLog(
          id: '',
          userId: currentUserId,
          drinkId: drink!.id,
          drinkName: drink!.name,
          servingSize: servingSize.toInt(),
          caffeineContent: caffeineContent,
          consumedAt: selectedDateTime,
        );

        await _consumptionService.addConsumption(log);

        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Consumption saved!'),
            backgroundColor: Color(0xFF6E3D2C),
          ),
        );
      }

      navigator.pop(true);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: const Color(0xFFFF5151),
        ),
      );
    }
  }

  Future<void> _handleDelete() async {
    if (consumptionLog == null || !isEditMode) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF5EBE0),
          title: const Text(
            'Delete Consumption',
            style: TextStyle(
              color: Color(0xFF42261D),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete this consumption log?',
            style: TextStyle(color: Color(0xFF42261D)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF6E3D2C)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Color(0xFFFF5151),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      if (!mounted) return;
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);

      await _consumptionService.deleteConsumption(consumptionLog!.id);

      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Consumption deleted successfully'),
          backgroundColor: Color(0xFF6E3D2C),
        ),
      );
      navigator.pop(true);
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
            child: isLoadingDrink
                ? const CircularProgressIndicator(color: Color(0xFF6E3D2C))
                : _buildDrinkImage(height),
          ),
        ),
      ],
    );
  }

  Widget _buildDrinkImage(double height) {
    if (drink != null && drink!.imageUrl.isNotEmpty) {
      return drink!.imageUrl.startsWith('http')
          ? ClipOval(
              child: Image.network(
                drink!.imageUrl,
                height: height * 0.15,
                width: height * 0.15,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    "assets/images/coffee.png",
                    height: height * 0.15,
                    fit: BoxFit.contain,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    height: height * 0.15,
                    width: height * 0.15,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF6E3D2C),
                      ),
                    ),
                  );
                },
              ),
            )
          : ClipOval(
              child: Image.asset(
                drink!.imageUrl,
                height: height * 0.15,
                width: height * 0.15,
                fit: BoxFit.cover,
              ),
            );
    }
    return Image.asset(
      "assets/images/coffee.png",
      height: height * 0.15,
      fit: BoxFit.contain,
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
            servingSize: servingSize.toInt(),
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
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildDrinkNameAndFavorite() {
    final drinkName = isEditMode
        ? (consumptionLog?.drinkName ?? "Unknown Drink")
        : (drink?.name ?? "Unknown Drink");

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            drinkName,
            style: const TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.bold,
              color: Color(0xFF000000),
            ),
            maxLines: 2,
            overflow: TextOverflow.visible,
          ),
        ),
        if (!isEditMode && drink != null)
          IconButton(
            onPressed: () async {
              await _drinkService.toggleFavorite(
                currentUserId,
                drink!.id,
                drink!.isFavorite,
              );
              setState(() {
                drink!.isFavorite = !drink!.isFavorite;
              });
            },
            icon: Icon(
              drink!.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: const Color(0xFFFF5151),
              size: 32,
            ),
          ),
      ],
    );
  }

  Widget _buildInformationSection() {
    final info = isEditMode
        ? "Editing consumption log - adjust serving size and caffeine will auto-calculate"
        : (drink?.information ?? "No information available");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Chip(
              label: Text(isEditMode ? "Edit Mode" : "Information"),
              backgroundColor:
                  isEditMode ? const Color(0xFF6E3D2C) : const Color(0xFF4E8D7C),
              labelStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              shape: const StadiumBorder(),
              elevation: 0,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          info,
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

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Save/Update Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6E3D2C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: _handleSave,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isEditMode ? Icons.check_circle_outline : Icons.add_circle_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isEditMode ? "Update" : "Save",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Delete Button (only in edit mode)
        if (isEditMode) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFF5151), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: _handleDelete,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline, color: Color(0xFFFF5151), size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Delete",
                    style: TextStyle(
                      color: Color(0xFFFF5151),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }
}