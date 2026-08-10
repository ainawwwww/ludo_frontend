import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

class StorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  static const String _keyToken = 'auth_token';
  static const String _keyDeviceId = 'device_id';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // --- Auth Token ---
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _keyToken, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _keyToken);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _keyToken);
  }

  // --- Device ID ---
  Future<String> getDeviceId() async {
    await init();
    String? deviceId = _prefs?.getString(_keyDeviceId);
    if (deviceId == null || deviceId.isEmpty) {
      deviceId = _generateDeviceId();
      await _prefs?.setString(_keyDeviceId, deviceId);
    }
    return deviceId;
  }

  String _generateDeviceId() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    return values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  // --- Cache User ID & Name ---
  Future<void> saveUserInfo(int userId, String username) async {
    await init();
    await _prefs?.setInt(_keyUserId, userId);
    await _prefs?.setString(_keyUserName, username);
  }

  Future<int?> getUserId() async {
    await init();
    return _prefs?.getInt(_keyUserId);
  }

  Future<String?> getUsername() async {
    await init();
    return _prefs?.getString(_keyUserName);
  }

  Future<void> clearAll() async {
    await deleteToken();
    await init();
    await _prefs?.remove(_keyUserId);
    await _prefs?.remove(_keyUserName);
  }
}
