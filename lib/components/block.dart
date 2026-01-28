import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../data/game_state.dart';
import '../data/enemy_mod.dart';
import '../systems/particle_manager.dart';
import '../systems/audio_manager.dart';

class BlockEnemy extends PositionComponent with HasGameReference {
  double hp = 10;
  final double damageStart = 10;
  double damageMultiplier = 1.0; // コアへの自爆ダメージ倍率
  double armorMultiplier = 1.0; // 被ダメージ倍率（低いほど硬い）

  /// このエネミーが持つMod
  final List<EnemyMod> mods = [];

  /// Rare敵かどうか（Mod付き）
  bool get isRare => mods.isNotEmpty;

  BlockEnemy({required Vector2 position, List<EnemyMod>? initialMods})
      : super(
            position: position, size: Vector2(32, 16), anchor: Anchor.center) {
    // HP Scaling
    double waveMultiplier = 1.0 + (GameState().currentWave - 1) * 0.2;
    hp = 10.0 * waveMultiplier;

    // Modを適用
    if (initialMods != null) {
      mods.addAll(initialMods);
      _applyMods();
    }
  }

  /// Modの効果を適用
  void _applyMods() {
    for (final mod in mods) {
      switch (mod.type) {
        case EnemyModType.haste:
          // 速度はvelocity設定後に適用される
          break;
        case EnemyModType.giant:
          size = size * mod.value;
          hp *= mod.value;
          break;
        case EnemyModType.enraged:
          damageMultiplier *= mod.value;
          break;
        case EnemyModType.armored:
          armorMultiplier *= mod.value;
          break;
      }
    }
  }

  /// 攻撃速度倍率を取得（haste mod用）
  double get speedMultiplier {
    double multiplier = 1.0;
    for (final mod in mods) {
      if (mod.type == EnemyModType.haste) {
        multiplier *= mod.value;
      }
    }
    return multiplier;
  }

  Vector2 velocity = Vector2.zero();

  @override
  void update(double dt) {
    super.update(dt);
    if (GameState().isPaused) return;

    position += velocity * speedMultiplier * dt;

    // Rotate block perpendicular to movement direction (long side faces core)
    if (velocity.length2 > 0) {
      angle = math.atan2(velocity.y, velocity.x) + math.pi / 2;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Procedural Pixel Art: Brick
    // Rare敵は黄色っぽい色で光る
    final baseColor =
        isRare ? const Color(0xFFCCAA33) : const Color(0xFFCC3333);
    final paintBase = Paint()..color = baseColor;
    final paintMortar = Paint()
      ..color = isRare ? const Color(0xFF665500) : const Color(0xFF660000);
    final paintHighlight = Paint()
      ..color = isRare ? const Color(0xFFFFDD66) : const Color(0xFFFF6666);

    final rect = size.toRect();
    canvas.drawRect(rect, paintBase);

    // Rare敵には輝くボーダーを追加
    if (isRare) {
      final glowPaint = Paint()
        ..color = Colors.yellow.withAlpha(100)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRect(rect.inflate(2), glowPaint);
    }

    // Borders (Mortar)
    final double pixel = 2.0;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, pixel), paintHighlight); // Top Light
    canvas.drawRect(Rect.fromLTWH(0, size.y - pixel, size.x, pixel),
        paintMortar); // Bottom Shadow
    canvas.drawRect(
        Rect.fromLTWH(0, 0, pixel, size.y), paintHighlight); // Left Light
    canvas.drawRect(Rect.fromLTWH(size.x - pixel, 0, pixel, size.y),
        paintMortar); // Right Shadow

    // Inner Detail (Cracks?)
    if (hp < damageStart / 2) {
      // Drack crack
      canvas.drawLine(Offset(size.x / 2, size.y / 4),
          Offset(size.x / 4, size.y * 0.75), paintMortar..strokeWidth = 2);
    }
  }

  void takeDamage(double damage) {
    // armorMultiplierを適用（低いほどダメージ軽減）
    final actualDamage = damage * armorMultiplier;
    hp -= actualDamage;
    if (hp <= 0) {
      die();
    }
  }

  void die() {
    // Spawn particles
    game.add(ParticleHelper.spawnBlockExplosion(position.clone()));
    AudioManager().playExplosion();

    removeFromParent();
    // Drop XP/Gold
    final state = GameState();
    final goldAmount = (10 * state.goldMultiplier).toInt();
    state.addRewards(gold: goldAmount, xp: 20);
    state.enemyKilled();
  }
}
