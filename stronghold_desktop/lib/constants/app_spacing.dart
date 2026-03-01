import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const base = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const xxl = 28.0;
  static const xxxl = 32.0;
  static const huge = 40.0;

  static const desktopPage = EdgeInsets.fromLTRB(20, 16, 20, 24);
  static const mobilePage = EdgeInsets.fromLTRB(14, 12, 14, 20);
  static const cardPadding = EdgeInsets.all(20);
  static const cardPaddingCompact = EdgeInsets.symmetric(
    horizontal: 18,
    vertical: 16,
  );

  static final heroRadius = BorderRadius.circular(20);
  static final cardRadius = BorderRadius.circular(14);
  static final panelRadius = BorderRadius.circular(12);
  static final avatarRadius = BorderRadius.circular(10);
  static final buttonRadius = BorderRadius.circular(10);
  static final smallRadius = BorderRadius.circular(8);
  static final chipRadius = BorderRadius.circular(8);
  static final badgeRadius = BorderRadius.circular(7);
  static final tinyRadius = BorderRadius.circular(6);

  static const double radiusSm = 8;
  static const double radiusMd = 10;
  static const double radiusLg = 12;
  static const double radiusXl = 14;
  static const double radiusXxl = 18;
}
