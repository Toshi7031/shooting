import 'package:flutter/material.dart';

/// 敵が持つMod（特殊能力）の種類
enum EnemyModType {
  haste, // 移動速度UP
  giant, // サイズUP + HPアップ
  enraged, // ダメージUP（Coreへの自爆ダメージ）
  armored, // 被ダメージ減少
}

/// Modの表示名と色
extension EnemyModTypeExtension on EnemyModType {
  String get label {
    switch (this) {
      case EnemyModType.haste:
        return 'Haste';
      case EnemyModType.giant:
        return 'Giant';
      case EnemyModType.enraged:
        return 'Enraged';
      case EnemyModType.armored:
        return 'Armored';
    }
  }

  Color get color {
    switch (this) {
      case EnemyModType.haste:
        return Colors.cyan;
      case EnemyModType.giant:
        return Colors.purple;
      case EnemyModType.enraged:
        return Colors.red;
      case EnemyModType.armored:
        return Colors.grey;
    }
  }

  /// Modの効果値（デフォルト）
  double get defaultValue {
    switch (this) {
      case EnemyModType.haste:
        return 1.5; // 50% faster
      case EnemyModType.giant:
        return 2.0; // 2x size and HP
      case EnemyModType.enraged:
        return 2.0; // 2x damage
      case EnemyModType.armored:
        return 0.5; // 50% damage reduction
    }
  }
}

/// 敵に付与されるMod
class EnemyMod {
  final EnemyModType type;
  final double value;

  const EnemyMod({
    required this.type,
    double? value,
  }) : value = value ?? 1.0;

  /// デフォルト値を使用してModを作成
  factory EnemyMod.withDefault(EnemyModType type) {
    return EnemyMod(type: type, value: type.defaultValue);
  }
}
