import 'package:flutter/material.dart';

abstract final class Motion {
  // Durations
  static const fast = Duration(milliseconds: 200);
  static const normal = Duration(milliseconds: 350);
  static const smooth = Duration(milliseconds: 500);
  static const dramatic = Duration(milliseconds: 700);
  static const slow = Duration(milliseconds: 1200);

  // Curves
  static const curve = Cubic(0.16, 1, 0.3, 1);
  static const spring = Curves.easeOutBack;
  static const gentle = Curves.easeOut;

  // Stagger
  static const staggerDelay = Duration(milliseconds: 70);
  static const maxStaggerItems = 15;
  static const sectionDelay = Duration(milliseconds: 100);
}
