import 'package:flutter/material.dart';
import '../../components/ball.dart';
import '../../components/block.dart';
import '../../systems/particle_manager.dart';
import 'item_effect.dart';

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
