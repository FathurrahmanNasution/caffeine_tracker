import 'package:flutter/material.dart';

class CoffeeListPage extends StatelessWidget {
  const CoffeeListPage({super.key});

  //List data minuman
  final List<Map<String, String>> coffeeList = const [
    {
      "name": "Espresso",
      "image": "assets/images/coffee.png",
      "desc": "2.1 mg per mL",
    },
    {
      "name": "Americano",
      "image": "assets/images/coffee.png",
      "desc": "1.9 mg per mL",
    },
    {
      "name": "Latte",
      "image": "assets/images/coffee.png",
      "desc": "1.2 mg per mL",
    },
    {
      "name": "Cappuccino",
      "image": "assets/images/coffee.png",
      "desc": "1.5 mg per mL",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EBE0),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: AppBar(
          backgroundColor: const Color(0xFFD5BBA2),
          elevation: 0,
          centerTitle: true,
          title: GestureDetector(
            child: Image.asset(
              "assets/images/coffee.png",
              height: 52,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                icon: const CircleAvatar(
                  backgroundImage: AssetImage("assets/images/profile.png"),
                ),
                onPressed: () {
                  // Aksi saat ikon ditekan
                },
              ),
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),

            // 🔍 Search bar
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 380,
                child: TextField(
                  style: const TextStyle(color: Color(0xFF5D3A00)),
                  decoration: InputDecoration(
                    hintText: "Search your drinks...",
                    hintStyle: const TextStyle(color: Color(0xFF6E3D2C)),
                    prefixIcon: Container(
                      margin: const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFA67C52)),
                        color: const Color(0xFFD5BBA2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.search,
                        color: Color(0xFF6E3D2C),
                        size: 28,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white54,
                    contentPadding: const EdgeInsets.only(left: 40, right: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Color.fromRGBO(93, 58, 0, 0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Color.fromRGBO(93, 58, 0, 0.5)),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Favorites section
            const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text(
                "Your Favorites",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF6E3D2C),
                ),
              ),
            ),

            const SizedBox(height: 20),
            SizedBox( //
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: coffeeList.length,
                itemBuilder: (context, index) {
                  final coffee = coffeeList[index];
                  return SizedBox(
                    width: MediaQuery.of(context).size.width / 3 - 12,
                    child: _buildCoffeeCard(
                      coffee["name"]!,
                      coffee["image"]!,
                      coffee["desc"]!,
                      showLove: true,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            // All Drinks section
            const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text(
                "All Drinks",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF6E3D2C),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Expanded(
              child: Stack(
                children: [
                  // GridView tetap full dan bisa scroll
                  GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.60,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 5,
                    ),
                    itemCount: coffeeList.length,
                    itemBuilder: (context, index) {
                      final coffee = coffeeList[index];
                      return _buildCoffeeCard(
                        coffee["name"]!,
                        coffee["image"]!,
                        coffee["desc"]!,
                      );
                    },
                  ),

                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4E8D7C),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                      ),
                      onPressed: () {
                        debugPrint("Add Others clicked");
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            "Add Others",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 6), // jarak antara teks dan ikon
                          Icon(
                            Icons.add_circle_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),

      // bottom navigation bar
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

  // 🔧 Coffee Card baru
  static Widget _buildCoffeeCard(String name, String imagePath, String description, {bool showLove = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 145,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    imagePath,
                    height: 95,
                    fit: BoxFit.contain,
                  ),
                ),
                if (showLove)
                  const Positioned(
                    top: 10,
                    right: 10,
                    child: Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),

          // Nama & deskripsi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6E3D2C),
                  ),
                ),
              ],
            ),
          ),

          // Tombol plus
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 0, top: 5),
              child: Icon(
                Icons.add_circle_outline,
                size: 24,
                color: Color(0xFF4E8D7C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
