import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../data/game_state.dart';
import '../data/models/enemy_mod.dart';
import '../systems/particle_manager.dart';
import '../systems/audio_manager.dart';

class BlockEnemy extends PositionComponent with HasGameReference {
  double hp = 10;
  final double damageStart = 10;
  double damageMultiplier = 1.0; // コアへの自爆ダメージ倍率
  double armorMultiplier = 1.0; // 被ダメージ倍率（低いほど硬い）

  // cos/sinキャッシュ（衝突判定の高速化用）
  double _cachedCos = 1.0;
  double _cachedSin = 0.0;
  double _cachedAngle = 0.0;

  double get cachedCos => _cachedCos;
  double get cachedSin => _cachedSin;

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
      final newAngle = math.atan2(velocity.y, velocity.x) + math.pi / 2;
      if (newAngle != _cachedAngle) {
        angle = newAngle;
        _cachedAngle = newAngle;
        _cachedCos = math.cos(-newAngle);
        _cachedSin = math.sin(-newAngle);
      }
    }
  }

  // 静的Paintキャッシュ（毎フレームの生成を回避）
  static final Paint _paintNormal = Paint()..color = const Color(0xFFCC3333);
  static final Paint _paintRare = Paint()..color = const Color(0xFFCCAA33);
  static final Paint _paintRareBorder = Paint()
    ..color = const Color(0xFFFFDD66)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  @override
  void render(Canvas canvas) {
    // 軽量描画: 単純な矩形のみ
    final rect = size.toRect();
    canvas.drawRect(rect, isRare ? _paintRare : _paintNormal);

    // Rare敵のボーダー（軽量版）
    if (isRare) {
      canvas.drawRect(rect, _paintRareBorder);
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
    final state = GameState();

    // パーティクルは敵が少ない時のみ（パフォーマンス対策）
    if (state.enemiesAlive < 50) {
      game.add(ParticleHelper.spawnBlockExplosion(position.clone()));
      AudioManager().playExplosion();
    } else if (state.enemiesAlive % 10 == 0) {
      // 多い時は10体に1回だけ音を鳴らす
      AudioManager().playExplosion();
    }

    removeFromParent();
    // Drop XP/Gold
    final goldAmount = (10 * state.goldMultiplier).toInt();
    state.addRewards(gold: goldAmount, xp: 20);
    state.enemyKilled();
  }
}
