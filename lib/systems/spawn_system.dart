import 'package:flame/components.dart';
import 'dart:math';
import '../components/block.dart';
import '../components/boss_enemy.dart';
import '../data/game_state.dart';
import '../data/enemy_mod.dart';
import '../data/constants.dart';

class SpawnSystem extends Component with HasGameReference {
  late Timer _timer;
  final Random _rng = Random();

  SpawnSystem() {
    _timer = Timer(1.0, repeat: true, onTick: _spawnBlock);
  }

  @override
  void update(double dt) {
    _timer.update(dt);
  }

  void _spawnBlock() {
    final state = GameState();
    if (state.isGameOver || state.isPaused) return;
    if (state.enemiesToSpawn <= 0) return;

    state.enemySpawned(); // Decrement pending count

    // Check Boss Spawn
    if (state.isBossWave) {
      _spawnBoss();
      return;
    }

    // Spawn 360 degrees
    final size = game.size;
    final center = Vector2(size.x / 2, size.y / 2);
    final radius = sqrt(size.x * size.x + size.y * size.y) / 2 +
        50; // Outside screen corner

    final angle = _rng.nextDouble() * 2 * pi;
    final spawnPos = center + Vector2(cos(angle), sin(angle)) * radius;

    // Target Core
    final velocity =
        (center - spawnPos).normalized() * GameConstants.defaultEnemySpeed;

    // Rare敵の生成（20%の確率、Wave 3以降）
    List<EnemyMod>? mods;
    if (state.currentWave >= 3 && _rng.nextDouble() < 0.2) {
      mods = _generateRandomMods();
    }

    // Block now rotates automatically based on velocity
    game.add(
        BlockEnemy(position: spawnPos, initialMods: mods)..velocity = velocity);
  }

  /// ランダムなModを生成（1〜2個）
  List<EnemyMod> _generateRandomMods() {
    final mods = <EnemyMod>[];
    final modCount = _rng.nextInt(2) + 1; // 1〜2個
    final availableTypes = List<EnemyModType>.from(EnemyModType.values);

    for (int i = 0; i < modCount && availableTypes.isNotEmpty; i++) {
      final index = _rng.nextInt(availableTypes.length);
      final type = availableTypes.removeAt(index);
      mods.add(EnemyMod.withDefault(type));
    }

    return mods;
  }

  void _spawnBoss() {
    final size = game.size;
    // Boss comes from top
    final pos = Vector2(size.x / 2 - 64, GameConstants.bossSpawnY);

    final corePos = Vector2(size.x / 2, size.y / 2);
    final velocity = (corePos - pos).normalized() * GameConstants.bossSpeed;

    // ボスは常に2-3個のModを持つ
    final bossMods = _generateBossMods();

    game.add(
        BossEnemy(position: pos, initialMods: bossMods)..velocity = velocity);
  }

  /// ボス用のMod生成（2〜3個）
  List<EnemyMod> _generateBossMods() {
    final mods = <EnemyMod>[];
    final modCount = _rng.nextInt(2) + 2; // 2〜3個
    final availableTypes = List<EnemyModType>.from(EnemyModType.values);

    for (int i = 0; i < modCount && availableTypes.isNotEmpty; i++) {
      final index = _rng.nextInt(availableTypes.length);
      final type = availableTypes.removeAt(index);
      // ボスはMod効果が少し強化される
      mods.add(EnemyMod(type: type, value: type.defaultValue * 1.2));
    }

    return mods;
  }
}
