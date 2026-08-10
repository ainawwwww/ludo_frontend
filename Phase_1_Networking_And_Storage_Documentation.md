# LudoVibe — Phase 1: Core Networking & Storage Layer Documentation

This document provides complete technical documentation and exact source code for **Phase 1: Core Networking & Storage Layer** implemented in the Flutter application (`ludo_vibe`) for integration with the Laravel 11 backend and Laravel Reverb WebSockets.

---

## 1. Overview of Phase 1 Architecture

Phase 1 establishes the core network and persistence infrastructure required for the Ludo application. It consists of four primary components:

1. **API Endpoints (`ApiEndpoints`)**: Centralized route definitions mapped directly to `Ludo_Backend_API_Documentation.md`.
2. **Storage Service (`StorageService`)**: Manages encrypted Sanctum bearer tokens via `FlutterSecureStorage` and generates/persists a unique hexadecimal `device_id` via `SharedPreferences`.
3. **API Client (`ApiClient`)**: A `Dio`-powered HTTP client that handles interceptors, automatic bearer token injection, `ApiException` mapping (HTTP 401, 422, 500), and multipart uploads for avatars and voice notes.
4. **WebSocket Service (`WebSocketService`)**: Manages real-time WebSocket connections to Laravel Reverb (`ws://127.0.0.1:8080/app`), handling channel subscriptions (`private-user.{user_id}` and `room.{room_id}`) and broadcasting parsed `WebSocketEvent` streams across Riverpod providers.

---

## 2. Directory Structure & Files Created

