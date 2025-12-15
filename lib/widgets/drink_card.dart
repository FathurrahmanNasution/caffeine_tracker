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
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Container(
      margin: EdgeInsets.only(
        right: r.adaptive(
          mobile: isLandscape ? 4 : 8,
          tablet: 12,
          desktop: 14,
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image Section
          Expanded(
            flex: isLandscape ? 7 : 6,
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(
                      isLandscape ? 8 : 8,
                    ),
                    child: drink.imageUrl.startsWith('http')
                        ? Image.network(
                            drink.imageUrl,
                            height: isLandscape
                                ? r.hp(20)
                                : r.wp(20),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.local_cafe,
                                size: isLandscape ? r.hp(8) : r.wp(15),
                                color: const Color(0xFF6E3D2C),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                          )
                        : Image.asset(
                            drink.imageUrl,
                            height: isLandscape ? r.hp(18) : r.wp(20),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.local_cafe,
                                size: isLandscape ? r.hp(20) : r.wp(20),
                                color: const Color(0xFF6E3D2C),
                              );
                            },
                          ),
                  ),
                ),
                if (showFavoriteIcon)
                  Positioned(
                    top: r.adaptive(
                      mobile: isLandscape ? 2 : 8,
                      tablet: 10,
                      desktop: 12,
                    ),
                    right: r.adaptive(
                      mobile: isLandscape ? 2 : 8,
                      tablet: 10,
                      desktop: 12,
                    ),
                    child: Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: r.sp(isLandscape ? 18 : 18),
                    ),
                  ),
              ],
            ),
          ),
          // Text Section
          Expanded(
            flex: isLandscape ? 3 : 3,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: r.adaptive(
                  mobile: isLandscape ? 6 : 10,
                  tablet: 12,
                  desktop: 14,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    drink.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: r.sp(isLandscape ? 10 : 13),
                      height: isLandscape ? 1.7 : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isLandscape ? 0 : 2),
                  Text(
                    "${drink.caffeineinMg}mg ~ ${drink.standardVolume}mL",
                    style: TextStyle(
                      fontSize: r.sp(isLandscape ? 8 : 10.5),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6E3D2C),
                      height: isLandscape ? 1.0 : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          // Button Section
          Padding(
            padding: EdgeInsets.only(
              right: 4,
              bottom: isLandscape ? 0 : 4,
            ),
            child: Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: Icon(
                  Icons.add_circle_outline,
                  size: r.sp(isLandscape ? 18 : 20),
                  color: const Color(0xFF4E8D7C),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onAddPressed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
