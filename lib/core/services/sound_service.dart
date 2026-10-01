import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final soundServiceProvider = Provider<SoundService>((ref) {
  return SoundService();
});

/// Sound & Audio Manager for LudoVibe.
/// Handles background theme music (SoundMain.mp3), dice rolling sounds,
/// token moves, captures, button clicks, and victory fanfare.
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;

  final AudioPlayer _bgMusicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _isSoundEnabled = false;
  bool _isMusicEnabled = false;
  bool _isBgPlaying = false;
  bool _hasStarted = false;

  bool get isSoundEnabled => _isSoundEnabled;
  bool get isMusicEnabled => _isMusicEnabled;
  bool get isBgPlaying => _isBgPlaying;

  SoundService._internal() {
    _init();
  }

  void _init() async {
    try {
      if (kIsWeb) {
        AudioCache.instance = AudioCache(prefix: 'assets/assets/');
      }
      await _bgMusicPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgMusicPlayer.setVolume(0.5);
    } catch (e) {
      debugPrint('🎵 SoundService init error: $e');
    }
  }

  /// Start playing continuous background theme music (SoundMain.mp3)
  Future<void> startBgMusic() async {
    if (!_isMusicEnabled || _isBgPlaying) return;
    try {
      await _bgMusicPlayer.stop();
      await _bgMusicPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgMusicPlayer.setVolume(0.5);
      await _bgMusicPlayer.play(
        AssetSource('sounds/SoundMain.mp3', mimeType: 'audio/mpeg'),
      );
      _isBgPlaying = true;
      _hasStarted = true;
    } catch (e) {
      if (kIsWeb) {
        debugPrint(
            '🎵 Background music will start on first user interaction (Web Autoplay Policy).');
      } else {
        debugPrint(
            '🎵 SoundService playing SoundMain.mp3 error ($e), trying bg_music.mp3...');
        try {
          await _bgMusicPlayer.play(
            AssetSource('sounds/bg_music.mp3', mimeType: 'audio/mpeg'),
          );
          _isBgPlaying = true;
          _hasStarted = true;
        } catch (e2) {
          debugPrint('🎵 SoundService bg_music error: $e2');
        }
      }
    }
  }

  /// Stop background theme music
  Future<void> stopBgMusic() async {
    try {
      await _bgMusicPlayer.stop();
      _isBgPlaying = false;
    } catch (e) {
      debugPrint('🎵 SoundService error stopping bg_music: $e');
    }
  }

  /// Centralized SFX playback guard ensuring stop-before-play and strict playbackRate control
  Future<void> _playSfx(String assetPath, {double rate = 1.0}) async {
    if (!_isSoundEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.setPlaybackRate(rate);
      await _sfxPlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('🎵 SoundService error playing $assetPath: $e');
    }
  }

  /// Play UI Button click sound effect
  Future<void> playButtonClick() async {
    // If background music hasn't started yet due to browser autoplay restriction, start it on first user gesture
    if (_isMusicEnabled && !_isBgPlaying) {
      startBgMusic();
    }
    await _playSfx('sounds/button_click.wav', rate: 1.0);
  }

  /// Play urgent countdown ticking sound effect
  Future<void> playTimerTick() async {
    await _playSfx('sounds/button_click.wav', rate: 1.35);
  }

  /// Play Dice Roll sound effect
  Future<void> playDiceRoll() async {
    await _playSfx('sounds/dice_roll.wav', rate: 1.0);
  }

  /// Play Token/Piece Step Move sound effect
  Future<void> playPieceMove() async {
    await _playSfx('sounds/piece_move.wav', rate: 1.0);
  }

  /// Play Token/Piece Capture sound effect
  Future<void> playPieceCapture() async {
    await _playSfx('sounds/piece_capture.wav', rate: 1.0);
  }

  /// Play Victory Win Fanfare sound effect
  Future<void> playWinFanfare() async {
    await _playSfx('sounds/win_fanfare.wav', rate: 1.0);
  }

  /// Toggle Sound FX setting (on/off)
  void setSoundEnabled(bool enabled) {
    _isSoundEnabled = enabled;
  }

  /// Toggle Music setting (on/off) from Settings Dialog
  void setMusicEnabled(bool enabled) {
    _isMusicEnabled = enabled;
    if (enabled) {
      startBgMusic();
    } else {
      stopBgMusic();
    }
  }

  void dispose() {
    _bgMusicPlayer.dispose();
    _sfxPlayer.dispose();
  }
}
