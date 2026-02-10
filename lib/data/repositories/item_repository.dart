import '../models/item_data.dart';
import '../models/rarity.dart';
import '../models/tags.dart';
import '../effects/life_leech_effect.dart';
import '../effects/explosion_effect.dart';
import '../effects/stun_effect.dart';
import '../effects/shield_leech_effect.dart';
import '../effects/supernova_explosion_effect.dart';

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

  // Tier 2 Balls
  static final ItemData juggernautSphere = ItemData(
    name: "Juggernaut Sphere",
    rarity: Rarity.legendary,
    tags: [GameTag.physical, GameTag.projectile],
    stats: const BaseStats(damage: 1500, speed: 250),
    effects: [StunEffect()],
    assetPath: 'items/juggernaut.png', // Placeholder
    description: "覚醒した物理弾。圧倒的な質量で敵を粉砕し、スタンさせる。",
  );

  static final ItemData bloodMoon = ItemData(
    name: "Blood Moon",
    rarity: Rarity.legendary,
    tags: [GameTag.physical, GameTag.projectile],
    stats: const BaseStats(damage: 2250, speed: 280),
    effects: [ShieldLeechEffect()],
    assetPath: 'items/blood_moon.png', // Placeholder
    description: "覚醒した吸血弾。過剰回復分をシールドに変換する。",
  );

  static final ItemData supernova = ItemData(
    name: "Supernova",
    rarity: Rarity.legendary,
    tags: [GameTag.fire, GameTag.aoe],
    stats: const BaseStats(damage: 1200, speed: 300),
    effects: [SupernovaExplosionEffect()],
    assetPath: 'items/supernova.png', // Placeholder
    description: "覚醒した爆発弾。広範囲を焼き尽くす。",
  );
}
