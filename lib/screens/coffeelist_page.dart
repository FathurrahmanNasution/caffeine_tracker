import 'package:flutter/material.dart';
import 'package:caffeine_tracker/model/drink_model.dart';
import 'package:caffeine_tracker/services/drink_service.dart';
import 'package:caffeine_tracker/widgets/drink_card.dart';
import 'package:caffeine_tracker/widgets/app_top_navigation.dart';
import 'package:caffeine_tracker/utils/responsive.dart';
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
  void initState() {
    super.initState();
    print("CoffeeListPage initialized");
    print("Current User ID: $currentUserId");

    // Check if user is logged in
    if (currentUserId.isEmpty) {
      print("WARNING: No user logged in!");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please log in to view drinks")),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: const Color(0xFFF5EBE0),
      body: Column(
        children: [
          const AppTopNavigation(),
          Expanded(
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: r.maxContentWidth),
                child: Padding(
                  padding: isLandscape
                      ? EdgeInsets.symmetric(
                          horizontal: r.pagePadding.horizontal / 2,
                          vertical: 4,
                        )
                      : r.pagePadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: isLandscape ? 4 : r.mediumSpacing),
                      // Search Bar
                      _buildSearchBar(r),
                      SizedBox(height: isLandscape ? 4 : r.mediumSpacing),
                      // Your Favorites Title
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          "Your Favorites",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: r.sp(18),
                            color: const Color(0xFF6E3D2C),
                          ),
                        ),
                      ),
                      SizedBox(height: isLandscape ? 2 : r.smallSpacing),
                      // Favorites Section
                      _buildFavoritesSection(r, isLandscape),
                      SizedBox(height: isLandscape ? 4 : r.mediumSpacing),
                      // All Drinks Title
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          "All Drinks",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: r.sp(18),
                            color: const Color(0xFF6E3D2C),
                          ),
                        ),
                      ),
                      SizedBox(height: isLandscape ? 2 : r.smallSpacing),
                      // All Drinks Section
                      Expanded(child: _buildAllDrinksSection(r, isLandscape)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(Responsive r) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: r.adaptive(
          mobile: r.wp(90),
          tablet: r.wp(70),
          desktop: r.wp(60),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          style: TextStyle(color: const Color(0xFF5D3A00), fontSize: r.sp(14)),
          decoration: InputDecoration(
            hintText: "Search your drinks...",
            hintStyle: TextStyle(
              color: const Color(0xFF6E3D2C),
              fontSize: r.sp(14),
            ),
            prefixIcon: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFA67C52)),
                color: const Color(0xFFD5BBA2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search,
                color: const Color(0xFF6E3D2C),
                size: r.sp(24),
              ),
            ),
            filled: true,
            fillColor: Colors.white54,
            contentPadding: const EdgeInsets.only(left: 40, right: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color.fromRGBO(93, 58, 0, 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color.fromRGBO(93, 58, 0, 0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesSection(Responsive r, bool isLandscape) {
    final height = r.adaptive(
      mobile: isLandscape ? r.hp(19) + 17 : r.hp(18) + 38,
      tablet: r.hp(20) + 38,
      desktop: r.hp(24) + 38,
    );

    // If user is not logged in, show message
    if (currentUserId.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            "Please log in to view favorites",
            style: TextStyle(
              color: const Color(0xFF6E3D2C),
              fontSize: r.sp(14),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: StreamBuilder<List<DrinkModel>>(
        stream: _drinkService.searchFavoriteDrinks(currentUserId, _searchQuery),
        builder: (context, snapshot) {
          print("Favorites Stream State: ${snapshot.connectionState}");

          if (snapshot.hasError) {
            print("Favorites Error: ${snapshot.error}");
            print("Error stack trace: ${snapshot.stackTrace}");
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Error loading favorites",
                  style: TextStyle(color: Colors.red, fontSize: r.sp(12)),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            print("No favorites data");
            return Center(
              child: Text(
                "No favorites yet",
                style: TextStyle(
                  color: const Color(0xFF6E3D2C),
                  fontSize: r.sp(14),
                ),
              ),
            );
          }

          final favorites = snapshot.data!;
          print("Favorites count: ${favorites.length}");

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final drink = favorites[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: r.adaptive(
                    mobile: r.wp(28),
                    tablet: r.wp(22),
                    desktop: r.wp(16),
                  ),
                  child: DrinkCard(
                    drink: drink,
                    showFavoriteIcon: true,
                    onAddPressed: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        '/drinkinformation',
                        arguments: drink,
                      );
                      if (result == true && mounted) {
                        setState(() {});
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAllDrinksSection(Responsive r, bool isLandscape) {
    // If user is not logged in, show message
    if (currentUserId.isEmpty) {
      return Center(
        child: Text(
          "Please log in to view drinks",
          style: TextStyle(color: const Color(0xFF6E3D2C), fontSize: r.sp(14)),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            StreamBuilder<List<DrinkModel>>(
              stream: _drinkService.searchNonFavoriteDrinks(
                currentUserId,
                _searchQuery,
              ),
              builder: (context, snapshot) {
                print("All Drinks Stream State: ${snapshot.connectionState}");

                if (snapshot.hasError) {
                  print("All Drinks Error: ${snapshot.error}");
                  print("Error stack trace: ${snapshot.stackTrace}");
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Error loading drinks",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: r.sp(14),
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${snapshot.error}",
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: r.sp(12),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  print("No drinks data available");
                  return Center(
                    child: Text(
                      "No drinks available",
                      style: TextStyle(
                        color: const Color(0xFF6E3D2C),
                        fontSize: r.sp(14),
                      ),
                    ),
                  );
                }

                final drinks = snapshot.data!;
                print("All drinks count: ${drinks.length}");

                final crossAxisCount = r.gridCrossAxisCount(
                  mobile: isLandscape ? 6 : 3,
                  tablet: isLandscape ? 7 : 4,
                  desktop: 6,
                );

                return GridView.builder(
                  padding: EdgeInsets.only(
                    top: isLandscape ? 0 : 0,
                    bottom: r.adaptive(mobile: 70, tablet: 80, desktop: 90),
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: r.adaptive(
                      mobile: isLandscape ? 0.6725 : 0.50,
                      tablet: isLandscape ? 0.7225 : 0.58,
                      desktop: 0.66,
                    ),
                    mainAxisSpacing: r.adaptive(
                      mobile: isLandscape ? 0 : 12,
                      tablet: 15,
                      desktop: 18,
                    ),
                    crossAxisSpacing: r.adaptive(
                      mobile: isLandscape ? 2 : 6,
                      tablet: 10,
                      desktop: 14,
                    ),
                  ),
                  itemCount: drinks.length,
                  itemBuilder: (context, index) {
                    final drink = drinks[index];
                    print("Building drink card for: ${drink.name}");

                    return DrinkCard(
                      drink: drink,
                      onAddPressed: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          '/drinkinformation',
                          arguments: drink,
                        );
                        if (result == true && mounted) {
                          setState(() {});
                        }
                      },
                    );
                  },
                );
              },
            ),
            Positioned(
              bottom: r.adaptive(mobile: 10, tablet: 15, desktop: 20),
              right: r.adaptive(mobile: 10, tablet: 15, desktop: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4E8D7C),
                  shape: const StadiumBorder(),
                  padding: EdgeInsets.symmetric(
                    horizontal: r.adaptive(mobile: 16, tablet: 20, desktop: 24),
                    vertical: r.adaptive(mobile: 12, tablet: 14, desktop: 16),
                  ),
                ),
                onPressed: () => Navigator.pushNamed(context, '/addotherdrink'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Add Others",
                      style: TextStyle(
                        fontSize: r.sp(16),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                      size: r.sp(24),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
