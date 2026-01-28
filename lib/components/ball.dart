import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../data/game_state.dart';
import '../data/item_data.dart';
import '../data/item_repository.dart'; // For default item
import '../data/tags.dart';
import '../data/rarity.dart';
import 'package:circle_breaker_survivors/breakout_game.dart';
import 'block.dart';
import 'core.dart';

class Ball extends PositionComponent with HasGameReference<BreakoutGame> {
  Vector2 velocity = Vector2(100, -200); // Initial velocity
  // final double baseSpeed = 300.0; // Replaced by ItemData.stats.speed
  final double maxStepPerFrame = 16.0; // Less than block size (32 or 16)

  late double damage;
  final Set<String> tags = {};
  int pierceCount = 0;
  int maxBounces = 0;
  int currentBounces = 0;
  final List<BlockEnemy> hitBlocks = []; // Track hits for pierce

  final ItemData data;

  // Constructor now accepts optional ItemData, defaults to Basic
  Ball({required Vector2 position, ItemData? itemData})
      : data = itemData ?? ItemRepository.defaultBall,
        super(
            position: position, size: Vector2.all(10), anchor: Anchor.center) {
    final state = GameState();
    double multiplier = 1.0;

    pierceCount = state.pierceCount;
    maxBounces = state.maxBounces;

    // Load Tags from ItemData
    for (final t in data.tags) {
      String key = '';
      switch (t) {
        case GameTag.physical:
          key = 'Physical';
          break;
        case GameTag.fire:
          key = 'Fire';
          break;
        case GameTag.cold:
          key = 'Cold';
          break;
        default:
          key = '';
      }
      if (key.isNotEmpty) tags.add(key);
    }

    // Apply Global Tag Multipliers
    for (final tag in tags) {
      multiplier *= (state.tagMultipliers[tag] ?? 1.0);
    }

    // Apply Stolen Mod damage bonus
    multiplier *= state.getStolenModMultiplier('damage');

    // Apply Berserker's Rage damage bonus
    if (state.hasBerserkBuff) {
      multiplier *= 1.5;
    }

    damage = data.stats.damage * multiplier;
  }

  void onHit(BlockEnemy block) {
    // 自身のエフェクトを実行
    for (final effect in data.effects) {
      effect.onHit(this, block);
    }

    // Coreのグローバルエフェクトも実行
    _triggerGlobalEffectsOnHit(block);
  }

  void onKill(BlockEnemy block) {
    // 自身のエフェクトを実行
    for (final effect in data.effects) {
      effect.onKill(this, block);
    }

    // Coreのグローバルエフェクトも実行
    _triggerGlobalEffectsOnKill(block);
  }

  /// Coreのグローバルエフェクトを取得してonHitを実行
  void _triggerGlobalEffectsOnHit(BlockEnemy block) {
    final core = game.children.whereType<Core>().firstOrNull;
    if (core == null) return;

    for (final effect in core.getGlobalEffects()) {
      effect.onHit(this, block);
    }
  }

  /// Coreのグローバルエフェクトを取得してonKillを実行
  void _triggerGlobalEffectsOnKill(BlockEnemy block) {
    final core = game.children.whereType<Core>().firstOrNull;
    if (core == null) return;

    for (final effect in core.getGlobalEffects()) {
      effect.onKill(this, block);
    }
  }

  void returnToCore() {
    // Return to inventory
    GameState().returnBall(); // Assuming GameState is defined elsewhere
    // Remove from world
    removeFromParent();
  }

  final List<Vector2> _trail = [];
  final int _trailLength = 10;

  @override
  void update(double dt) {
    if (GameState().isPaused) return;
    super.update(dt);
    // Enforce Speed from Stats
    double speed = velocity.length;
    double targetSpeed = data.stats.speed;
    // Optional: Smoothly adjust speed or just clamp?
    // For now, just ensure it doesn't drift?
    // Actually, velocity shouldn't change magnitude unless friction.
    // But let's ensure we are moving at item speed.
    if (speed > 0) {
      velocity = velocity.normalized() * targetSpeed;
    }

    // Speed Cap / Tunneling Prevention
    double dist = velocity.length * dt;
    if (dist > maxStepPerFrame) {
      velocity.scale(maxStepPerFrame / dist);
    }

    position += velocity * dt;

    // Update Trail
    _trail.add(position.clone());
    if (_trail.length > _trailLength) {
      _trail.removeAt(0);
    }
  }

  Sprite? _sprite;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    if (data.assetPath != null) {
      try {
        _sprite = await game.loadSprite(data.assetPath!);
      } catch (e) {
        debugPrint("Error loading sprite for ${data.name}: $e");
        // _sprite remains null, so fallback render will be used.
      }
    }
  }

  @override
  void render(Canvas canvas) {
    // Render Trail
    for (int i = 0; i < _trail.length; i++) {
      final localPos = (_trail[i] - position).toOffset();
      final alpha = (i / _trailLength * 255).toInt();

      // Trail color based on rarity?
      final color = data.rarity.color.withAlpha(alpha);
      final paint = Paint()..color = color;

      canvas.drawCircle(localPos + Offset(size.x / 2, size.y / 2),
          size.x / 2 * (i / _trailLength), paint);
    }

    if (_sprite != null) {
      _sprite!.render(canvas, size: size);
    } else {
      // Fallback Draw Ball
      final paint = Paint()..color = data.rarity.color;
      canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);
    }
  }
}
