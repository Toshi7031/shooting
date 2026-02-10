import 'package:flutter/material.dart';

class GameColors {
  static const Color background = Color(0xFF222222);
  static const Color accent = Colors.yellow;
  static const Color textMain = Colors.white;
  static const Color textSecondary = Colors.grey;
  static const Color success = Colors.green;
  static const Color error = Colors.red;
  static const Color warning = Colors.orange;
  static const Color legendary = Colors.purpleAccent;
}

class GameConstants {
  // Game Board / Camera
  static const double responsiveWidth = 360.0; // Reference width if needed

  // UI
  static const double bottomMenuHeight = 200.0;
  static const double uiPadding = 20.0;

  // Spawning
  static const double bossSpawnY = -100.0;
  static const double spawnEdgeOffset = 20.0;
  static const double spawnAvoidBottomHeight = bottomMenuHeight;

  // Gameplay
  static const double bossSpeed = 5.0;
  static const double defaultEnemySpeed = 20.0;
  static const int coreDamageFromEnemy = 10;

  // Shop
  static const int healCost = 50;
  static const int healAmount = 50;
  static const int randomUpgradeCost = 200;
}
