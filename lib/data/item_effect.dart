import '../components/ball.dart';
import '../components/block.dart';
import 'game_state.dart';
import 'package:flutter/material.dart';
import '../systems/particle_manager.dart';

// Forward declaration for Core (will be imported properly when needed)
// Core is imported conditionally to avoid circular dependency

/// エフェクトの基底クラス
/// BallsとArtifactsの両方で使用される
abstract class ItemEffect {
  /// このエフェクトがグローバル（全ボールに適用）かどうか
  bool get isGlobal => false;

  /// ボールが敵にヒットした時
  void onHit(Ball ball, BlockEnemy block) {}

  /// ボールが敵を倒した時
  void onKill(Ball ball, BlockEnemy block) {}

  /// アーティファクト装備時（Coreに装備された時）
  void onEquip(dynamic core) {}

  /// アーティファクト解除時
  void onUnequip(dynamic core) {}

  /// 毎フレーム呼び出し（持続効果用）
  void onTick(dynamic core, double dt) {}
}

/// ライフリーチ効果: 敵を倒すとHPを回復
class LifeLeechEffect extends ItemEffect {
  @override
  void onKill(Ball ball, BlockEnemy block) {
    GameState().healCore(1.0);
    debugPrint("LifeLeech: Healed Core! HP: ${GameState().coreHp}");
  }
}

/// 爆発効果: ヒット時に範囲ダメージ
class ExplosionEffect extends ItemEffect {
  @override
  void onHit(Ball ball, BlockEnemy block) {
    debugPrint("ExplosionEffect: BOOM on hit!");

    final explosionRadius = 50.0;
    final damage = 2.0;

    final targets = ball.game.children.whereType<BlockEnemy>();
    for (final target in targets) {
      if (target == block) continue;
      if (target.distance(block) < explosionRadius) {
        target.takeDamage(damage);
      }
    }

    // Visual - パーティクルと衝撃波
    final explosionPos = block.position.clone();
    ball.game.add(ParticleHelper.spawnBlockExplosion(explosionPos));
    ball.game.add(
        ParticleHelper.spawnShockwave(explosionPos, radius: explosionRadius));
  }
}
