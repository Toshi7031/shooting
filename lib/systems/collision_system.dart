import 'package:flame/components.dart';
import '../components/ball.dart';
import '../components/block.dart';
import 'audio_manager.dart';
import 'spatial_grid.dart';
import 'dart:math';
import '../components/core.dart';
import 'package:circle_breaker_survivors/breakout_game.dart';

class CollisionSystem extends Component with HasGameReference<BreakoutGame> {
  // Grid cell size 100 covers ~3 blocks (32px) wide.
  final SpatialGrid _grid = SpatialGrid(cellSize: 100);

  // 再利用可能なリスト（GC削減）
  final List<Ball> _ballsCache = [];
  final List<BlockEnemy> _blocksCache = [];
  final Set<BlockEnemy> _currentCollisions = {};

  @override
  void update(double dt) {
    super.update(dt);

    // キャッシュリストをクリアして再利用（新しいリスト生成を回避）
    _ballsCache.clear();
    _blocksCache.clear();

    Core? core;
    for (final child in game.children) {
      if (child is Ball) {
        _ballsCache.add(child);
      } else if (child is BlockEnemy) {
        _blocksCache.add(child);
      } else if (child is Core) {
        core = child;
      }
    }

    if (core == null) return;

    // 1. Rebuild Grid
    _grid.clear();
    for (final block in _blocksCache) {
      _grid.insert(block);
    }

    // 2. Process Balls
    for (final ball in _ballsCache) {
      // Ball vs Screen Walls
      bool hitWall = false;
      bool hitVertical = false; // Left/Right
      bool hitHorizontal = false; // Top/Bottom

      if (ball.position.x <= 0 && ball.velocity.x < 0) {
        hitWall = true;
        hitVertical = true;
      } else if (ball.position.x >= game.size.x && ball.velocity.x > 0) {
        hitWall = true;
        hitVertical = true;
      }

      if (ball.position.y <= 0 && ball.velocity.y < 0) {
        hitWall = true;
        hitHorizontal = true;
      } else if (ball.position.y >= game.size.y && ball.velocity.y > 0) {
        hitWall = true;
        hitHorizontal = true;
      }

      if (hitWall) {
        if (ball.currentBounces < ball.maxBounces) {
          ball.currentBounces++;
          if (hitVertical) ball.velocity.x = -ball.velocity.x;
          if (hitHorizontal) ball.velocity.y = -ball.velocity.y;
        } else {
          ball.returnToCore();
          continue; // Stop checking blocks
        }
      }

      // Ball vs Blocks (Optimized)
      // Query grid for nearby blocks
      // Ball size is roughly ball.size.x
      // We explicitly query with the ball's bounding box
      final nearbyBlocks = _grid.query(ball.toRect());

      _currentCollisions.clear(); // 再利用

      for (final block in nearbyBlocks) {
        if (block.isRemoved) {
          continue; // Skip blocks destroyed in this frame (e.g. by Blast Orb)
        }

        if (checkCircleAABB(ball, block)) {
          _currentCollisions.add(block);

          if (ball.hitBlocks.contains(block)) {
            continue; // Ignore already hit blocks that are still colliding
          }

          // Damage
          final double previousHp = block.hp;
          block.takeDamage(ball.damage);
          AudioManager().playHit();
          ball.hitBlocks.add(block);

          ball.onHit(block);

          // Check if block was destroyed by this hit
          if (previousHp > 0 && block.hp <= 0) {
            ball.onKill(block);
          }

          // Physics
          if (ball.pierceCount > 0) {
            ball.pierceCount--;
            // No Bounce, just pass through
          } else {
            resolveCollision(ball, block);
          }
        }
      }

      // Cleanup: Remove blocks that are no longer colliding
      ball.hitBlocks.removeWhere((b) => !_currentCollisions.contains(b));
    }

    // Blocks vs Core
    // Core is static, we could also use grid, but iterating blocks is OK?
    // Actually, we can use grid query around Core too if we wanted,
    // but iteration is O(N) which is fine for now compared to O(N*M) of ball*block.
    // However, blocks move towards core so many will be near it.
    for (final block in _blocksCache) {
      if (block.toRect().overlaps(core.toRect())) {
        core.takeDamage(10);
        block.die(); // Self destruct
      }
    }
  }