| File Path | Description |
|---|---|
| [`lib/core/network/api_endpoints.dart`](file:///c:/Users/SINC%2012/Desktop/ludo/lib/core/network/api_endpoints.dart) | API and WebSocket route constants |
| [`lib/core/storage/storage_service.dart`](file:///c:/Users/SINC%2012/Desktop/ludo/lib/core/storage/storage_service.dart) | Secure token and persistent device_id storage service |
| [`lib/core/network/api_client.dart`](file:///c:/Users/SINC%2012/Desktop/ludo/lib/core/network/api_client.dart) | Dio HTTP client with interceptors & error handlers |
| [`lib/core/network/websocket_service.dart`](file:///c:/Users/SINC%2012/Desktop/ludo/lib/core/network/websocket_service.dart) | Laravel Reverb WebSocket client & event stream manager |
| [`test/core_network_storage_test.dart`](file:///c:/Users/SINC%2012/Desktop/ludo/test/core_network_storage_test.dart) | Unit test suite for Phase 1 components |

---

## 3. Complete Source Code

### 3.1 `lib/core/network/api_endpoints.dart`
```dart
abstract final class ApiEndpoints {
  // Base URLs (Update host for physical device / emulator testing, e.g. 10.0.2.2 for Android Emulator)
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';
  static const String wsUrl = 'ws://127.0.0.1:8080/app';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String guest = '/auth/guest';
  static const String google = '/auth/google';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';

  // Home
  static const String home = '/home';

  // Profile
  static const String profile = '/profile';

  // Wallet
  static const String walletBalance = '/wallet/balance';
  static const String walletTransactions = '/wallet/transactions';
  static const String walletTopup = '/wallet/topup';

  // Rooms
  static const String rooms = '/rooms';
  static const String joinRoom = '/rooms/join';
  static String roomDetail(int id) => '/rooms/$id';

  // Matchmaking
  static const String matchmakingJoin = '/matchmaking/join';
  static const String matchmakingLeave = '/matchmaking/leave';
  static const String matchmakingStatus = '/matchmaking/status';

  // Game Engine
  static const String gameStart = '/game/start';
  static const String gameState = '/game/state';
  static const String gameRoll = '/game/roll';
  static const String gameMove = '/game/move';

  // Store
  static const String storeItems = '/store/items';
  static const String storePurchase = '/store/purchase';
  static const String storeInventory = '/store/inventory';

  // Friends
  static const String friends = '/friends';
  static const String friendRequest = '/friends/request';
  static String friendRespond(int id) => '/friends/$id/respond';

  // Room Chat
  static const String chatMessage = '/chat/message';
  static const String chatMessages = '/chat/messages';

  // Direct Messaging
  static String friendSendMessage(int friendId) => '/friends/$friendId/message';
  static String friendGetMessages(int friendId) => '/friends/$friendId/messages';
  static const String conversations = '/friends/conversations';
  static String deleteMessage(int messageId) => '/friends/messages/$messageId';

  // Leaderboard
  static const String leaderboard = '/leaderboard';
}
```

---

### 3.2 `lib/core/storage/storage_service.dart`
```dart
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
```

---

### 3.3 `lib/core/network/api_client.dart`
```dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/network/api_endpoints.dart';
import 'package:ludo_vibe/core/storage/storage_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return ApiClient(storageService: storageService);
});

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  @override
  String toString() => 'ApiException: $message (code: $statusCode)';
}

class ApiClient {
  late final Dio _dio;
  final StorageService _storageService;

  ApiClient({required StorageService storageService}) : _storageService = storageService {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (kDebugMode) {
            print('🌐 [API REQ] ${options.method} -> ${options.uri}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('✅ [API RES] ${response.statusCode} <- ${response.requestOptions.uri}');
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (kDebugMode) {
            print('❌ [API ERR] ${e.response?.statusCode} <- ${e.requestOptions.uri}');
            print('   Message: ${e.response?.data}');
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters, options: options);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(path, data: data, queryParameters: queryParameters, options: options);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(path, data: data, queryParameters: queryParameters, options: options);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(path, data: data, queryParameters: queryParameters, options: options);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // --- Multipart Form Data Upload (for Avatars, Voice Notes) ---
  Future<dynamic> uploadMultipart(
    String path, {
    required Map<String, dynamic> fields,
    required Map<String, File> files,
    String method = 'POST',
  }) async {
    try {
      final formDataMap = <String, dynamic>{...fields};

      for (var entry in files.entries) {
        final file = entry.value;
        final filename = file.path.split('/').last;
        formDataMap[entry.key] = await MultipartFile.fromFile(
          file.path,
          filename: filename,
        );
      }

      final formData = FormData.fromMap(formDataMap);

      final options = Options(
        method: method,
        headers: {'Content-Type': 'multipart/form-data'},
      );

      final response = await _dio.request(path, data: formData, options: options);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  ApiException _handleError(DioException error) {
    final response = error.response;
    final statusCode = response?.statusCode;
    String message = 'An unexpected error occurred.';
    Map<String, dynamic>? errors;

    if (response != null && response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      if (data.containsKey('message')) {
        message = data['message'].toString();
      }
      if (data.containsKey('errors') && data['errors'] is Map<String, dynamic>) {
        errors = data['errors'] as Map<String, dynamic>;
      }
    } else if (error.type == DioExceptionType.connectionTimeout || error.type == DioExceptionType.receiveTimeout) {
      message = 'Connection timed out. Please check your network.';
    } else if (error.error is SocketException) {
      message = 'Could not connect to server. Please ensure backend is running.';
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      errors: errors,
    );
  }
}
```

---

### 3.4 `lib/core/network/websocket_service.dart`
```dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/network/api_endpoints.dart';
import 'package:ludo_vibe/core/storage/storage_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return WebSocketService(storageService: storageService);
});

class WebSocketEvent {
  final String channel;
  final String event;
  final Map<String, dynamic> payload;

  WebSocketEvent({
    required this.channel,
    required this.event,
    required this.payload,
  });

  @override
  String toString() => 'WebSocketEvent(channel: $channel, event: $event, payload: $payload)';
}

class WebSocketService {
  final StorageService _storageService;
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  bool _isConnected = false;

  final _eventController = StreamController<WebSocketEvent>.broadcast();
  final Set<String> _subscribedChannels = {};

  WebSocketService({required StorageService storageService}) : _storageService = storageService;

  Stream<WebSocketEvent> get eventStream => _eventController.stream;
  bool get isConnected => _isConnected;

  Future<void> connect({String? customWsUrl}) async {
    if (_isConnected) return;

    final token = await _storageService.getToken();
    final url = Uri.parse(customWsUrl ?? ApiEndpoints.wsUrl);

    if (kDebugMode) {
      print('🔌 [WS] Connecting to WebSocket at $url');
    }

    try {
      _channel = WebSocketChannel.connect(url);
      _isConnected = true;

      _subscription = _channel?.stream.listen(
        (data) {
          _onMessageReceived(data);
        },
        onError: (error) {
          if (kDebugMode) {
            print('❌ [WS ERR] $error');
          }
          _handleDisconnect();
        },
        onDone: () {
          if (kDebugMode) {
            print('⚠️ [WS] Connection closed by server');
          }
          _handleDisconnect();
        },
      );

      if (token != null) {
        sendEvent('pusher:subscribe', {
          'channel': 'auth',
          'auth': token,
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [WS ERR] Connection failed: $e');
      }
      _handleDisconnect();
    }
  }

  void subscribeToUserChannel(int userId) {
    final channelName = 'private-user.$userId';
    subscribeChannel(channelName);
  }

  void subscribeToRoomChannel(int roomId) {
    final channelName = 'room.$roomId';
    subscribeChannel(channelName);
  }

  void subscribeChannel(String channelName) {
    if (_subscribedChannels.contains(channelName)) return;
    _subscribedChannels.add(channelName);

    if (kDebugMode) {
      print('📡 [WS] Subscribing to channel: $channelName');
    }

    sendEvent('pusher:subscribe', {
      'data': {'channel': channelName}
    });
  }

  void unsubscribeChannel(String channelName) {
    if (!_subscribedChannels.contains(channelName)) return;
    _subscribedChannels.remove(channelName);

    if (kDebugMode) {
      print('🔕 [WS] Unsubscribing from channel: $channelName');
    }

    sendEvent('pusher:unsubscribe', {
      'data': {'channel': channelName}
    });
  }

  void sendEvent(String eventName, Map<String, dynamic> data) {
    if (_channel != null && _isConnected) {
      final payload = jsonEncode({
        'event': eventName,
        'data': data,
      });
      _channel?.sink.add(payload);
    }
  }

  void _onMessageReceived(dynamic rawData) {
    try {
      final Map<String, dynamic> decoded = jsonDecode(rawData.toString());
      final String channelName = decoded['channel'] ?? decoded['event'] ?? 'system';
      final String eventName = decoded['event'] ?? '';
      final Map<String, dynamic> payload = decoded['data'] is Map<String, dynamic>
          ? decoded['data'] as Map<String, dynamic>
          : {'raw': decoded['data']};

      final wsEvent = WebSocketEvent(
        channel: channelName,
        event: eventName,
        payload: payload,
      );

      if (kDebugMode) {
        print('📩 [WS MSG] Event: ${wsEvent.event} | Channel: ${wsEvent.channel}');
      }

      _eventController.add(wsEvent);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [WS] Failed to parse message: $rawData');
      }
    }
  }

  void _handleDisconnect() {
    _isConnected = false;
    _subscription?.cancel();
    _subscription = null;
    _channel = null;
  }

  void disconnect() {
    _subscribedChannels.clear();
    _handleDisconnect();
  }

  void dispose() {
    disconnect();
    _eventController.close();
  }
}
```

---

### 3.5 `test/core_network_storage_test.dart`
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_vibe/core/network/api_endpoints.dart';
import 'package:ludo_vibe/core/storage/storage_service.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/core/network/websocket_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 1 - Core Networking & Storage Tests', () {
    test('ApiEndpoints returns expected path structures', () {
      expect(ApiEndpoints.baseUrl, equals('http://127.0.0.1:8000/api/v1'));
      expect(ApiEndpoints.guest, equals('/auth/guest'));
      expect(ApiEndpoints.roomDetail(42), equals('/rooms/42'));
      expect(ApiEndpoints.friendSendMessage(5), equals('/friends/5/message'));
      expect(ApiEndpoints.deleteMessage(100), equals('/friends/messages/100'));
    });

    test('StorageService generates and persists deviceId', () async {
      final storageService = StorageService();
      final deviceId1 = await storageService.getDeviceId();
      final deviceId2 = await storageService.getDeviceId();

      expect(deviceId1.length, greaterThanOrEqualTo(16));
      expect(deviceId1, equals(deviceId2));
    });

    test('ApiClient handles ApiException creation', () {
      final exception = ApiException(
        message: 'The email field is required.',
        statusCode: 422,
        errors: {
          'email': ['The email field is required.']
        },
      );

      expect(exception.statusCode, equals(422));
      expect(exception.message, contains('email'));
      expect(exception.errors?['email'], isNotNull);
    });

    test('WebSocketService formats events correctly', () {
      final event = WebSocketEvent(
        channel: 'private-user.1',
        event: 'match.found',
        payload: {'room_id': 12, 'game_id': 9},
      );

      expect(event.channel, equals('private-user.1'));
      expect(event.event, equals('match.found'));
      expect(event.payload['room_id'], equals(12));
    });
  });
}
```

---

## 4. Testing & Execution Guide

### Automated Unit Tests
To run unit tests:
```bash
flutter test test/core_network_storage_test.dart
```

### Live Backend Integration & Debug Logs
1. Start Laravel Backend API:
   ```bash
   php artisan serve --host=0.0.0.0 --port=8000
   ```
2. Start Laravel Reverb WebSocket server:
   ```bash
   php artisan reverb:start
   ```
3. Run Flutter App (`flutter run`). Network logs will appear in the debug output:
   - `🌐 [API REQ] POST -> http://127.0.0.1:8000/api/v1/auth/guest`
   - `✅ [API RES] 200 <- http://127.0.0.1:8000/api/v1/auth/guest`
   - `🔌 [WS] Connecting to WebSocket at ws://127.0.0.1:8080/app`
   - `📡 [WS] Subscribing to channel: private-user.1`
   - `📩 [WS MSG] Event: match.found | Channel: private-user.1`
