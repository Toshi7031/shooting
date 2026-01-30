import 'package:flutter/material.dart';
import '../game_state.dart';
import '../../components/ball.dart';
import '../../components/block.dart';
import 'item_effect.dart';

/// ライフリーチ効果: 敵を倒すとHPを回復
class LifeLeechEffect extends ItemEffect {
  @override
  void onKill(Ball ball, BlockEnemy block) {
    GameState().healCore(1.0);
    debugPrint("LifeLeech: Healed Core! HP: ${GameState().coreHp}");
  }
}
