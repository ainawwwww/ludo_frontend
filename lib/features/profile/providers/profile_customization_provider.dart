import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ludo_vibe/features/profile/models/profile_customization_model.dart';
import 'package:ludo_vibe/features/profile/providers/profile_provider.dart';

class ProfileCustomizationState {
  final ProfileThemeItem currentTheme;
  final ProfileFrameItem currentFrame;
  final ProfileOrnamentItem currentOrnament;
  final String? customAvatarPath;
  final String? presetAvatarAsset;
  final bool isUploadingAvatar;

  const ProfileCustomizationState({
    required this.currentTheme,
    required this.currentFrame,
    required this.currentOrnament,
    this.customAvatarPath,
    this.presetAvatarAsset,
    this.isUploadingAvatar = false,
  });

  ProfileCustomizationState copyWith({
    ProfileThemeItem? currentTheme,
    ProfileFrameItem? currentFrame,
    ProfileOrnamentItem? currentOrnament,
    String? customAvatarPath,
    String? presetAvatarAsset,
    bool? isUploadingAvatar,
    bool clearCustomAvatar = false,
  }) {
    return ProfileCustomizationState(
      currentTheme: currentTheme ?? this.currentTheme,
      currentFrame: currentFrame ?? this.currentFrame,
      currentOrnament: currentOrnament ?? this.currentOrnament,
      customAvatarPath: clearCustomAvatar
          ? null
          : (customAvatarPath ?? this.customAvatarPath),
      presetAvatarAsset: presetAvatarAsset ?? this.presetAvatarAsset,
      isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
    );
  }
}

class ProfileCustomizationNotifier
    extends StateNotifier<ProfileCustomizationState> {
  final Ref _ref;
  SharedPreferences? _prefs;

  static const String _keyThemeId = 'profile_theme_id';
  static const String _keyFrameId = 'profile_frame_id';
  static const String _keyOrnamentId = 'profile_ornament_id';
  static const String _keyCustomAvatarPath = 'profile_custom_avatar_path';
  static const String _keyPresetAvatarAsset = 'profile_preset_avatar_asset';

  ProfileCustomizationNotifier(this._ref)
      : super(
          ProfileCustomizationState(
            currentTheme: ProfileThemeItem.allThemes.first,
            currentFrame: ProfileFrameItem.allFrames.first,
            currentOrnament: ProfileOrnamentItem.allOrnaments.first,
          ),
        ) {
    _loadFromPreferences();
  }

  Future<void> _loadFromPreferences() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();

      final savedThemeId = _prefs?.getString(_keyThemeId);
      final savedFrameId = _prefs?.getString(_keyFrameId);
      final savedOrnamentId = _prefs?.getString(_keyOrnamentId);
      final savedCustomAvatar = _prefs?.getString(_keyCustomAvatarPath);
      final savedPresetAvatar = _prefs?.getString(_keyPresetAvatarAsset);

      final theme = ProfileThemeItem.allThemes.firstWhere(
        (t) => t.id == savedThemeId,
        orElse: () => ProfileThemeItem.allThemes.first,
      );

      final frame = ProfileFrameItem.allFrames.firstWhere(
        (f) => f.id == savedFrameId,
        orElse: () => ProfileFrameItem.allFrames.first,
      );

      final ornament = ProfileOrnamentItem.allOrnaments.firstWhere(
        (o) => o.id == savedOrnamentId,
        orElse: () => ProfileOrnamentItem.allOrnaments.first,
      );

      state = state.copyWith(
        currentTheme: theme,
        currentFrame: frame,
        currentOrnament: ornament,
        customAvatarPath: savedCustomAvatar,
        presetAvatarAsset: savedPresetAvatar,
      );

      // Sync avatar with profileProvider if preset was set
      if (savedCustomAvatar != null && savedCustomAvatar.isNotEmpty) {
        _ref.read(profileProvider.notifier).setAvatarUrl(savedCustomAvatar);
      } else if (savedPresetAvatar != null && savedPresetAvatar.isNotEmpty) {
        _ref.read(profileProvider.notifier).setAvatarUrl(savedPresetAvatar);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading profile customization: $e');
      }
    }
  }

  Future<void> setTheme(ProfileThemeItem theme) async {
    state = state.copyWith(currentTheme: theme);
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setString(_keyThemeId, theme.id);
    } catch (_) {}
  }

  Future<void> setFrame(ProfileFrameItem frame) async {
    state = state.copyWith(currentFrame: frame);
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setString(_keyFrameId, frame.id);
    } catch (_) {}
  }

  Future<void> setOrnament(ProfileOrnamentItem ornament) async {
    state = state.copyWith(currentOrnament: ornament);
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setString(_keyOrnamentId, ornament.id);
    } catch (_) {}
  }

  Future<void> setPresetAvatar(ProfileAvatarPreset preset) async {
    state = state.copyWith(
      presetAvatarAsset: preset.assetPath,
      clearCustomAvatar: true,
    );
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setString(_keyPresetAvatarAsset, preset.assetPath);
      await _prefs?.remove(_keyCustomAvatarPath);
      _ref.read(profileProvider.notifier).setAvatarUrl(preset.assetPath);
    } catch (_) {}
  }

  Future<bool> uploadCustomAvatar(File imageFile) async {
    return uploadCustomAvatarPath(imageFile.path, file: imageFile);
  }

  Future<bool> uploadCustomAvatarPath(String path, {File? file}) async {
    try {
      state = state.copyWith(isUploadingAvatar: true);

      state = state.copyWith(
        customAvatarPath: path,
        presetAvatarAsset: null,
        isUploadingAvatar: false,
      );

      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setString(_keyCustomAvatarPath, path);
      await _prefs?.remove(_keyPresetAvatarAsset);

      _ref.read(profileProvider.notifier).setAvatarUrl(path);

      // Attempt to sync with backend if online and file is provided
      if (file != null && !kIsWeb) {
        try {
          await _ref
              .read(profileRepositoryProvider)
              .updateProfile(avatarFile: file);
        } catch (_) {}
      }

      return true;
    } catch (e) {
      state = state.copyWith(isUploadingAvatar: false);
      return false;
    }
  }
}

final profileCustomizationProvider = StateNotifierProvider<
    ProfileCustomizationNotifier, ProfileCustomizationState>((ref) {
  return ProfileCustomizationNotifier(ref);
});
