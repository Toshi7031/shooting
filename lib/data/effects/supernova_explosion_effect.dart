import 'package:flutter/material.dart';
import '../../components/ball.dart';
import '../../components/block.dart';
import '../../components/afterburn_area.dart';
import '../../systems/particle_manager.dart';
import 'item_effect.dart';

class SupernovaExplosionEffect extends ItemEffect {
  @override
  void onHit(Ball ball, BlockEnemy block) {
    debugPrint("Supernova: BOOM!");

    final explosionRadius = 100.0; // 2x Normal
    final damage = 10.0; // Higher damage for Tier 2

    final targets = ball.game.children.whereType<BlockEnemy>();
    for (final target in targets) {
      if (target == block) continue;
      if (target.distance(block) < explosionRadius) {
        target.takeDamage(damage);
      }
    }

    // Visuals
    final explosionPos = block.position.clone();
    ball.game.add(ParticleHelper.spawnBlockExplosion(explosionPos));
    ball.game.add(
        ParticleHelper.spawnShockwave(explosionPos, radius: explosionRadius));

    // Spawn Afterburn Area
    ball.game.add(AfterburnArea(position: explosionPos, radius: explosionRadius));
  }
}
