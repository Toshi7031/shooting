import '../models/artifact_data.dart';
import '../models/rarity.dart';
import '../effects/headhunter_effect.dart';
import '../effects/tabula_rasa_effect.dart';
import '../effects/soul_eater_effect.dart';
import '../effects/berserkers_rage_effect.dart';
import '../effects/lucky_charm_effect.dart';

/// アーティファクトのリポジトリ
class ArtifactRepository {
  static final ArtifactData headhunter = ArtifactData(
    name: "Headhunter",
    description: "Rare敵を倒すと、そのModを5秒間盗む。",
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
