import 'package:flutter_test/flutter_test.dart';
import 'package:circle_breaker_survivors/data/game_state.dart';

void main() {
  group('GameState Headhunter Mod Limit Tests', () {
    late GameState gameState;

    setUp(() {
      gameState = GameState();
      gameState.reset();
    });

    test('Limit mods of same type to 5', () {
      // Add 5 mods of same type
      for (int i = 0; i < 5; i++) {
        gameState.addStolenMod('haste', 1.0, 10.0);
      }
      expect(gameState.stolenMods.length, 5);
      expect(gameState.stolenMods.every((m) => m.type == 'haste'), true);

      // Add 6th mod
      gameState.addStolenMod('haste', 1.0, 10.0);

      // Should still be 5
      expect(gameState.stolenMods.length, 5);
      expect(gameState.stolenMods.every((m) => m.type == 'haste'), true);
    });

    test('Oldest mod is removed when limit exceeded', () {
      // Add 5 mods with distinct remaining times to identify them
      // Note: addStolenMod(type, value, duration)
      // 1st: duration 10
      // 2nd: duration 20
      // ...
      // 5th: duration 50
      for (int i = 0; i < 5; i++) {
        gameState.addStolenMod('haste', 1.0, (i + 1) * 10.0);
      }

      // First added mod should be at index 0 and have duration 10
      expect(gameState.stolenMods.first.remainingTime, 10.0);

      // Add 6th mod
      gameState.addStolenMod('haste', 1.0, 60.0);

      // Size should be 5
      expect(gameState.stolenMods.length, 5);

      // Oldest (duration 10) should be gone.
      // New first should be duration 20.
      expect(gameState.stolenMods.first.remainingTime, 20.0);

      // Last should be new one (duration 60)
      expect(gameState.stolenMods.last.remainingTime, 60.0);
    });

    test('Different mod types are counted separately', () {
      // Add 5 'haste' mods
      for (int i = 0; i < 5; i++) {
        gameState.addStolenMod('haste', 1.0, 10.0);
      }

      // Add 1 'giant' mod
      gameState.addStolenMod('giant', 1.0, 10.0);

      // Total should be 6
      expect(gameState.stolenMods.length, 6);
      expect(gameState.stolenMods.where((m) => m.type == 'haste').length, 5);
      expect(gameState.stolenMods.where((m) => m.type == 'giant').length, 1);
    });
  });
}
