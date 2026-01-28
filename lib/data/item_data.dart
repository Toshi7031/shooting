import 'rarity.dart';
import 'tags.dart';
import 'item_effect.dart';

class BaseStats {
  final double damage;
  final double speed;

  const BaseStats({
    required this.damage,
    required this.speed,
  });
}

class ItemData {
  final String name;
  final Rarity rarity;
  final List<GameTag> tags;
  final BaseStats stats;
  final List<ItemEffect> effects;
  final String? assetPath;
  final String description;

  const ItemData({
    required this.name,
    required this.rarity,
    required this.tags,
    required this.stats,
    this.effects = const [],
    this.assetPath,
    this.description = "",
  });
}
