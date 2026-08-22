import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_vibe/core/network/api_endpoints.dart';
import 'package:ludo_vibe/core/storage/storage_service.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/core/network/websocket_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Phase 1 - Core Networking & Storage Tests', () {
    test('ApiEndpoints returns expected path structures', () {
      expect(ApiEndpoints.baseUrl, equals('http://127.0.0.1:8000/api/v1'));
      expect(ApiEndpoints.broadcastingAuth, equals('http://127.0.0.1:8000/broadcasting/auth'));
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
