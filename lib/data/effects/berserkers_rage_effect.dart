import 'package:flutter/material.dart';
import '../game_state.dart';
import 'item_effect.dart';

/// Berserker's Rage効果: HPが50%以下でダメージ+50%
class BerserkersRageEffect extends ItemEffect {
  @override
  bool get isGlobal => true;

  // onHit時にダメージを増加させる代わりに、GameStateに状態を保存
  @override
  void onTick(dynamic core, double dt) {
    final state = GameState();
    final isLowHp = state.coreHp <= state.maxCoreHp * 0.5;

    // Berserker状態を管理
    if (isLowHp && !state.hasBerserkBuff) {
      state.hasBerserkBuff = true;
      debugPrint("Berserker's Rage: ACTIVATED! Damage +50%");
    } else if (!isLowHp && state.hasBerserkBuff) {
      state.hasBerserkBuff = false;
      debugPrint("Berserker's Rage: Deactivated");
    }
  }

  @override
  void onUnequip(dynamic core) {
    GameState().hasBerserkBuff = false;
  }
}
