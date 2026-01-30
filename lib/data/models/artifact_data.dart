import 'rarity.dart';
import '../effects/item_effect.dart';

/// アーティファクト（パッシブ装備品）のデータ
class ArtifactData {
  final String name;
  final String description;
  final Rarity rarity;
  final List<ItemEffect> effects;
  final String? iconPath;

  const ArtifactData({
    required this.name,
    required this.description,
    required this.rarity,
    this.effects = const [],
    this.iconPath,
  });
}
