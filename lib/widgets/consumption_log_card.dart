import 'package:flutter/material.dart';

class ConsumptionLogCard extends StatelessWidget {
  final String name;
  final String caffeine;
  final String size;
  final String time;
  final String image;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ConsumptionLogCard({
    super.key,
    required this.name,
    required this.caffeine,
    required this.size,
    required this.time,
    required this.image,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xffd5bba2),
          border: Border.all(color: const Color(0xffa67c52), width: 1.0),
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
                child: Text(image, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '$caffeine • $size',
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: Color(0xff42261d),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (time.isNotEmpty) ...[
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
                        time,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            GestureDetector(
              onTap: onDelete,
              child: Transform.translate(
                offset: const Offset(10, -25.0),
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
}