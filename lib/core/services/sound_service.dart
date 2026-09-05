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

  bool _isSoundEnabled = true;
  bool _isMusicEnabled = true;
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
        AssetSource('sounds/SoundMain.mp3'),
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
          await _bgMusicPlayer.play(AssetSource('sounds/bg_music.mp3'));
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

  /// Play UI Button click sound effect
  Future<void> playButtonClick() async {
    // If background music hasn't started yet due to browser autoplay restriction, start it on first user gesture
    if (_isMusicEnabled && !_isBgPlaying) {
      startBgMusic();
    }

    if (!_isSoundEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('sounds/button_click.wav'));
    } catch (e) {
      debugPrint('🎵 SoundService error playing button_click: $e');
    }
  }

  /// Play Dice Roll sound effect
  Future<void> playDiceRoll() async {
    if (!_isSoundEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('sounds/dice_roll.wav'));
    } catch (e) {
      debugPrint('🎵 SoundService error playing dice_roll: $e');
    }
  }

  /// Play Token/Piece Step Move sound effect
  Future<void> playPieceMove() async {
    if (!_isSoundEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('sounds/piece_move.wav'));
    } catch (e) {
      debugPrint('🎵 SoundService error playing piece_move: $e');
    }
  }

  /// Play Token/Piece Capture sound effect
  Future<void> playPieceCapture() async {
    if (!_isSoundEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('sounds/piece_capture.wav'));
    } catch (e) {
      debugPrint('🎵 SoundService error playing piece_capture: $e');
    }
  }

  /// Play Victory Win Fanfare sound effect
  Future<void> playWinFanfare() async {
    if (!_isSoundEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('sounds/win_fanfare.wav'));
    } catch (e) {
      debugPrint('🎵 SoundService error playing win_fanfare: $e');
    }
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
