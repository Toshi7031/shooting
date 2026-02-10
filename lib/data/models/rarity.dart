import 'package:flutter/material.dart';

enum Rarity {
  common,
  magic,
  rare,
  unique,
  legendary,
}

extension RarityExtension on Rarity {
  Color get color {
    switch (this) {
      case Rarity.common:
        return Colors.white;
      case Rarity.magic:
        return Colors.blue;
      case Rarity.rare:
        return Colors.yellow;
      case Rarity.unique:
        return Colors.orange;
      case Rarity.legendary:
        return Colors.purpleAccent;
    }
  }

  String get label {
    switch (this) {
      case Rarity.common:
        return 'Common';
      case Rarity.magic:
        return 'Magic';
      case Rarity.rare:
        return 'Rare';
      case Rarity.unique:
        return 'Unique';
      case Rarity.legendary:
        return 'LEGENDARY';
    }
  }
}
