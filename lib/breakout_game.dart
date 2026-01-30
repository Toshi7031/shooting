import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'components/core.dart';
import 'components/ball.dart';
import 'components/block.dart';
import 'components/boss_enemy.dart';
import 'systems/collision_system.dart';
import 'systems/spawn_system.dart';
import 'data/game_state.dart';
import 'data/constants.dart';

class BreakoutGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    // Add Core
    final core = Core();
    add(core);

    // Add initial ball for testing (using size which is now canvas size)
    add(Ball(position: Vector2(size.x / 2, size.y / 2)));

    // Add Systems
    add(SpawnSystem());
    add(CollisionSystem());

    // Start paused until user interaction
    paused = true;
    GameState().addListener(_onGameStateChanged);
  }

  void _onGameStateChanged() {
    if (GameState().isGameActive && paused) {
      paused = false;
    }
  }

  /// ゲームをリセット（全コンポーネントを削除して再初期化）
  void resetGame() {
    // 全ての敵、ボール、パーティクルを削除
    final toRemove = <Component>[];
    for (final child in children) {
      if (child is BlockEnemy || child is BossEnemy || child is Ball || child is Core || child is ParticleSystemComponent) {
        toRemove.add(child);
      }
    }
    for (final c in toRemove) {
      c.removeFromParent();
    }

    // Coreを再追加
    add(Core());

    // 初期ボールを追加
    add(Ball(position: Vector2(size.x / 2, size.y / 2)));
  }

  @override
  void onRemove() {
    GameState().removeListener(_onGameStateChanged);
    super.onRemove();
  }

  @override
  Color backgroundColor() => GameColors.background;
}
