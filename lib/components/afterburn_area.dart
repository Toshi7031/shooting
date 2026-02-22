import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../breakout_game.dart';
import 'block.dart';
import '../data/game_state.dart';

class AfterburnArea extends PositionComponent
    with HasGameReference<BreakoutGame> {
  final double radius;
  final double duration;
  final double damagePerTick;
  final double tickInterval = 0.5;

  double _timer = 0.0;
  double _tickTimer = 0.0;

  AfterburnArea({
    required Vector2 position,
    this.radius = 50.0,
    this.duration = 3.0,
    this.damagePerTick = 2.0,
  }) : super(
            position: position,
            size: Vector2.all(radius * 2),
            anchor: Anchor.center);

  @override
  void update(double dt) {
    if (GameState().isPaused) return;
    super.update(dt);

    _timer += dt;
    if (_timer >= duration) {
      removeFromParent();
      return;
    }

    _tickTimer += dt;
    if (_tickTimer >= tickInterval) {
      _tickTimer = 0;
      _applyDamage();
    }
  }

  void _applyDamage() {
    final enemies = game.children.whereType<BlockEnemy>();
    for (final enemy in enemies) {
      // Simple distance check
      if (enemy.absolutePosition.distanceTo(absolutePosition) <= radius) {
        enemy.takeDamage(damagePerTick);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.deepOrange.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), radius, paint);
  }
}
