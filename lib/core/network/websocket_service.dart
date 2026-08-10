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

      // Authenticate socket if token exists
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
