import 'package:flutter/material.dart';

import '../models/cell.dart';

class GridColors {
  static const Color background = Color(0xFF0F1E1E);
  static const Color container = Color.fromARGB(255, 27, 54, 54);
  static const Color start = Color.fromARGB(255, 22, 206, 68); // Bright green
  static const Color goal = Color(0xFFFF3B30); // Strong red
  static const Color empty = Color(0xFF027333); // Normal green
  static const Color weighted = Color(0xFF025939); // Dark green
  static const Color wall = Color(0xFF012340); // Deep navy/blue

  static Color color(Cell cell) {
    switch (cell.type) {
      case CellType.start:
        return GridColors.start;
      case CellType.goal:
        return GridColors.goal;
      case CellType.weighted:
        return GridColors.weighted;
      case CellType.wall:
        return GridColors.wall;
      case CellType.empty:
      default:
        return GridColors.background;
    }
  }
}
