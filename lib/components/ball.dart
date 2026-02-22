import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../systems/pool_manager.dart';
import '../data/game_state.dart';
import '../data/models/item_data.dart';
import '../data/models/tags.dart';
import '../data/models/rarity.dart';
import 'package:circle_breaker_survivors/breakout_game.dart';
import 'block.dart';
import 'core.dart';

class Ball extends CircleComponent with HasGameReference<BreakoutGame> {
  Vector2 velocity = Vector2(100, -200); // Initial velocity
  // final double baseSpeed = 300.0; // Replaced by ItemData.stats.speed
  final double maxStepPerFrame = 16.0; // Less than block size (32 or 16)

  late double baseDamage;
  final Set<String> tags = {};
  int pierceCount = 0;
  int maxBounces = 0;
  int currentBounces = 0;
  final List<BlockEnemy> hitBlocks = []; // Track hits for pierce

  ItemData itemData; // Changed from 'data' to 'itemData' and made non-final

  // Constructor now accepts optional ItemData, defaults to Basic
  Ball({required Vector2 position, required this.itemData})
      : super(
            position: position,
            radius: 10, // Changed from size: Vector2.all(10)
            anchor: Anchor.center,
            paint: Paint()..color = Colors.white) {
    // Added paint
    _init();
  }

  void _init() {
    final state = GameState();
    double multiplier = 1.0;

    pierceCount = state.pierceCount;
    maxBounces = state.maxBounces;

    // Clear existing tags before loading new ones
    tags.clear();
    // Load Tags from ItemData
    for (final t in itemData.tags) {
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

    baseDamage = itemData.stats.damage * multiplier;
  }

  double get damage {
    double efficiency = 0.1;
    if (itemData.name == 'Juggernaut Sphere') {
      efficiency = 0.3;
    }
    return baseDamage * (1.0 + currentBounces * efficiency);
  }

  void onHit(BlockEnemy block) {
    // 自身のエフェクトを実行
    for (final effect in itemData.effects) {
      effect.onHit(this, block);
    }

    // Coreのグローバルエフェクトも実行
    _triggerGlobalEffectsOnHit(block);
  }

  void onKill(BlockEnemy block) {
    // 自身のエフェクトを実行
    for (final effect in itemData.effects) {
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

  void reset(Vector2 position, ItemData newItemData) {
    this.position.setFrom(position);
    itemData = newItemData;
    velocity = Vector2.zero();
    currentBounces = 0;
    hitBlocks.clear();
    _trailIndex = 0;
    _trailCount = 0;
    for (int i = 0; i < _trailLength; i++) {
      _trail[i] = null;
    }
    isCounted = true;
    _init();
  }

  void release() {
    GamePools().ballPool.returnToPool(this);
  }

  bool isCounted = true;

  // リングバッファでTrailを管理（固定長、メモリ効率向上）
  static const int _trailLength = 10;
  final List<Vector2?> _trail = List.filled(_trailLength, null);
  int _trailIndex = 0;
  int _trailCount = 0;

  @override
  void update(double dt) {
    if (GameState().isPaused) return;
    super.update(dt);
    // Enforce Speed from Stats
    double speed = velocity.length;
    double targetSpeed = itemData.stats.speed;
    // Optional: Smoothly adjust speed or just clamp?
    // For now, just ensure it doesn't drift?
    // Actually, velocity shouldn't change magnitude unless friction.
    // But let's ensure we are moving at item speed.
    if (speed > 0) {
      velocity = velocity.normalized() * targetSpeed;
    }

    // Giant Mod: 2.0x Size
    final giantMult = GameState().getStolenModMultiplier('giant');
    size = Vector2.all(10.0 * giantMult); // Base size 10

    // Speed Cap / Tunneling Prevention
    double dist = velocity.length * dt;
    if (dist > maxStepPerFrame) {
      velocity.scale(maxStepPerFrame / dist);
    }

    position += velocity * dt;

    // Update Trail (リングバッファ) - 敵が多い時はスキップ
    if (GameState().enemiesAlive < 100) {
      _trail[_trailIndex] = position.clone();
      _trailIndex = (_trailIndex + 1) % _trailLength;
      if (_trailCount < _trailLength) _trailCount++;
    }
  }

  Sprite? _sprite;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    if (itemData.assetPath != null) {
      try {
        _sprite = await game.loadSprite(itemData.assetPath!);
      } catch (e) {
        debugPrint("Error loading sprite for ${itemData.name}: $e");
        // _sprite remains null, so fallback render will be used.
      }
    }
  }

  // 静的Paintキャッシュ
  static final Paint _ballPaint = Paint();

  @override
  void render(Canvas canvas) {
    // Trailは敵が少ない時のみ描画
    if (GameState().enemiesAlive < 100 && _trailCount > 0) {
      for (int i = 0; i < _trailCount; i++) {
        final idx =
            (_trailIndex - _trailCount + i + _trailLength) % _trailLength;
        final trailPos = _trail[idx];
        if (trailPos == null) continue;

        final localPos = (trailPos - position).toOffset();
        final alpha = (i / _trailLength * 255).toInt();
        _ballPaint.color = itemData.rarity.color.withAlpha(alpha);

        canvas.drawCircle(localPos + Offset(size.x / 2, size.y / 2),
            size.x / 2 * (i / _trailLength), _ballPaint);
      }
    }

    if (_sprite != null) {
      _sprite!.render(canvas, size: size);
    } else {
      // Fallback Draw Ball
      _ballPaint.color = itemData.rarity.color;
      canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, _ballPaint);
    }
  }

  @override
  void onMount() {
    super.onMount();
    GameState().updateFieldBallCount(1);
  }

  @override
  void onRemove() {
    if (isCounted) {
      GameState().updateFieldBallCount(-1);
    }
    super.onRemove();
  }
}
