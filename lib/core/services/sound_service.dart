import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final soundServiceProvider = Provider<SoundService>((ref) {
  final soundService = SoundService();
  ref.onDispose(() => soundService.dispose());
  return soundService;
});

/// Sound & Audio Manager for LudoVibe.
/// Handles background theme music, dice rolling sounds, token moves, captures, button clicks, and victory fanfare.
class SoundService {
  final AudioPlayer _bgMusicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _isSoundEnabled = true;
  bool _isMusicEnabled = true;
  bool _isBgPlaying = false;

  bool get isSoundEnabled => _isSoundEnabled;
  bool get isMusicEnabled => _isMusicEnabled;

  SoundService() {
    _init();
  }

  void _init() {
    _bgMusicPlayer.setReleaseMode(ReleaseMode.loop);
  }

  /// Start playing continuous background theme music
  Future<void> startBgMusic() async {
    if (!_isMusicEnabled || _isBgPlaying) return;
    try {
      await _bgMusicPlayer.play(AssetSource('sounds/bg_music.wav'));
      _isBgPlaying = true;
    } catch (e) {
      debugPrint('🎵 SoundService error playing bg_music: $e');
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

  /// Toggle Music setting (on/off)
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
