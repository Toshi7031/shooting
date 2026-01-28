import 'item_data.dart';
import 'item_effect.dart';
import 'rarity.dart';
import 'tags.dart';

class ItemRepository {
  static final ItemData defaultBall = ItemData(
    name: "Iron Ball",
    rarity: Rarity.common,
    tags: [GameTag.physical, GameTag.projectile],
    stats: const BaseStats(damage: 10, speed: 300),
    assetPath: 'items/iron_ball.png',
    description: "標準的な鉄のボール。",
  );

  static final ItemData vampireOrb = ItemData(
    name: "Vampire Orb",
    rarity: Rarity.unique,
    tags: [GameTag.physical, GameTag.projectile],
    stats: const BaseStats(damage: 15, speed: 320),
    effects: [LifeLeechEffect()],
    assetPath: 'items/vampire_orb.png',
    description: "敵を倒すとコアのHPを回復する。",
  );

  static final ItemData explosiveOrb = ItemData(
    name: "Blast Orb",
    rarity: Rarity.common, // Or Rare
    tags: [GameTag.fire, GameTag.aoe],
    stats: const BaseStats(damage: 8, speed: 280),
    effects: [ExplosionEffect()],
    assetPath: 'items/blast_orb.png',
    description: "ヒット時に爆発し、周囲に火属性ダメージを与える。",
  );
}
