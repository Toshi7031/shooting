import 'package:flutter_soloud/flutter_soloud.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool _initialized = false;
  late final SoLoud _soloud;

  // AudioSource for SE
  AudioSource? _shootSource;
  AudioSource? _hitSource;
  AudioSource? _explosionSource;
  AudioSource? _levelupSource;
  AudioSource? _gameoverSource;

  // AudioSource for BGM
  AudioSource? _bgmSource;
  SoundHandle? _bgmHandle;

  // Settings
  double _bgmVolume = 0.5;
  double _seVolume = 0.5;
  bool _bgmEnabled = true;
  bool seEnabled = false;

  double get bgmVolume => _bgmVolume;
  double get seVolume => _seVolume;
  bool get bgmEnabled => _bgmEnabled;

  set bgmVolume(double value) {
    _bgmVolume = value.clamp(0.0, 1.0);
    if (_bgmEnabled && _bgmHandle != null && _soloud.isInitialized) {
      _soloud.setVolume(_bgmHandle!, _bgmVolume);
    }
  }

  set seVolume(double value) {
    _seVolume = value.clamp(0.0, 1.0);
  }

  set bgmEnabled(bool value) {
    _bgmEnabled = value;
    if (_bgmEnabled) {
      startBgm();
    } else {
      stopBgm();
    }
  }

  // SE再生のクールダウン（同じSEの連続再生を防ぐ）
  final Map<String, int> _lastPlayTime = {};
  static const int _sfxCooldownMs = 50;

  Future<void> init() async {
    if (_initialized) return;

    _soloud = SoLoud.instance;
    await _soloud.init();

    try {
      _shootSource = await _soloud.loadAsset('assets/audio/shoot.wav');
      _hitSource = await _soloud.loadAsset('assets/audio/hit.wav');
      _explosionSource = await _soloud.loadAsset('assets/audio/explosion.wav');
      _levelupSource = await _soloud.loadAsset('assets/audio/levelup.wav');
      _gameoverSource = await _soloud.loadAsset('assets/audio/gameover.wav');
      _bgmSource = await _soloud.loadAsset('assets/audio/bgm.mp3');
    } catch (e) {
      // Ignore
    }

    _initialized = true;
  }

  void playShoot() {
    _playFromSource(_shootSource, 'shoot');
  }

  void playHit() {
    _playFromSource(_hitSource, 'hit', relativeVolume: 0.8);
  }

  void playExplosion() {
    _playFromSource(_explosionSource, 'explosion');
  }

  void playLevelUp() {
    _playFromSource(_levelupSource, 'levelup');
  }

  void playGameOver() {
    _playFromSource(_gameoverSource, 'gameover');
  }

  void _playFromSource(AudioSource? source, String key,
      {double relativeVolume = 1.0}) {
    if (!SoLoud.instance.isInitialized || source == null || !seEnabled) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final lastPlay = _lastPlayTime[key];
    if (lastPlay != null && (now - lastPlay) < _sfxCooldownMs) {
      return;
    }
    _lastPlayTime[key] = now;

    try {
      _soloud.play(source, volume: _seVolume * relativeVolume);
    } catch (e) {
      // Ignore
    }
  }

  void startBgm() async {
    if (!_bgmEnabled || !_soloud.isInitialized || _bgmSource == null) return;

    try {
      if (_bgmHandle == null || !_soloud.getIsValidVoiceHandle(_bgmHandle!)) {
        _bgmHandle =
            await _soloud.play(_bgmSource!, volume: _bgmVolume, looping: true);
      } else {
        _soloud.setVolume(_bgmHandle!, _bgmVolume);
      }
    } catch (e) {
      // Ignore
    }
  }

  void stopBgm() {
    if (_soloud.isInitialized && _bgmHandle != null) {
      _soloud.stop(_bgmHandle!);
      _bgmHandle = null;
    }
  }
}
