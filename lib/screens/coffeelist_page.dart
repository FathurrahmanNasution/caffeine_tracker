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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

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
                  padding: r.pagePadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: r.mediumSpacing),
                      // Search Bar
                      _buildSearchBar(r),
                      SizedBox(height: r.mediumSpacing),
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
                      SizedBox(height: r.smallSpacing),
                      // Favorites Section
                      _buildFavoritesSection(r),
                      SizedBox(height: r.mediumSpacing),
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
                      SizedBox(height: r.smallSpacing),
                      // All Drinks Section
                      Expanded(
                        child: _buildAllDrinksSection(r),
                      ),
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
          style: TextStyle(
            color: const Color(0xFF5D3A00),
            fontSize: r.sp(14),
          ),
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
              borderSide: const BorderSide(color: Color.fromRGBO(93, 58, 0, 0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Color.fromRGBO(93, 58, 0, 0.5)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesSection(Responsive r) {
    final height = r.adaptive(
      mobile: r.hp(24),
      tablet: r.hp(28),
      desktop: r.hp(32),
    );

    return SizedBox(
      height: height,
      child: StreamBuilder<List<DrinkModel>>(
        stream: _drinkService.searchFavoriteDrinks(currentUserId, _searchQuery),
        builder: (context, snapshot) {
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
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final drink = favorites[index];
              return SizedBox(
                width: r.adaptive(
                  mobile: r.wp(32),
                  tablet: r.wp(24),
                  desktop: r.wp(18),
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
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAllDrinksSection(Responsive r) {
    return Stack(
      children: [
        StreamBuilder<List<DrinkModel>>(
          stream: _drinkService.searchNonFavoriteDrinks(currentUserId, _searchQuery),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
            final crossAxisCount = r.gridCrossAxisCount(
              mobile: 3,
              tablet: 4,
              desktop: 6,
            );

            return GridView.builder(
              padding: const EdgeInsets.only(top: 0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: r.adaptive(
                  mobile: 0.56,
                  tablet: 0.65,
                  desktop: 0.75,
                ),
                mainAxisSpacing: r.adaptive(mobile: 15, tablet: 18, desktop: 20),
                crossAxisSpacing: r.adaptive(mobile: 3, tablet: 8, desktop: 12),
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
  }
}