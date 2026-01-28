import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/core.dart';
import 'components/ball.dart';
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

  @override
  void onRemove() {
    GameState().removeListener(_onGameStateChanged);
    super.onRemove();
  }

  @override
  Color backgroundColor() => GameColors.background;
}
