import 'package:flutter/material.dart';

class DrinkinformationPage extends StatelessWidget {
  const DrinkinformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EBE0),

      // 🔼 AppBar custom
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(200),
        child: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: const Color(0xFFD5BBA2),
          elevation: 0,
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // gambar minuman
              Center(
                child: Image.asset(
                  "assets/images/americano.png", // ganti sesuai asset
                  height: 160,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12, top: 8),
              child: IconButton(
                icon: const CircleAvatar(
                  backgroundImage: AssetImage("assets/images/profile.png"),
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Nama minuman + favorit
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Americano",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B2F2F),
                  ),
                ),
                Icon(Icons.favorite_border, color: Colors.red),
              ],
            ),
            const SizedBox(height: 12),

            // Informasi singkat
            const Row(
              children: [
                Chip(
                  label: Text("Information"),
                  backgroundColor: Color(0xFF4E8D7C),
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur aliquet turpis...",
              style: TextStyle(fontSize: 14, height: 1.4, color: Color(0xFF6E3D2C)),
            ),

            const SizedBox(height: 24),

            // Serving size
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Enter serving size"),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF6E3D2C)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {},
                      ),
                      const Text("240ml"),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Caffeine content
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD5BBA2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.coffee, size: 18),
                      SizedBox(width: 6),
                      Text("50mg"),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Time taken
            Row(
              children: const [
                Icon(Icons.access_time, size: 18, color: Color(0xFF6E3D2C)),
                SizedBox(width: 8),
                Text("Wednesday, 10th Sept 2025   04:00 PM"),
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
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {},
                child: const Text(
                  "Save",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),

      // 🔽 Bottom Navigation Bar (sama kayak page lain)
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        selectedItemColor: const Color(0xFF6E3D2C),
        unselectedItemColor: const Color(0xFFA67C52),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_food_beverage_outlined), label: "Add Drinks"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: "Logs"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
