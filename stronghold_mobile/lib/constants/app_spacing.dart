import 'package:flutter/material.dart';

abstract final class AppSpacing {
  // ═══════════════════════════════════════════
  //  AETHER SPACING SCALE
  // ═══════════════════════════════════════════

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const base = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const xxl = 28.0;
  static const xxxl = 32.0;
  static const huge = 40.0;

  // Page padding
  static const desktopPage = EdgeInsets.fromLTRB(36, 28, 36, 60);
  static const mobilePage = EdgeInsets.fromLTRB(20, 16, 20, 32);
  static const cardPadding = EdgeInsets.all(24);
  static const cardPaddingCompact =
      EdgeInsets.symmetric(horizontal: 22, vertical: 20);

  // ═══════════════════════════════════════════
  //  BORDER RADIUS
  // ═══════════════════════════════════════════

  static final heroRadius = BorderRadius.circular(24);
  static final cardRadius = BorderRadius.circular(20);
  static final panelRadius = BorderRadius.circular(16);
  static final avatarRadius = BorderRadius.circular(14);
  static final buttonRadius = BorderRadius.circular(12);
  static final smallRadius = BorderRadius.circular(10);
  static final chipRadius = BorderRadius.circular(9);
  static final badgeRadius = BorderRadius.circular(8);
  static final tinyRadius = BorderRadius.circular(7);

  // ═══════════════════════════════════════════
  //  BACKWARD COMPATIBILITY
  // ═══════════════════════════════════════════

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusXxl = 24;
  static const double screenPadding = 20;
  static const double touchTarget = 44.0;
  static const listItemPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );
}
