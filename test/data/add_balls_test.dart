import 'package:flutter_test/flutter_test.dart';
import 'package:circle_breaker_survivors/data/game_state.dart';
import 'package:circle_breaker_survivors/data/repositories/item_repository.dart';

void main() {
  group('GameState Bulk Purchase Tests', () {
    late GameState gameState;

    setUp(() {
      gameState = GameState();
      gameState.reset();
    });

    test('addBalls adds correct number of balls', () {
      final initialCount = gameState.totalBalls; // Should be 3
      final initialAvailable = gameState.availableBalls; // Should be 3

      // Add 1 ball
      gameState.addBalls(ItemRepository.defaultBall, 1);
      expect(gameState.totalBalls, initialCount + 1);
      expect(gameState.availableBalls, initialAvailable + 1);

      // Add 10 balls
      gameState.addBalls(ItemRepository.defaultBall, 10);
      expect(gameState.totalBalls, initialCount + 1 + 10);
      expect(gameState.availableBalls, initialAvailable + 1 + 10);

       // Add 100 balls
      gameState.addBalls(ItemRepository.defaultBall, 100);
      expect(gameState.totalBalls, initialCount + 11 + 100);
      expect(gameState.availableBalls, initialAvailable + 11 + 100);
    });
  });
}
