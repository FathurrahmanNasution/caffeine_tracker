import 'package:flutter/material.dart';
import 'package:caffeine_tracker/model/drink_model.dart';
import 'package:caffeine_tracker/utils/responsive.dart';

class DrinkCard extends StatelessWidget {
  final DrinkModel drink;
  final bool showFavoriteIcon;
  final VoidCallback? onAddPressed;

  const DrinkCard({
    super.key,
    required this.drink,
    this.showFavoriteIcon = false,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return Container(
      margin: EdgeInsets.only(
        right: r.adaptive(mobile: 10, tablet: 12, desktop: 14),
      ),
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
          // Image Section
          SizedBox(
            height: r.adaptive(
              mobile: r.wp(28.5),
              tablet: r.wp(20),
              desktop: r.wp(12),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: drink.imageUrl.startsWith('http')
                      ? Image.network(
                    drink.imageUrl,
                    height: r.adaptive(
                      mobile: r.wp(31),
                      tablet: r.wp(21),
                      desktop: r.wp(13),
                    ),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        "assets/images/coffee.png",
                        height: r.adaptive(
                          mobile: r.wp(22),
                          tablet: r.wp(15),
                          desktop: r.wp(10),
                        ),
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
                    height: r.adaptive(
                      mobile: r.wp(23),
                      tablet: r.wp(18),
                      desktop: r.wp(11),
                    ),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        "assets/images/coffee.png",
                        height: r.adaptive(
                          mobile: r.wp(21),
                          tablet: r.wp(15),
                          desktop: r.wp(10),
                        ),
                        fit: BoxFit.contain,
                      );
                    },
                  ),
                ),
                if (showFavoriteIcon)
                  Positioned(
                    top: r.adaptive(mobile: 11, tablet: 14, desktop: 16),
                    right: r.adaptive(mobile: 11, tablet: 14, desktop: 16),
                    child: Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: r.sp(20),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: r.adaptive(mobile: 12, tablet: 14, desktop: 16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  drink.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: r.sp(14.3),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),
                Text(
                  "${drink.caffeineinMg}mg ~ ${drink.standardVolume}mL",
                  style: TextStyle(
                    fontSize: r.sp(11.5),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6E3D2C),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
              icon: Icon(
                Icons.add_circle_outline,
                size: r.sp(24),
                color: const Color(0xFF4E8D7C),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: onAddPressed,
            ),
          ),
          SizedBox(height: r.adaptive(mobile: 4, tablet: 6, desktop: 8)),
        ],
      ),
    );
  }
}