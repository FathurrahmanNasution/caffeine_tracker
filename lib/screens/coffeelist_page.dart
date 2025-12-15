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
            child: SingleChildScrollView(
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
                        SizedBox(height: isLandscape ? 2 : r.mediumSpacing),
                        // Search Bar
                        _buildSearchBar(r),
                        SizedBox(height: isLandscape ? 2 : r.mediumSpacing),
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
                        SizedBox(height: isLandscape ? 1 : r.smallSpacing),
                        // Favorites Section
                        _buildFavoritesSection(r, isLandscape),
                        SizedBox(height: isLandscape ? 2 : r.mediumSpacing),
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
                        SizedBox(height: isLandscape ? 1 : r.smallSpacing),
                        // All Drinks Section - No longer Expanded
                        _buildAllDrinksSection(r, isLandscape),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'coffeelist_fab',
        onPressed: () => Navigator.pushNamed(context, '/addotherdrink'),
        backgroundColor: const Color(0xFF4E8D7C),
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        label: const Text(
          'Add Others',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
    // ✅ Simplified height calculation
    final height = isLandscape
        ? r.hp(40) // ✅ Increased from 35 to 40 for much bigger images
        : r.adaptive(
            mobile: r.hp(22),
            tablet: r.hp(24),
            desktop: r.hp(26),
          );

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
          if (snapshot.hasError) {
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

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 4), // ✅ Added padding
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final drink = favorites[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: isLandscape
                      ? r.wp(18) // ✅ Increased from 15 to 18 for easier scrolling
                      : r.adaptive(
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
    if (currentUserId.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            "Please log in to view drinks",
            style: TextStyle(color: const Color(0xFF6E3D2C), fontSize: r.sp(14)),
          ),
        ),
      );
    }

    return StreamBuilder<List<DrinkModel>>(
      stream: _drinkService.searchNonFavoriteDrinks(
        currentUserId,
        _searchQuery,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SizedBox(
            height: 200,
            child: Center(
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox(
            height: 200,
            child: Center(
              child: Text(
                "No drinks available",
                style: TextStyle(
                  color: const Color(0xFF6E3D2C),
                  fontSize: r.sp(14),
                ),
              ),
            ),
          );
        }

        final drinks = snapshot.data!;

        final crossAxisCount = r.gridCrossAxisCount(
          mobile: isLandscape ? 4 : 3, // ✅ Reduced from 5 to 4
          tablet: isLandscape ? 5 : 4,  // ✅ Reduced from 6 to 5
          desktop: 6,
        );

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            top: 4,
            bottom: r.adaptive(mobile: 70, tablet: 80, desktop: 90),
            left: 4,
            right: 4,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: r.adaptive(
              mobile: isLandscape ? 0.75 : 0.50,
              tablet: isLandscape ? 0.78 : 0.58,
              desktop: 0.66,
            ),
            mainAxisSpacing: r.adaptive(
              mobile: isLandscape ? 4 : 12,
              tablet: isLandscape ? 8 : 15,
              desktop: 18,
            ),
            crossAxisSpacing: r.adaptive(
              mobile: isLandscape ? 4 : 6,
              tablet: isLandscape ? 6 : 10,
              desktop: 14,
            ),
          ),
          itemCount: drinks.length,
          itemBuilder: (context, index) {
            final drink = drinks[index];

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
    );
  }
}
