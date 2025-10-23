import 'package:flutter/material.dart';
import 'package:caffeine_tracker/model/drink_model.dart';
import 'package:caffeine_tracker/services/drink_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CoffeeListPage extends StatefulWidget {
  const CoffeeListPage({super.key});

  @override
  State<CoffeeListPage> createState() => _CoffeeListPageState();
}

class _CoffeeListPageState extends State<CoffeeListPage> {
  final DrinkService _drinkService = DrinkService();
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5EBE0),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: AppBar(
          backgroundColor: const Color(0xFFD5BBA2),
          elevation: 0,
          centerTitle: true,
          title: GestureDetector(
            child: Image.asset("assets/images/coffee.png", height: height * 0.06),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
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

      body: Padding(
        padding: EdgeInsets.all(width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height * 0.02),

            // 🔍 Search bar
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: width * 0.9,
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  style: const TextStyle(color: Color(0xFF5D3A00)),
                  decoration: InputDecoration(
                    hintText: "Search your drinks...",
                    hintStyle: const TextStyle(color: Color(0xFF6E3D2C)),
                    prefixIcon: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFA67C52)),
                        color: const Color(0xFFD5BBA2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.search, color: Color(0xFF6E3D2C), size: 24),
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

            SizedBox(height: height * 0.025),

            // Favorites section
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text("Your Favorites",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF6E3D2C))),
            ),

            SizedBox(height: height * 0.02),

            SizedBox(
              height: height * 0.24,
              child: StreamBuilder<List<DrinkModel>>(
                stream: _drinkService.searchFavoriteDrinks(currentUserId, _searchQuery),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text("No favorites yet",
                          style: TextStyle(color: Color(0xFF6E3D2C))),
                    );
                  }

                  final favorites = snapshot.data!;
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final drink = favorites[index];
                      return SizedBox(
                        width: width * 0.32,
                        child: _buildCoffeeCard(
                            context,
                            drink,
                            showLove: true
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            SizedBox(height: height * 0.025),

            // All Drinks section
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text("All Drinks",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF6E3D2C))),
            ),

            SizedBox(height: height * 0.02),
            Expanded(
              child: Stack(
                children: [
                  StreamBuilder<List<DrinkModel>>(
                    stream: _drinkService.searchNonFavoriteDrinks(currentUserId, _searchQuery),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text("No drinks available",
                              style: TextStyle(color: Color(0xFF6E3D2C))),
                        );
                      }

                      final drinks = snapshot.data!;
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: width < 360 ? 2 : 3,
                          childAspectRatio: 0.56,
                          mainAxisSpacing: 15,
                          crossAxisSpacing: 3,
                        ),
                        itemCount: drinks.length,
                        itemBuilder: (context, index) {
                          final drink = drinks[index];
                          return _buildCoffeeCard(context, drink);
                        },
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
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.04,
                          vertical: height * 0.015,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/addotherdrink');
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text("Add Others",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                          SizedBox(width: 6),
                          Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
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
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_food_beverage_outlined), label: "Add Drinks"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: "Logs"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  // 🔧 Coffee Card responsif
  Widget _buildCoffeeCard(BuildContext context, DrinkModel drink, {bool showLove = false}) {
    final width = MediaQuery.of(context).size.width;
    return Container(

      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.05), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: width * 0.3,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: drink.imageUrl.startsWith('http')
                      ? Image.network(
                    drink.imageUrl,
                    height: width * 0.31,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        "assets/images/coffee.png",
                        height: width * 0.21,
                        fit: BoxFit.contain,
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                  )
                      : Image.asset(
                    drink.imageUrl,
                    height: width * 0.25,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        "assets/images/coffee.png",
                        height: width * 0.21,
                        fit: BoxFit.contain,
                      );
                    },
                  ),
                ),
                if (showLove)
                  const Positioned(top: 12, right: 12, child: Icon(Icons.favorite, color: Colors.red, size: 20)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(drink.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.3)),
                Text(
                  "${drink.caffeineinMg}mg ~ ${drink.standardVolume}mL",
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: Color(0xFF6E3D2C)),
                ),
              ],
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 24, color: Color(0xFF4E8D7C)),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  '/drinkinformation',
                  arguments: drink,
                );
                if (result== true && mounted){
                  setState(() {});
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
