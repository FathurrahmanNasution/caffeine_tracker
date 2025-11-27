import 'package:flutter/material.dart';

class ConsumptionLogCard extends StatelessWidget {
  final String name;
  final String caffeine;
  final String size;
  final String time;
  final String image; // Can be URL, asset path, or emoji
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
            // ✅ Dynamic Image Container
            _buildImageContainer(),
            const SizedBox(width: 15),

            // TEXT INFO
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

            // DELETE BUTTON
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

  // ✅ Build image container that handles URLs, assets, and emojis
  Widget _buildImageContainer() {
    // Check if it's a URL (network image)
    if (image.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          image,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackContainer();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.brown[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
    // Check if it's an asset path
    else if (image.startsWith('assets/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          image,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackContainer();
          },
        ),
      );
    }
    // Otherwise treat as emoji
    else {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.brown[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            image,
            style: const TextStyle(fontSize: 28),
          ),
        ),
      );
    }
  }

  // ✅ Fallback container for failed image loads
  Widget _buildFallbackContainer() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.brown[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          '☕',
          style: TextStyle(fontSize: 28),
        ),
      ),
    );
  }
}