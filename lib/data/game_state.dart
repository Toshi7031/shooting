import 'package:flutter/foundation.dart';
import 'models/item_data.dart';
import 'repositories/item_repository.dart';
import 'models/artifact_data.dart';

class GameState extends ChangeNotifier {
  static final GameState _instance = GameState._internal();
  factory GameState() => _instance;
  GameState._internal();

  int gold = 0;
  int currentWave = 1;
  double coreHp = 100.0;
  double maxCoreHp = 100.0;

  // Wave Stats
  // int totalBalls = 3; // Deprecated, use ballLoadout.length
  List<ItemData> ballLoadout = [
    ItemRepository.defaultBall,
    ItemRepository.defaultBall,
    ItemRepository.defaultBall,
  ];

  int get totalBalls => ballLoadout.length;

  int availableBalls = 3;
  double ballDamage = 1.0;

  bool isGameOver = false;
  // bool isLevelUp = false; // Removed in favor of pendingUpgrades
  bool isPaused = false; // New Pause State

  int enemiesToSpawn = 10;
  int enemiesAlive = 0;
  bool isBossWave = false;

  bool isGameActive = false;

  void startGame() {
    isGameActive = true;
    notifyListeners();
  }

  // XP Stats
  int level = 1;
  double xp = 0;
  double xpRequired = 100;

  // Tag Multipliers
  Map<String, double> tagMultipliers = {
    'Physical': 1.0,
    'Fire': 1.0,
    'Cold': 1.0,
  };

  // New Stats
  double fireIntervalMultiplier =
      1.0; // Higher = Faster? No, Interval * (1/Multiplier)
  int pierceCount = 0;
  int maxBounces = 1; // Default 1 bounce

  // Stolen Mods (Headhunter用)
  final List<StolenMod> stolenMods = [];

  // Artifact管理
  final List<ArtifactData> equippedArtifacts = [];
  static const int maxArtifactSlots = 3;

  // Artifact効果用
  bool hasBerserkBuff = false; // Berserker's Rage
  double goldMultiplier = 1.0; // Lucky Charm

  /// アーティファクトを装備
  bool equipArtifact(ArtifactData artifact) {
    if (equippedArtifacts.length >= maxArtifactSlots) {
      debugPrint("Cannot equip ${artifact.name}: No empty slots");
      return false;
    }

    equippedArtifacts.add(artifact);
    debugPrint("Equipped artifact: ${artifact.name}");
    notifyListeners();
    return true;
  }

  /// アーティファクトを解除
  bool unequipArtifact(ArtifactData artifact) {
    final removed = equippedArtifacts.remove(artifact);
    if (removed) {
      debugPrint("Unequipped artifact: ${artifact.name}");
      notifyListeners();
    }
    return removed;
  }

  /// スロットに空きがあるか
  bool get hasEmptyArtifactSlot => equippedArtifacts.length < maxArtifactSlots;

  /// 指定したアーティファクトを既に持っているか
  bool hasArtifact(ArtifactData artifact) {
    return equippedArtifacts.any((a) => a.name == artifact.name);
  }

  void addGold(int amount) {
    gold += amount;
    notifyListeners();
  }

  // Level Up Stats
  int pendingUpgrades = 0;

  void addXp(double amount) {
    if (isGameOver) return;
    xp += amount;
    while (xp >= xpRequired) {
      xp -= xpRequired;
      level++;
      pendingUpgrades++;
      xpRequired *= 1.2; // Scale requirement
    }
    notifyListeners();
  }

  void addRewards({required int gold, required double xp}) {
    if (isGameOver) return;
    this.gold += gold;

    // XP Logic
    this.xp += xp;
    while (this.xp >= xpRequired) {
      this.xp -= xpRequired;
      level++;
      pendingUpgrades++;
      xpRequired *= 1.2;
    }
    notifyListeners();
  }

  // void closeLevelUp() {} // Removed

