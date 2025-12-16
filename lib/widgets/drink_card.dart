import 'package:flutter/material.dart';
import 'package:caffeine_tracker/model/drink_model.dart';
import 'package:caffeine_tracker/utils/responsive.dart';

class DrinkCard extends StatelessWidget {
  final DrinkModel drink;
  final bool showFavoriteIcon;
  final bool isFavoritesList;
  final VoidCallback? onAddPressed;

  const DrinkCard({
    super.key,
    required this.drink,
    this.showFavoriteIcon = false,
    this.isFavoritesList = false,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Container(
      margin: isFavoritesList
          ? EdgeInsets.zero
          : EdgeInsets.only(
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
          // Image Section - Use Flexible instead of Expanded for favorites
          isFavoritesList
              ? Flexible(
                  flex: isLandscape ? 7 : 6,
                  child: _buildImageSection(r, isLandscape),
                )
              : Expanded(
                  flex: isLandscape ? 7 : 6,
                  child: _buildImageSection(r, isLandscape),
                ),
          // Text Section - Use Flexible instead of Expanded for favorites
          isFavoritesList
              ? Flexible(
                  flex: isLandscape ? 3 : 3,
                  child: _buildTextSection(r, isLandscape),
                )
              : Expanded(
                  flex: isLandscape ? 3 : 3,
                  child: _buildTextSection(r, isLandscape),
                ),
          // Button Section
          _buildButtonSection(r, isLandscape),
        ],
      ),
    );
  }

  Widget _buildImageSection(Responsive r, bool isLandscape) {
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: EdgeInsets.all(isLandscape ? 6 : 8),
            child: drink.imageUrl.startsWith('http')
                ? Image.network(
                    drink.imageUrl,
                    height: isLandscape ? r.hp(15) : r.wp(18),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.local_cafe,
                        size: isLandscape ? r.hp(6) : r.wp(12),
                        color: const Color(0xFF6E3D2C),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  )
                : Image.asset(
                    drink.imageUrl,
                    height: isLandscape ? r.hp(15) : r.wp(18),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.local_cafe,
                        size: isLandscape ? r.hp(15) : r.wp(18),
                        color: const Color(0xFF6E3D2C),
                      );
                    },
                  ),
          ),
        ),
        if (showFavoriteIcon)
          Positioned(
            top: r.adaptive(
              mobile: isLandscape ? 2 : 6,
              tablet: 8,
              desktop: 10,
            ),
            right: r.adaptive(
              mobile: isLandscape ? 2 : 6,
              tablet: 8,
              desktop: 10,
            ),
            child: Icon(
              Icons.favorite,
              color: Colors.red,
              size: r.sp(isLandscape ? 16 : 16),
            ),
          ),
      ],
    );
  }

  Widget _buildTextSection(Responsive r, bool isLandscape) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: r.adaptive(
          mobile: isLandscape ? 4 : 8,
          tablet: 10,
          desktop: 12,
        ),
        vertical: isLandscape ? 2 : 4,
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
              fontSize: r.sp(isLandscape ? 9 : 12),
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isLandscape ? 1 : 2),
          Text(
            "${drink.caffeineinMg}mg ~ ${drink.standardVolume}mL",
            style: TextStyle(
              fontSize: r.sp(isLandscape ? 7.5 : 10),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6E3D2C),
              height: 1.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildButtonSection(Responsive r, bool isLandscape) {
    return Padding(
      padding: EdgeInsets.only(right: 2, bottom: isLandscape ? 2 : 4),
      child: Align(
        alignment: Alignment.bottomRight,
        child: IconButton(
          icon: Icon(
            Icons.add_circle_outline,
            size: r.sp(isLandscape ? 16 : 18),
            color: const Color(0xFF4E8D7C),
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: onAddPressed,
        ),
      ),
    );
  }
}