  bool checkCircleAABB(Ball ball, BlockEnemy block) {
    // Transform ball center to block's local coordinate system
    final Vector2 ballWorldPos = ball.absolutePosition;
    final Vector2 blockCenter = block.absolutePosition;

    // Translate ball relative to block center
    final double relX = ballWorldPos.x - blockCenter.x;
    final double relY = ballWorldPos.y - blockCenter.y;

    // Rotate by -block.angle to align with block's local axes (using cached values)
    final double cosA = block.cachedCos;
    final double sinA = block.cachedSin;
    final double localX = relX * cosA - relY * sinA;
    final double localY = relX * sinA + relY * cosA;

    // Now do standard circle vs AABB in local space
    final double halfW = block.size.x / 2;
    final double halfH = block.size.y / 2;

    double clamp(double value, double min, double max) {
      if (value < min) return min;
      if (value > max) return max;
      return value;
    }

    final double closestX = clamp(localX, -halfW, halfW);
    final double closestY = clamp(localY, -halfH, halfH);

    final double distX = localX - closestX;
    final double distY = localY - closestY;
    final double distSquared = distX * distX + distY * distY;
    final double r = ball.size.x / 2;

    return distSquared < (r * r);
  }

  void resolveCollision(Ball ball, BlockEnemy block) {
    // Transform ball center to block's local coordinate system
    final Vector2 ballWorldPos = ball.absolutePosition;
    final Vector2 blockCenter = block.absolutePosition;

    final double relX = ballWorldPos.x - blockCenter.x;
    final double relY = ballWorldPos.y - blockCenter.y;

    // Use cached cos/sin values
    final double cosA = block.cachedCos;
    final double sinA = block.cachedSin;
    final double localX = relX * cosA - relY * sinA;
    final double localY = relX * sinA + relY * cosA;

    final double halfW = block.size.x / 2;
    final double halfH = block.size.y / 2;
    final double ballRadius = ball.size.x / 2;

    // Penetration depth calculation in local space
    final double penetrationX = (halfW + ballRadius) - localX.abs();
    final double penetrationY = (halfH + ballRadius) - localY.abs();

    // Determine push direction in local space
    double pushLocalX = 0;
    double pushLocalY = 0;
    double velLocalX = ball.velocity.x * cosA - ball.velocity.y * sinA;
    double velLocalY = ball.velocity.x * sinA + ball.velocity.y * cosA;

    if (penetrationX < penetrationY) {
      // Push along local X axis
      if (localX > 0) {
        pushLocalX = penetrationX;
        velLocalX = velLocalX.abs();
      } else {
        pushLocalX = -penetrationX;
        velLocalX = -velLocalX.abs();
      }
    } else {
      // Push along local Y axis
      if (localY > 0) {
        pushLocalY = penetrationY;
        velLocalY = velLocalY.abs();
      } else {
        pushLocalY = -penetrationY;
        velLocalY = -velLocalY.abs();
      }
    }

    // Transform push and velocity back to world space
    final double cosB = cos(block.angle);
    final double sinB = sin(block.angle);

    final double pushWorldX = pushLocalX * cosB - pushLocalY * sinB;
    final double pushWorldY = pushLocalX * sinB + pushLocalY * cosB;

    ball.position.x += pushWorldX;
    ball.position.y += pushWorldY;

    ball.velocity.x = velLocalX * cosB - velLocalY * sinB;
    ball.velocity.y = velLocalX * sinB + velLocalY * cosB;
  }
}
