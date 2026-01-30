import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool _initialized = false;

  // AudioPool（プリロード済みプレーヤーを再利用してGC圧力を回避）
  AudioPool? _shootPool;
  AudioPool? _hitPool;
  AudioPool? _explosionPool;
  AudioPool? _levelupPool;
  AudioPool? _gameoverPool;

  // Settings
  double _bgmVolume = 0.5;
  double _seVolume = 0.5;
  bool _bgmEnabled = true;
  bool _seEnabled = false;

  double get bgmVolume => _bgmVolume;
  double get seVolume => _seVolume;
  bool get bgmEnabled => _bgmEnabled;
  bool get seEnabled => _seEnabled;

  set bgmVolume(double value) {
    _bgmVolume = value.clamp(0.0, 1.0);
    if (_bgmEnabled) {
      FlameAudio.bgm.audioPlayer.setVolume(_bgmVolume);
    }
  }

  set seVolume(double value) {
    _seVolume = value.clamp(0.0, 1.0);
  }

  set bgmEnabled(bool value) {
    _bgmEnabled = value;
    if (_bgmEnabled) {
      if (!FlameAudio.bgm.isPlaying) {
        startBgm();
      } else {
        FlameAudio.bgm.audioPlayer.setVolume(_bgmVolume);
      }
    } else {
      stopBgm();
    }
  }

  set seEnabled(bool value) {
    _seEnabled = value;
  }

  // SE再生のクールダウン（同じSEの連続再生を防ぐ）
  final Map<String, int> _lastPlayTime = {}; // DateTimeの代わりにmillisecondsを使用
  static const int _sfxCooldownMs = 50;

  Future<void> init() async {
    if (_initialized) return;

    // AudioPoolを作成（各音源に対してプレーヤーをプール）
    try {
      _shootPool = await FlameAudio.createPool('shoot.wav', maxPlayers: 3);
      _hitPool = await FlameAudio.createPool('hit.wav', maxPlayers: 4);
      _explosionPool = await FlameAudio.createPool('explosion.wav', maxPlayers: 3);
      _levelupPool = await FlameAudio.createPool('levelup.wav', maxPlayers: 1);
      _gameoverPool = await FlameAudio.createPool('gameover.wav', maxPlayers: 1);
    } catch (e) {
      // プール作成に失敗した場合は無音で続行
    }

    _initialized = true;
  }

  void playShoot() {
    _playFromPool(_shootPool, 'shoot');
  }

  void playHit() {
    _playFromPool(_hitPool, 'hit', relativeVolume: 0.8);
  }

  void playExplosion() {
    _playFromPool(_explosionPool, 'explosion');
  }

  void playLevelUp() {
    _playFromPool(_levelupPool, 'levelup');
  }

  void playGameOver() {
    _playFromPool(_gameoverPool, 'gameover');
  }

  void _playFromPool(AudioPool? pool, String key, {double relativeVolume = 1.0}) {
    if (pool == null || !_seEnabled) return;

    // クールダウンチェック（DateTime.now()の代わりにStopwatchベースの時間を使用）
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastPlay = _lastPlayTime[key];
    if (lastPlay != null && (now - lastPlay) < _sfxCooldownMs) {
      return; // クールダウン中はスキップ
    }
    _lastPlayTime[key] = now;

    try {
      pool.start(volume: _seVolume * relativeVolume);
    } catch (e) {
      // エラーは無視
    }
  }

  void startBgm() {
    if (!_bgmEnabled) return;

    try {
      if (!FlameAudio.bgm.isPlaying) {
        FlameAudio.bgm.play('bgm.mp3', volume: _bgmVolume);
      }
    } catch (e) {
      // Ignore
    }
  }

  void stopBgm() {
    FlameAudio.bgm.stop();
  }
}
