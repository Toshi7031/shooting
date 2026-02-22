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
import 'data/models/item_data.dart';
import 'systems/pool_manager.dart';
import 'data/repositories/item_repository.dart';

class BreakoutGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    // Initialize Pools
    GamePools().init(() =>
        Ball(position: Vector2.zero(), itemData: ItemRepository.defaultBall));

    // Add Core
    final core = Core();
    add(core);

    // Add initial ball for testing (using size which is now canvas size)
    add(Ball(
        position: Vector2(size.x / 2, size.y / 2),
        itemData: ItemRepository.defaultBall));

    // Add Systems
    add(SpawnSystem());
    add(CollisionSystem());

    // Start paused until user interaction
    paused = true;
    GameState().addListener(_onGameStateChanged);

    // Register Singularity Merge Callback
    GameState().onMergeRequest = (int count, ItemData reward) {
      // Visual effects (Particles, Sound) can go here
      // State changes are handled in GameState
    };
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
      if (child is BlockEnemy ||
          child is BossEnemy ||
          child is Core ||
          child is ParticleSystemComponent) {
        toRemove.add(child);
      }
      // Ball handles its own removal via release if needed, but for hard reset we might just remove?
      // If we remove Ball without release, it's lost to GC.
      // Better to release all balls to pool.
      if (child is Ball) {
        child.release();
      }
    }
    for (final c in toRemove) {
      c.removeFromParent();
    }

    // Coreを再追加
    add(Core());

    // 初期ボールを追加
    add(Ball(
        position: Vector2(size.x / 2, size.y / 2),
        itemData: ItemRepository.defaultBall));
  }

  @override
  void onRemove() {
    GameState().removeListener(_onGameStateChanged);
    super.onRemove();
  }

  @override
  Color backgroundColor() => GameColors.background;
}
