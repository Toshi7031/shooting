import 'package:flutter/material.dart';
import '../game_state.dart';
import 'item_effect.dart';

/// Lucky Charm効果: ゴールドドロップ+50%
class LuckyCharmEffect extends ItemEffect {
  @override
  bool get isGlobal => true;

  @override
  void onEquip(dynamic core) {
    GameState().goldMultiplier += 0.5;
    debugPrint("Lucky Charm: Gold +50%!");
  }

  @override
  void onUnequip(dynamic core) {
    GameState().goldMultiplier -= 0.5;
    debugPrint("Lucky Charm: Removed gold bonus");
  }
}
