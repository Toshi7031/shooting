import '../rarity.dart';
import '../item_effect.dart';
import '../enemy_mod.dart';
import '../game_state.dart';
import '../../components/ball.dart';
import '../../components/block.dart';
import 'package:flutter/material.dart';

/// アーティファクト（パッシブ装備品）のデータ
class ArtifactData {
  final String name;
  final String description;
  final Rarity rarity;
  final List<ItemEffect> effects;
  final String? iconPath;

  const ArtifactData({
    required this.name,
    required this.description,
    required this.rarity,
    this.effects = const [],
    this.iconPath,
  });
}

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
      switch (mod.type) {
        case EnemyModType.haste:
          state.addStolenMod('haste', mod.value, 20.0);
          debugPrint(
              "  -> Attack Speed +${((mod.value - 1) * 100).toInt()}% for 20s");
          break;
        case EnemyModType.giant:
          // 巨大化は意味がないので、ダメージボーナスに変換
          state.addStolenMod('damage', mod.value * 0.5, 20.0);
          debugPrint(
              "  -> Damage +${((mod.value * 0.5 - 1) * 100).toInt()}% for 20s");
          break;
        case EnemyModType.enraged:
          state.addStolenMod('damage', mod.value, 20.0);
          debugPrint(
              "  -> Damage +${((mod.value - 1) * 100).toInt()}% for 20s");
          break;
        case EnemyModType.armored:
          // アーマーはCore耐久力として適用
          state.addStolenMod('armor', mod.value, 20.0);
          debugPrint(
              "  -> Damage Reduction +${((1 - mod.value) * 100).toInt()}% for 20s");
          break;
      }
    }
  }
}

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

/// アーティファクトのリポジトリ
class ArtifactRepository {
  static final ArtifactData headhunter = ArtifactData(
    name: "Headhunter",
    description: "Rare敵を倒すと、そのModを20秒間盗む。",
    rarity: Rarity.unique,
    effects: [HeadhunterEffect()],
  );

  static final ArtifactData tabulaRasa = ArtifactData(
    name: "Tabula Rasa",
    description: "すべてのダメージタグに+20%ボーナス。",
    rarity: Rarity.unique,
    effects: [TabulaRasaEffect()],
  );

  static final ArtifactData soulEater = ArtifactData(
    name: "Soul Eater",
    description: "敵を倒すとHP+1回復。",
    rarity: Rarity.rare,
    effects: [SoulEaterEffect()],
  );

  static final ArtifactData berserkersRage = ArtifactData(
    name: "Berserker's Rage",
    description: "HP50%以下でダメージ+50%。",
    rarity: Rarity.rare,
    effects: [BerserkersRageEffect()],
  );

  static final ArtifactData luckyCharm = ArtifactData(
    name: "Lucky Charm",
    description: "ゴールドドロップ+50%。",
    rarity: Rarity.rare,
    effects: [LuckyCharmEffect()],
  );

  /// 全てのアーティファクト
  static List<ArtifactData> get all => [
        headhunter,
        tabulaRasa,
        soulEater,
        berserkersRage,
        luckyCharm,
      ];
}
