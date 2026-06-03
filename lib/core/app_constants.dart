import 'package:flutter/material.dart';

class AppPadding {
  static const double extraSmall = 4.0;
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double extraLarge = 32.0;

  static const EdgeInsets screenPadding = EdgeInsets.all(medium);
  static const EdgeInsets horizontalPadding =
      EdgeInsets.symmetric(horizontal: medium);
  static const EdgeInsets verticalPadding =
      EdgeInsets.symmetric(vertical: medium);
}

class AppRadius {
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double extraLarge = 24.0;

  static final BorderRadius smallBorderRadius = BorderRadius.circular(small);
  static final BorderRadius mediumBorderRadius = BorderRadius.circular(medium);
  static final BorderRadius largeBorderRadius = BorderRadius.circular(large);
}

class AppShadows {
  static List<BoxShadow> get light => [
        BoxShadow(
          color: Colors.black.withAlpha(50),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get medium => [
        BoxShadow(
          color: Colors.black.withAlpha(10),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
}
