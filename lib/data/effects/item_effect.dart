import '../../components/ball.dart';
import '../../components/block.dart';

/// エフェクトの基底クラス
/// BallsとArtifactsの両方で使用される
abstract class ItemEffect {
  /// このエフェクトがグローバル（全ボールに適用）かどうか
  bool get isGlobal => false;

  /// ボールが敵にヒットした時
  void onHit(Ball ball, BlockEnemy block) {}

  /// ボールが敵を倒した時
  void onKill(Ball ball, BlockEnemy block) {}

  /// アーティファクト装備時（Coreに装備された時）
  void onEquip(dynamic core) {}

  /// アーティファクト解除時
  void onUnequip(dynamic core) {}

  /// 毎フレーム呼び出し（持続効果用）
  void onTick(dynamic core, double dt) {}
}
