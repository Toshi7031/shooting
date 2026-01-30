import 'package:flutter/material.dart';
import '../game_state.dart';
import '../../components/ball.dart';
import '../../components/block.dart';
import 'item_effect.dart';

/// Soul Eater効果: 敵を倒すとHP+1回復
class SoulEaterEffect extends ItemEffect {
  @override
  bool get isGlobal => true;

  @override
  void onKill(Ball ball, BlockEnemy block) {
    final state = GameState();
    if (state.coreHp < state.maxCoreHp) {
      state.healCore(1);
      debugPrint("Soul Eater: +1 HP on kill");
    }
  }
}
