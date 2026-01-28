import 'package:flame/components.dart';

// Simple Pool Interface
class PoolManager<T extends Component> {
  final List<T> _pool = [];
  final T Function() _factory;

  PoolManager(this._factory);

  T get() {
    if (_pool.isNotEmpty) {
      return _pool.removeLast();
    }
    return _factory();
  }

  void returnToPool(T component) {
    component.removeFromParent();
    _pool.add(component);
  }
}

// Global Pools (Singleton or Game managed)
class GamePools {
  static final GamePools _instance = GamePools._internal();
  factory GamePools() => _instance;
  GamePools._internal();

  // Example for particles or basic blocks
  // final PoolManager<BlockEnemy> blockPool = PoolManager(() => BlockEnemy(position: Vector2.zero()));
}
