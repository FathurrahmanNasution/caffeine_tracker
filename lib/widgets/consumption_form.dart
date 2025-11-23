import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class ConsumptionForm extends StatelessWidget {
  final int servingSize;
  final double caffeineContent;
  final DateTime selectedDateTime;
  final TextEditingController servingController;
  final TextEditingController caffeineController;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final Function(String) onServingChanged;
  final Function(String) onCaffeineChanged;
  final VoidCallback onSelectDateTime;

  const ConsumptionForm({
    super.key,
    required this.servingSize,
    required this.caffeineContent,
    required this.selectedDateTime,
    required this.servingController,
    required this.caffeineController,
    required this.onIncrement,
    required this.onDecrement,
    required this.onServingChanged,
    required this.onCaffeineChanged,
    required this.onSelectDateTime,
  });

  String _formatDateTime(DateTime dateTime) {
    final DateFormat dateFormatter = DateFormat('EEEE, dd MMM yyyy');
    final DateFormat timeFormatter = DateFormat('hh:mm a');
    return '${dateFormatter.format(dateTime)}   ${timeFormatter.format(dateTime)}';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Serving Size Input
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
                    onPressed: onDecrement,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  Expanded(
                    child: TextField(
                      controller: servingController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: onServingChanged,
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
                    onPressed: onIncrement,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Caffeine Content Input
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
                      controller: caffeineController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: onCaffeineChanged,
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

        // Time Taken Section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Row(
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
              onTap: onSelectDateTime,
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
      ],
    );
  }
}