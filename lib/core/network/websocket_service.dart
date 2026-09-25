import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/core/network/api_endpoints.dart';
import 'package:ludo_vibe/core/storage/storage_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  final apiClient = ref.watch(apiClientProvider);
  return WebSocketService(
    storageService: storageService,
    apiClient: apiClient,
  );
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
  String toString() =>
      'WebSocketEvent(channel: $channel, event: $event, payload: $payload)';
}

class WebSocketService {
  final StorageService _storageService;
  final ApiClient _apiClient;

  StorageService get storageService => _storageService;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  bool _isConnected = false;
  String? _socketId;

  final _eventController = StreamController<WebSocketEvent>.broadcast();
  final Set<String> _subscribedChannels = {};
  final Set<String> _pendingSubscriptions = {};

  // MatchFound Event Buffer (Addition B)
  Map<String, dynamic>? _lastMatchFoundData;
  DateTime? _lastMatchFoundTime;
  bool _isMatchFoundConsumed = false;

  WebSocketService({
    required StorageService storageService,
    required ApiClient apiClient,
  })  : _storageService = storageService,
        _apiClient = apiClient;

  Stream<WebSocketEvent> get eventStream => _eventController.stream;
  bool get isConnected => _isConnected;
  String? get socketId => _socketId;

  /// Check and consume buffered MatchFound event (valid within 60s)
  Map<String, dynamic>? consumeBufferedMatchFound() {
    if (_lastMatchFoundData != null && !_isMatchFoundConsumed) {
      if (_lastMatchFoundTime != null &&
          DateTime.now().difference(_lastMatchFoundTime!).inSeconds < 60) {
        _isMatchFoundConsumed = true;
        if (kDebugMode) {
          print('⚡ [WS BUFFER] Consumed buffered MatchFound event: $_lastMatchFoundData');
        }
        return _lastMatchFoundData;
      }
    }
    return null;
  }

  /// Clear buffered MatchFound event
  void clearBufferedMatchFound() {
    _lastMatchFoundData = null;
    _lastMatchFoundTime = null;
    _isMatchFoundConsumed = true;
  }

  /// Manually buffer a MatchFound event (e.g. from an HTTP API response)
  void bufferMatchFound(Map<String, dynamic> payload) {
    _lastMatchFoundData = payload;
    _lastMatchFoundTime = DateTime.now();
    _isMatchFoundConsumed = false;
    if (kDebugMode) {
      print('📦 [WS BUFFER] Manually buffered MatchFound: $payload');
    }
  }

  Future<void> connect({String? customWsUrl}) async {
    if (_isConnected) return;

    final url = Uri.parse(customWsUrl ?? ApiEndpoints.wsUrl);

    if (kDebugMode) {
      print('🔌 [WS] Connecting to WebSocket at $url');
    }

    try {
      final channel = WebSocketChannel.connect(url);
      _channel = channel;

      channel.ready.then((_) {
        _isConnected = true;
      }).catchError((error) {
        if (kDebugMode) {
          print('❌ [WS ERR] Connection handshake failed: $error');
        }
        _handleDisconnect();
      });

      _subscription = channel.stream.listen(
        (rawData) {
          _onMessageReceived(rawData);
        },
        onError: (error) {
          if (kDebugMode) {
            print('❌ [WS ERR] Connection error: $error');
          }
          _handleDisconnect();
        },
        onDone: () {
          if (kDebugMode) {
            print('⚠️ [WS] Connection closed by server');
          }
          _handleDisconnect();
        },
        cancelOnError: true,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ [WS ERR] Connection failed: $e');
      }
      _handleDisconnect();
    }
  }

  /// Subscribe to user's private channel: private-user.{userId}
  void subscribeToUserChannel(int userId) {
    subscribeChannel('private-user.$userId');
  }

  /// Subscribe to room channels (both private-room.{roomId} and room.{roomId})
  void subscribeToRoomChannel(int roomId) {
    subscribeChannel('private-room.$roomId');
    subscribeChannel('room.$roomId');
  }

  /// Generic channel subscription logic supporting public and private channels
  Future<void> subscribeChannel(String channelName) async {
    if (_subscribedChannels.contains(channelName)) return;

    final isPrivateChannel = channelName.startsWith('private-') ||
        channelName.startsWith('presence-');

    if (isPrivateChannel && _socketId == null) {
      if (kDebugMode) {
        print(
            '⏳ [WS AUTH] Socket ID not ready yet. Queueing subscription for: $channelName');
      }
      _pendingSubscriptions.add(channelName);
      return;
    }

    _subscribedChannels.add(channelName);

    if (isPrivateChannel) {
      await _subscribePrivateChannel(channelName);
    } else {
      _sendSubscribeEvent(channelName: channelName);
    }
  }

