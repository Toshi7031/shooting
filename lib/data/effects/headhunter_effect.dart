import 'package:flutter/material.dart';
import '../game_state.dart';
import '../../components/ball.dart';
import '../../components/block.dart';
import '../models/enemy_mod.dart';
import 'item_effect.dart';

/// Headhunter効果: Rare敵を倒すとそのModを20秒間盗む
class HeadhunterEffect extends ItemEffect {
  @override
  bool get isGlobal => true;

  @override
  void onKill(Ball ball, BlockEnemy block) {
    if (!block.isRare || block.mods.isEmpty) return;

    final state = GameState();
    for (final mod in block.mods) {
      debugPrint("Headhunter: Stole ${mod.type.label} from Rare enemy!");

      // Modに応じた一時的バフを適用
      // バランス調整: 効果時間を20秒 -> 5秒に短縮
      const duration = 5.0;

      switch (mod.type) {
        case EnemyModType.haste:
          state.addStolenMod('haste', mod.value, duration);
          debugPrint(
            "  -> Attack Speed +${((mod.value - 1) * 100).toInt()}% for ${duration}s");
          break;
        case EnemyModType.giant:
          // 巨大化は意味がないので、ダメージボーナスに変換
          state.addStolenMod('damage', mod.value * 0.5, duration);
          debugPrint(
            "  -> Damage +${((mod.value * 0.5 - 1) * 100).toInt()}% for ${duration}s");
          break;
        case EnemyModType.enraged:
          state.addStolenMod('damage', mod.value, duration);
          debugPrint(
            "  -> Damage +${((mod.value - 1) * 100).toInt()}% for ${duration}s");
          break;
        case EnemyModType.armored:
          // アーマーはCore耐久力として適用
          state.addStolenMod('armor', mod.value, duration);
          debugPrint(
            "  -> Damage Reduction +${((1 - mod.value) * 100).toInt()}% for ${duration}s");
          break;
      }
    }
  }
}
