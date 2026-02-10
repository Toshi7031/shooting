import 'package:flutter_test/flutter_test.dart';
import 'package:flame/extensions.dart';
import 'package:circle_breaker_survivors/components/ball.dart';
import 'package:circle_breaker_survivors/data/models/item_data.dart';
import 'package:circle_breaker_survivors/data/models/rarity.dart';
import 'package:circle_breaker_survivors/data/models/tags.dart';
import 'package:circle_breaker_survivors/data/game_state.dart';

void main() {
  test('Kinetic Charge Damage Calculation', () {
    // Setup GameState
    final state = GameState();
    state.reset();

    // Create a dummy ItemData
    final itemData = ItemData(
      name: 'Test Ball',
      rarity: Rarity.common,
      tags: [GameTag.physical],
      stats: BaseStats(damage: 10, speed: 100),
      description: 'Test',
    );

    // Create Ball
    final ball = Ball(position: Vector2.zero(), itemData: itemData);

    // Check initial damage
    // Base 10 * 1.0 (state) = 10.
    // Current bounces 0.
    // Damage = 10 * (1.0 + 0 * 0.1) = 10.
    expect(ball.damage, 10.0);

    // Simulate 1 bounce
    ball.currentBounces = 1;
    // Damage = 10 * (1.1) = 11.
    expect(ball.damage, 11.0);

    // Simulate 5 bounces
    ball.currentBounces = 5;
    // Damage = 10 * (1.5) = 15.
    expect(ball.damage, 15.0);
  });

  test('Juggernaut Sphere Kinetic Charge Efficiency', () {
    final state = GameState();
    state.reset();

    final juggernaut = ItemData(
      name: 'Juggernaut Sphere',
      rarity: Rarity.rare,
      tags: [GameTag.physical],
      stats: BaseStats(damage: 20, speed: 100),
      description: 'Test Juggernaut',
    );

    final ball = Ball(position: Vector2.zero(), itemData: juggernaut);

    // Base 20.
    // Efficiency 0.3.
    // 0 bounces: 20.
    expect(ball.damage, 20.0);

    // 1 bounce: 20 * (1 + 0.3) = 26.
    ball.currentBounces = 1;
    expect(ball.damage, 26.0);

    // 2 bounces: 20 * (1 + 0.6) = 32.
    ball.currentBounces = 2;
    expect(ball.damage, 32.0);
  });
}