  Future<void> _subscribePrivateChannel(String channelName) async {
    final currentSocketId = _socketId;
    if (currentSocketId == null) {
      if (kDebugMode) {
        print(
            '❌ [WS AUTH] Cannot subscribe to private channel without socket_id: $channelName');
      }
      _subscribedChannels.remove(channelName);
      return;
    }

    try {
      if (kDebugMode) {
        print(
            '🔒 [WS AUTH] Requesting auth token from ${ApiEndpoints.broadcastingAuth} for channel: $channelName (socket_id: $currentSocketId)');
      }

      final response = await _apiClient.post(
        ApiEndpoints.broadcastingAuth,
        data: {
          'socket_id': currentSocketId,
          'channel_name': channelName,
        },
      );

      if (kDebugMode) {
        print('✅ [WS AUTH] Received auth response for $channelName: $response');
      }

      final String? authSignature = response is Map<String, dynamic>
          ? response['auth']?.toString()
          : null;

      if (authSignature == null || authSignature.isEmpty) {
        if (kDebugMode) {
          print(
              '❌ [WS AUTH] Failed to retrieve auth signature for channel: $channelName');
        }
        _subscribedChannels.remove(channelName);
        return;
      }

      final dataMap = <String, dynamic>{
        'channel': channelName,
        'auth': authSignature,
      };

      if (response is Map<String, dynamic> &&
          response.containsKey('channel_data')) {
        dataMap['channel_data'] = response['channel_data'];
      }

      _sendSubscribeEvent(
          channelName: channelName,
          authSignature: authSignature,
          extraData: dataMap);
    } catch (e) {
      if (kDebugMode) {
        print(
            '❌ [WS AUTH] Authentication request failed for channel $channelName: $e');
      }
      _subscribedChannels.remove(channelName);
    }
  }

  void _sendSubscribeEvent(
      {required String channelName,
      String? authSignature,
      Map<String, dynamic>? extraData}) {
    if (kDebugMode) {
      print(
          '📡 [WS] Sending pusher:subscribe for channel: $channelName ${authSignature != null ? "(authenticated)" : "(public)"}');
    }

    final data = extraData ?? {'channel': channelName};
    if (authSignature != null && !data.containsKey('auth')) {
      data['auth'] = authSignature;
    }

    sendRawEvent('pusher:subscribe', data);
  }

  void unsubscribeChannel(String channelName) {
    if (!_subscribedChannels.contains(channelName)) return;
    _subscribedChannels.remove(channelName);
    _pendingSubscriptions.remove(channelName);

    if (kDebugMode) {
      print('🔕 [WS] Unsubscribing from channel: $channelName');
    }

    sendRawEvent('pusher:unsubscribe', {
      'channel': channelName,
    });
  }

  void sendRawEvent(String eventName, Map<String, dynamic> data) {
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
      final String eventName = decoded['event'] ?? '';
      final String channelName = decoded['channel'] ?? 'system';

      dynamic rawPayload = decoded['data'];
      Map<String, dynamic> payload = {};

      if (rawPayload is String) {
        try {
          final decodedPayload = jsonDecode(rawPayload);
          if (decodedPayload is Map<String, dynamic>) {
            payload = decodedPayload;
          } else {
            payload = {'data': rawPayload};
          }
        } catch (_) {
          payload = {'raw': rawPayload};
        }
      } else if (rawPayload is Map<String, dynamic>) {
        payload = rawPayload;
      }

      // 1. Connection Established -> Extract socket_id
      if (eventName == 'pusher:connection_established') {
        final extractedSocketId = payload['socket_id']?.toString();
        _socketId = extractedSocketId;

        if (kDebugMode) {
          print(
              '🔑 [WS AUTH] Connection established. Socket ID received: $_socketId');
        }

        _processPendingSubscriptions();
        return;
      }

      // Heartbeat: Respond to pusher:ping
      if (eventName == 'pusher:ping') {
        sendRawEvent('pusher:pong', {});
        if (kDebugMode) {
          print('🏓 [WS] Responded to pusher:ping with pusher:pong');
        }
        return;
      }

      // 2. Subscription confirmation or failure logging
      if (eventName == 'pusher:subscription_succeeded') {
        if (kDebugMode) {
          print(
              '🎉 [WS AUTH] Subscription succeeded for channel: $channelName');
        }
      } else if (eventName == 'pusher:subscription_error' ||
          eventName == 'pusher:error') {
        if (kDebugMode) {
          print(
              '❌ [WS AUTH] Subscription error for channel: $channelName | Payload: $payload');
        }
      }

      final lowerEvent = eventName.toLowerCase();
      if (lowerEvent.contains('match.found') ||
          lowerEvent.contains('matchfound') ||
          lowerEvent.contains('tournament.match.found')) {
        _lastMatchFoundData = payload;
        _lastMatchFoundTime = DateTime.now();
        _isMatchFoundConsumed = false;
        if (kDebugMode) {
          print('📦 [WS BUFFER] Stored MatchFound in buffer: $payload (event: $eventName)');
        }
      }

      final wsEvent = WebSocketEvent(
        channel: channelName,
        event: eventName,
        payload: payload,
      );

      if (kDebugMode) {
        print(
            '📩 [WS MSG] Event: ${wsEvent.event} | Channel: ${wsEvent.channel}');
      }

      _eventController.add(wsEvent);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [WS] Failed to parse raw message: $rawData | Error: $e');
      }
    }
  }

  void _processPendingSubscriptions() {
    if (_pendingSubscriptions.isEmpty) return;

    final channelsToSubscribe = List<String>.from(_pendingSubscriptions);
    _pendingSubscriptions.clear();

    if (kDebugMode) {
      print(
          '🚀 [WS AUTH] Processing ${channelsToSubscribe.length} pending channel subscriptions...');
    }

    for (final channel in channelsToSubscribe) {
      subscribeChannel(channel);
    }
  }

  void _handleDisconnect() {
    _isConnected = false;
    _socketId = null;
    _subscription?.cancel();
    _subscription = null;
    _channel = null;
  }

  void disconnect() {
    _subscribedChannels.clear();
    _pendingSubscriptions.clear();
    _handleDisconnect();
  }

  void dispose() {
    disconnect();
    _eventController.close();
  }
}
