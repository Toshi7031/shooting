import 'package:flame/extensions.dart';
import '../components/block.dart';

class SpatialGrid {
  final double cellSize;
  final Map<int, List<BlockEnemy>> _cells = {};

  SpatialGrid({this.cellSize = 64.0});

  void clear() {
    // リストの中身だけクリアし、リストオブジェクト自体は再利用
    for (final list in _cells.values) {
      list.clear();
    }
    // 古いセルが蓄積する場合のために、十分な数がたまったらマップ自体もクリア
    if (_cells.length > 100) {
      _cells.clear();
    }
  }

  // Generate a unique key for cell (x, y)
  // Combining x and y into a single int key
  int _hash(int x, int y) {
    // Standard pairing function or simple shifting if bounds are known.
    // Assuming simple world, simple shift is usually okay but let's be safe.
    // String key is safer but slower.
    // using prime multiplication:
    return x * 73856093 ^ y * 19349663;
  }

  void insert(BlockEnemy block) {
    // A block might span multiple cells if it's large or on a boundary
    // For simplicity, we can just insert the center point,
    // OR inserting into all overlapped cells is more accurate.
    // Given the small size of blocks relative to common screen size,
    // let's check the bounding box.

    final rect = block.toRect();
    final startX = (rect.left / cellSize).floor();
    final endX = (rect.right / cellSize).floor();
    final startY = (rect.top / cellSize).floor();
    final endY = (rect.bottom / cellSize).floor();

    for (int x = startX; x <= endX; x++) {
      for (int y = startY; y <= endY; y++) {
        final key = _hash(x, y);
        _cells.putIfAbsent(key, () => []).add(block);
      }
    }
  }

  // クエリ結果用のキャッシュ（GC削減）
  final Set<BlockEnemy> _queryResultSet = {};
  final List<BlockEnemy> _queryResultList = [];

  List<BlockEnemy> query(Rect rect) {
    final startX = (rect.left / cellSize).floor();
    final endX = (rect.right / cellSize).floor();
    final startY = (rect.top / cellSize).floor();
    final endY = (rect.bottom / cellSize).floor();

    _queryResultSet.clear();

    for (int x = startX; x <= endX; x++) {
      for (int y = startY; y <= endY; y++) {
        final key = _hash(x, y);
        final cell = _cells[key];
        if (cell != null) {
          _queryResultSet.addAll(cell);
        }
      }
    }

    _queryResultList.clear();
    _queryResultList.addAll(_queryResultSet);
    return _queryResultList;
  }
}
