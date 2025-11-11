import 'package:flutter/material.dart';

class Responsive {
  final BuildContext context;
  late final double _width;
  late final double _height;
  late final Orientation _orientation;

  Responsive(this.context) {
    final size = MediaQuery.of(context).size;
    _width = size.width;
    _height = size.height;
    _orientation = MediaQuery.of(context).orientation;
  }

  // Device type getters
  bool get isMobile => _width < 600;
  bool get isTablet => _width >= 600 && _width < 1024;
  bool get isDesktop => _width >= 1024;
  bool get isPortrait => _orientation == Orientation.portrait;
  bool get isLandscape => _orientation == Orientation.landscape;

  // Responsive width
  double wp(double percentage) => _width * (percentage / 100);

  // Responsive height
  double hp(double percentage) => _height * (percentage / 100);

  // Responsive font size
  double sp(double size) {
    if (isDesktop) return size * 1.2;
    if (isTablet) return size * 1.1;
    return size;
  }

  // Grid cross axis count
  int gridCrossAxisCount({
    int mobile = 2,
    int tablet = 3,
    int desktop = 4,
  }) {
    if (isDesktop) return desktop;
    if (isTablet) return tablet;
    return mobile;
  }

  // Adaptive value based on device type
  T adaptive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  // Max content width for web/desktop
  double get maxContentWidth {
    if (isDesktop) return 1200;
    if (isTablet) return 800;
    return _width;
  }

  // Padding responsive
  EdgeInsets get pagePadding => EdgeInsets.all(adaptive(
    mobile: 16,
    tablet: 24,
    desktop: 32,
  ));

  EdgeInsets get cardPadding => EdgeInsets.all(adaptive(
    mobile: 12,
    tablet: 16,
    desktop: 20,
  ));

  // Spacing responsive
  double get smallSpacing => adaptive(mobile: 10, tablet: 12, desktop: 16);
  double get mediumSpacing => adaptive(mobile: 18, tablet: 20, desktop: 24);
  double get largeSpacing => adaptive(mobile: 24, tablet: 32, desktop: 40);
}

// Extension untuk akses mudah
extension ResponsiveExtension on BuildContext {
  Responsive get responsive => Responsive(this);
}