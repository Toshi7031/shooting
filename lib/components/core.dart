import 'package:flame/components.dart';
import 'package:flutter/material.dart';
// import 'dart:math'; // For random if needed
import '../data/game_state.dart';
import '../data/effects/item_effect.dart';
import '../systems/audio_manager.dart';
import 'ball.dart';
import 'block.dart';

class Core extends PositionComponent with HasGameReference {
  Core() : super(size: Vector2.all(48), anchor: Anchor.center);

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Center Core: ScreenCenter
    position = Vector2(size.x / 2, size.y / 2);
  }

  double timer = 0;
  final double fireInterval = 0.5; // Fire every 0.1s if ammo available

  @override
  void update(double dt) {
    super.update(dt);
    final state = GameState();

    // Stolen Modsの更新
    state.updateStolenMods(dt);

    // アーティファクトのonTick処理（GameStateから取得）
    for (final artifact in state.equippedArtifacts) {
      for (final effect in artifact.effects) {
        effect.onTick(this, dt);
      }
    }

    timer += dt;

    // Stolen ModのfrenzyボーナスをfireIntervalに適用
    final frenzyBonus = state.getStolenModMultiplier('frenzy');
    double interval =
        fireInterval / (state.fireIntervalMultiplier * frenzyBonus);
    if (timer >= interval) {
      timer = 0;
      fire();
    }
  }

  /// 全てのグローバルエフェクトを取得（GameStateから）
  List<ItemEffect> getGlobalEffects() {
    final effects = <ItemEffect>[];
    for (final artifact in GameState().equippedArtifacts) {
      for (final effect in artifact.effects) {
        if (effect.isGlobal) {
          effects.add(effect);
        }
      }
    }
    return effects;
  }

  int currentLoadoutIndex = 0;

  void fire() {
    // Check GameState for ammo
    final state = GameState();
    if (state.consumeBall()) {
      // Find nearest enemy (最適化版)
      Vector2 targetDir = Vector2(0, -1); // Default UP

      // 高速化: 全敵検索ではなく、ある程度近い敵を見つけたら終了
      BlockEnemy? closest;
      double minDst = double.infinity;
      const double goodEnoughDist = 10000; // 100pxの2乗 - この距離以内なら即採用

      for (final child in game.children) {
        if (child is! BlockEnemy) continue;
        final dst = child.position.distanceToSquared(position);
        if (dst < minDst) {
          minDst = dst;
          closest = child;
          if (dst < goodEnoughDist) break; // 十分近ければ終了
        }
      }

      if (closest != null) {
        targetDir = (closest.position - position).normalized();
      } else {
        // Random if no enemies
        final r = DateTime.now().millisecondsSinceEpoch % 100 / 100;
        targetDir = Vector2(0, -1)
          ..rotate((r - 0.5) * 2); // +/- 1 radian spread
      }

      // Cycle loadout
      if (state.ballLoadout.isEmpty) return; // Should not happen given init
      // リセット時のインデックス範囲外を防ぐ
      if (currentLoadoutIndex >= state.ballLoadout.length) {
        currentLoadoutIndex = 0;
      }
      final item = state.ballLoadout[currentLoadoutIndex];
      currentLoadoutIndex =
          (currentLoadoutIndex + 1) % state.ballLoadout.length;

      final ball = Ball(
        position: position.clone(),
        itemData: item,
      );

      ball.velocity = targetDir * ball.itemData.stats.speed;

      game.add(ball);
      AudioManager().playShoot(); // Play shoot sound
    }
  }

  void takeDamage(double amount) {
    final armorMult = GameState().getStolenModMultiplier('armor');
    GameState().damageCore(amount * armorMult);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Procedural Pixel Art: Crystal
    final paintMain = Paint()..color = Colors.blue;
    final paintHighlight = Paint()..color = Colors.lightBlueAccent;
    // final paintShadow = Paint()..color = Colors.blue[900]!;

    final double w = size.x;
    final double h = size.y;
    final double pixel = 4.0; // "Big pixels"

    // Draw base diamond shape using rects (simulating pixels)
    // Center:
    canvas.drawRect(
        Rect.fromLTWH(
            w / 2 - pixel * 3, h / 2 - pixel * 5, pixel * 6, pixel * 10),
        paintMain);
    canvas.drawRect(
        Rect.fromLTWH(
            w / 2 - pixel * 5, h / 2 - pixel * 3, pixel * 10, pixel * 6),
        paintMain);

    // Highlight
    canvas.drawRect(
        Rect.fromLTWH(
            w / 2 - pixel * 1, h / 2 - pixel * 3, pixel * 2, pixel * 2),
        paintHighlight);

    // Core Pulse Effect (Border) using timer
    if ((timer * 10).toInt() % 2 == 0) {
      // Blink
      final paintBorder = Paint()
        ..color = Colors.white.withAlpha(100)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRect(size.toRect(), paintBorder);
    }
  }
}
