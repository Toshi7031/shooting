import 'package:flutter/material.dart';
import '../game_state.dart';
import 'item_effect.dart';

/// Tabula Rasa効果: 全タグのレベル+1（シンプルなボーナス）
class TabulaRasaEffect extends ItemEffect {
  @override
  bool get isGlobal => true;

  @override
  void onEquip(dynamic core) {
    debugPrint("Tabula Rasa: Equipped! All tag levels +1");
    final state = GameState();
    for (final tag in state.tagMultipliers.keys) {
      state.tagMultipliers[tag] = (state.tagMultipliers[tag] ?? 1.0) + 0.2;
    }
  }

  @override
  void onUnequip(dynamic core) {
    debugPrint("Tabula Rasa: Unequipped! Removing tag bonuses");
    final state = GameState();
    for (final tag in state.tagMultipliers.keys) {
      state.tagMultipliers[tag] = (state.tagMultipliers[tag] ?? 1.2) - 0.2;
    }
  }
}
