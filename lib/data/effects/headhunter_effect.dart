import 'package:flutter/material.dart';
import '../game_state.dart';
import '../../components/ball.dart';
import '../../components/block.dart';
import '../models/enemy_mod.dart';
import 'item_effect.dart';

/// Headhunter効果: Rare敵を倒すとそのModを5秒間盗む
class HeadhunterEffect extends ItemEffect {
  @override
  bool get isGlobal => true;

  @override
  void onKill(Ball ball, BlockEnemy block) {
    if (!block.isRare || block.mods.isEmpty) return;

    final state = GameState();
    for (final mod in block.mods) {
      debugPrint("Headhunter: Stole ${mod.type.label} from Rare enemy!");
      const duration = 5.0;

      switch (mod.type) {
        case EnemyModType.haste:
          state.addStolenMod('frenzy', 1.5, duration);
          debugPrint("  -> Fire Rate +50%");
          break;
        case EnemyModType.giant:
          state.addStolenMod('giant', 1.5, duration);
          debugPrint("  -> Ball Size 1.5x");
          break;
        case EnemyModType.enraged:
          state.addStolenMod('damage', 1.5, duration);
          debugPrint("  -> Global Damage +50%");
          break;
        case EnemyModType.armored:
          state.addStolenMod('armor', 0.5, duration);
          debugPrint("  -> Damage Reduction 50%");
          break;
        case EnemyModType.gravityWell:
          state.addStolenMod('slow_aura', 1.0, duration);
          debugPrint("  -> Slow Aura Active");
          break;
      }
    }
  }
}
