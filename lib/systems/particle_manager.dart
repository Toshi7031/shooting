import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class ParticleHelper {
  static final Random _rng = Random();

  static Component spawnBlockExplosion(Vector2 position) {
    return ParticleSystemComponent(
      particle: Particle.generate(
        count: 5,
        lifespan: 0.3,
        generator: (i) => AcceleratedParticle(
          acceleration: Vector2(0, 200),
          speed: Vector2(
              _rng.nextDouble() * 200 - 100, _rng.nextDouble() * 200 - 100),
          position: position,
          child: CircleParticle(
            radius: 2,
            paint: Paint()..color = Colors.redAccent,
          ),
        ),
      ),
    );
  }

  /// 衝撃波エフェクト（拡大する円）
  static Component spawnShockwave(Vector2 position, {double radius = 50.0}) {
    return _ShockwaveComponent(
      position: position,
      maxRadius: radius,
      duration: 0.3,
      color: Colors.orangeAccent,
    );
  }
}

/// 衝撃波コンポーネント - 拡大する円を描画
class _ShockwaveComponent extends PositionComponent {
  final double maxRadius;
  final double duration;
  final Color color;

  double _elapsed = 0;

  _ShockwaveComponent({
    required Vector2 position,
    required this.maxRadius,
    required this.duration,
    required this.color,
  }) : super(position: position, anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final progress = (_elapsed / duration).clamp(0.0, 1.0);
    final currentRadius = maxRadius * progress;
    final opacity = (1.0 - progress) * 0.7;

    final paint = Paint()
      ..color = color.withAlpha((opacity * 255).toInt())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0 * (1.0 - progress * 0.5);

    canvas.drawCircle(Offset.zero, currentRadius, paint);
  }
}
