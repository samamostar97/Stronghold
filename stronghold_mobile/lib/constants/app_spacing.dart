import 'package:flutter/material.dart';

abstract class AppSpacing {
  // -- Spacing scale --
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  // -- Screen-level padding --
  static const double screenPadding = 20;

  // -- Border radius scale --
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusXxl = 24;

  // -- Common padding presets --
  static const cardPadding = EdgeInsets.all(16);
  static const listItemPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );

  // -- Touch target minimum --
  static const double touchTarget = 44.0;
}
