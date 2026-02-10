import 'package:flutter/material.dart';
import '../game_state.dart';
import '../../components/ball.dart';
import '../../components/block.dart';
import 'item_effect.dart';

class ShieldLeechEffect extends ItemEffect {
  @override
  void onKill(Ball ball, BlockEnemy block) {
    final state = GameState();
    if (state.coreHp >= state.maxCoreHp) {
        state.addShield(1.0);
        debugPrint("ShieldLeech: Added Shield! Current: ${state.shield}");
    } else {
        state.healCore(1.0);
        debugPrint("ShieldLeech: Healed Core! HP: ${state.coreHp}");
    }
  }
}
