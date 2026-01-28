import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    // Preload sounds
    await FlameAudio.audioCache.loadAll([
      'shoot.wav',
      'hit.wav',
      'explosion.wav',
      'levelup.wav',
      'gameover.wav',
      // 'bgm.mp3', // BGM might be large, stream it?
    ]);
    _initialized = true;
  }

  void playShoot() {
    _playSfx('shoot.wav');
  }

  void playHit() {
    _playSfx('hit.wav');
  }

  void playExplosion() {
    _playSfx('explosion.wav', volume: 0.6);
  }

  void playLevelUp() {
    _playSfx('levelup.wav');
  }

  void playGameOver() {
    _playSfx('gameover.wav');
  }

  void _playSfx(String file, {double volume = 1.0}) {
    try {
      FlameAudio.play(file, volume: volume);
    } catch (e) {
      // Ignore errors if file is empty/missing during dev
      // print("Audio Error: $e");
    }
  }

  void startBgm() {
    try {
      if (!FlameAudio.bgm.isPlaying) {
        FlameAudio.bgm.play('bgm.mp3', volume: 0.5);
      }
    } catch (e) {
      // Ignore
    }
  }

  void stopBgm() {
    FlameAudio.bgm.stop();
  }
}
