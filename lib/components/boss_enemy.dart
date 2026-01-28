import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'block.dart';
import '../data/game_state.dart';
import '../data/enemy_mod.dart';
import '../systems/audio_manager.dart';
import '../systems/particle_manager.dart';

class BossEnemy extends BlockEnemy {
  BossEnemy({required super.position, List<EnemyMod>? initialMods}) {
    size = Vector2(128, 64); // Larger size
    double waveHealth = (GameState().currentWave * 2000)
        .toDouble(); // Boss HP Scaling (20x boost)
    hp = waveHealth;

    // Modを適用
    if (initialMods != null) {
      mods.addAll(initialMods);
      _applyBossMods();
    }
  }

  void _applyBossMods() {
    for (final mod in mods) {
      switch (mod.type) {
        case EnemyModType.haste:
          // 速度は親クラスで処理
          break;
        case EnemyModType.giant:
          size *= mod.value;
          hp *= mod.value;
          break;
        case EnemyModType.enraged:
          damageMultiplier *= mod.value;
          break;
        case EnemyModType.armored:
          armorMultiplier *= mod.value;
          break;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    // Custom Boss Render
    // Procedural Pixel Art: Big Skull / Fortress

    final w = size.x;
    final h = size.y;

    // Modに応じて色を変更
    Color baseColor = Colors.purple[800]!;
    if (mods.any((m) => m.type == EnemyModType.enraged)) {
      baseColor = Colors.red[900]!;
    } else if (mods.any((m) => m.type == EnemyModType.armored)) {
      baseColor = Colors.blueGrey[700]!;
    } else if (mods.any((m) => m.type == EnemyModType.haste)) {
      baseColor = Colors.cyan[800]!;
    }

    final paintBase = Paint()..color = baseColor;
    final paintHighlight = Paint()..color = Colors.purpleAccent;
    final paintEye = Paint()..color = Colors.redAccent;

    canvas.drawRect(size.toRect(), paintBase);

    // Eyes
    canvas.drawRect(
        Rect.fromLTWH(w * 0.2, h * 0.3, w * 0.2, h * 0.3), paintEye);
    canvas.drawRect(
        Rect.fromLTWH(w * 0.6, h * 0.3, w * 0.2, h * 0.3), paintEye);

    // Teeth
    for (int i = 0; i < 5; i++) {
      canvas.drawRect(
          Rect.fromLTWH(w * 0.2 + (i * w * 0.12), h * 0.7, w * 0.1, h * 0.2),
          paintHighlight);
    }

    // Border
    final paintBorder = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawRect(size.toRect(), paintBorder);

    // Rare glow for modded boss
    if (isRare) {
      final glowPaint = Paint()
        ..color = Colors.yellow.withAlpha(100)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6;
      canvas.drawRect(
        Rect.fromLTWH(-3, -3, size.x + 6, size.y + 6),
        glowPaint,
      );
    }
  }

  @override
  void die() {
    // Boss Death
    AudioManager()
        .playLevelUp(); // Victory sound? Using LevelUp as placeholder for big event
    game.add(ParticleHelper.spawnBlockExplosion(position));
    game.add(ParticleHelper.spawnBlockExplosion(position + Vector2(20, 20)));
    game.add(ParticleHelper.spawnBlockExplosion(position - Vector2(20, 20)));

    removeFromParent();

    // Huge Rewards
    final state = GameState();
    final goldAmount = (500 * state.goldMultiplier).toInt();
    state.addGold(goldAmount);
    state.addXp(200);
    state.enemyKilled(); // Triggers next wave
  }
}