  void upgradeTag(String tag, double amount) {
    if (pendingUpgrades <= 0) return;

    if (tagMultipliers.containsKey(tag)) {
      tagMultipliers[tag] = (tagMultipliers[tag] ?? 1.0) + amount;
      pendingUpgrades--;
      notifyListeners();
    } else if (tag == 'AttackSpeed') {
      fireIntervalMultiplier += amount;
      pendingUpgrades--;
      notifyListeners();
    } else if (tag == 'Pierce') {
      pierceCount += amount.toInt();
      pendingUpgrades--;
      notifyListeners();
    } else if (tag == 'Bounce') {
      maxBounces += amount.toInt();
      pendingUpgrades--;
      notifyListeners();
    }
  }

  void addBall(ItemData item) {
    ballLoadout.add(item);
    availableBalls++;
    notifyListeners();
  }

  void reset() {
    isGameOver = false;
    isGameActive = false;
    pendingUpgrades = 0;
    isPaused = false;
    coreHp = maxCoreHp;
    currentWave = 1;
    isBossWave = false;
    gold = 0;

    level = 1;
    xp = 0;
    xpRequired = 100;
    tagMultipliers = {
      'Physical': 1.0,
      'Fire': 1.0,
      'Cold': 1.0,
    };
    fireIntervalMultiplier = 1.0;
    pierceCount = 0;
    maxBounces = 1;
    stolenMods.clear();
    equippedArtifacts.clear();
    hasBerserkBuff = false;
    goldMultiplier = 1.0;

    // ... (inside reset)
    ballLoadout = [
      ItemRepository.defaultBall,
      ItemRepository.defaultBall,
      ItemRepository.defaultBall,
    ];
    availableBalls = 3;
    availableBalls = 3;
    // 初期敵数
    enemiesToSpawn = 50;
    enemiesAlive = 0;
    notifyListeners();
  }

  void nextWave() {
    currentWave++;

    if (currentWave % 5 == 0) {
      isBossWave = true;
      enemiesToSpawn = 1; // Only 1 Boss
    } else {
      isBossWave = false;
      enemiesToSpawn = 50 + (currentWave * 10); // Waveごとに+10体
    }

    notifyListeners();
  }

  void enemySpawned() {
    enemiesToSpawn--;
    enemiesAlive++;
    // We don't necessarily notify on every spawn to save performance,
    // but if UI shows "Enemies Remaining" we might want to.
  }

  void enemyKilled() {
    enemiesAlive--;
    if (enemiesAlive <= 0 && enemiesToSpawn <= 0) {
      nextWave();
    }
  }

  void returnBall() {
    availableBalls++;
    // notifyListenersは高頻度なのでスキップ
  }

  bool consumeBall() {
    if (availableBalls > 0) {
      availableBalls--;
      // notifyListenersは高頻度なのでスキップ
      return true;
    }
    return false;
  }

  void damageCore(double amount) {
    if (isGameOver) return;
    coreHp -= amount;
    if (coreHp <= 0) {
      coreHp = 0;
      isGameOver = true;
    }
    notifyListeners();
  }

  void healCore(double amount) {
    if (isGameOver) return;
    coreHp += amount;
    if (coreHp > maxCoreHp) {
      coreHp = maxCoreHp;
    }
    notifyListeners();
  }

  /// 盗んだModを追加
  void addStolenMod(String type, double value, double duration) {
    stolenMods
        .add(StolenMod(type: type, value: value, remainingTime: duration));
    notifyListeners();
  }

  /// 盗んだModを更新（毎フレーム呼び出し）
  void updateStolenMods(double dt) {
    if (stolenMods.isEmpty) return;

    stolenMods.removeWhere((mod) {
      mod.remainingTime -= dt;
      return mod.remainingTime <= 0;
    });
  }

  /// 盗んだModの合計倍率を取得
  double getStolenModMultiplier(String type) {
    double multiplier = 1.0;
    for (final mod in stolenMods.where((m) => m.type == type)) {
      multiplier *= mod.value;
    }
    return multiplier;
  }
}

/// 盗んだModの一時データ
class StolenMod {
  final String type;
  final double value;
  double remainingTime;

  StolenMod({
    required this.type,
    required this.value,
    required this.remainingTime,
  });
}
