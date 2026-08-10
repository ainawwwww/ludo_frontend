import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/core/network/api_endpoints.dart';
import 'package:ludo_vibe/core/network/websocket_service.dart';
import 'package:ludo_vibe/features/social/models/leaderboard_model.dart';
import 'package:ludo_vibe/features/social/models/message_model.dart';

final socialRepositoryProvider = Provider<SocialRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final webSocketService = ref.watch(webSocketServiceProvider);
  return SocialRepository(apiClient: apiClient, webSocketService: webSocketService);
});

final friendsListProvider = FutureProvider.autoDispose<List<FriendModel>>((ref) async {
  final socialRepository = ref.watch(socialRepositoryProvider);
  return await socialRepository.getFriends();
});

final conversationsListProvider = FutureProvider.autoDispose<List<ConversationModel>>((ref) async {
  final socialRepository = ref.watch(socialRepositoryProvider);
  return await socialRepository.getConversations();
});

final leaderboardProvider = FutureProvider.autoDispose.family<List<LeaderboardItemModel>, String>((ref, type) async {
  final socialRepository = ref.watch(socialRepositoryProvider);
  return await socialRepository.getLeaderboard(type: type);
});

final directMessagesProvider = StateNotifierProvider.family<DirectMessagesNotifier, List<MessageModel>, int>((ref, friendId) {
  final socialRepository = ref.watch(socialRepositoryProvider);
  final webSocketService = ref.watch(webSocketServiceProvider);
  return DirectMessagesNotifier(friendId: friendId, socialRepository: socialRepository, webSocketService: webSocketService);
});

class DirectMessagesNotifier extends StateNotifier<List<MessageModel>> {
  final int friendId;
  final SocialRepository _socialRepository;
  final WebSocketService _webSocketService;
  StreamSubscription? _wsSubscription;

  DirectMessagesNotifier({
    required this.friendId,
    required SocialRepository socialRepository,
    required WebSocketService webSocketService,
  })  : _socialRepository = socialRepository,
        _webSocketService = webSocketService,
        super([]) {
    loadMessages();
    _listenToRealtimeMessages();
  }

  Future<void> loadMessages() async {
    try {
      final messages = await _socialRepository.getMessages(friendId);
      state = messages;
    } catch (_) {}
  }

  void _listenToRealtimeMessages() {
    _wsSubscription = _webSocketService.eventStream.listen((event) {
      if (event.event == 'direct.message.sent' || event.event == 'DirectMessageSent') {
        final message = MessageModel.fromJson(event.payload);
        if (message.senderId == friendId || message.receiverId == friendId) {
          state = [...state, message];
        }
      } else if (event.event == 'direct.message.deleted' || event.event == 'DirectMessageDeleted') {
        final deletedId = event.payload['message_id'] is int
            ? event.payload['message_id'] as int
            : int.tryParse(event.payload['message_id']?.toString() ?? '0') ?? 0;
        state = state.where((m) => m.id != deletedId).toList();
      }
    });
  }

  Future<void> sendText(String message) async {
    try {
      final newMsg = await _socialRepository.sendTextMessage(friendId: friendId, message: message);
      state = [...state, newMsg];
    } catch (_) {}
  }

  Future<void> sendVoiceNote(File voiceFile, int durationSeconds) async {
    try {
      final newMsg = await _socialRepository.sendVoiceNote(
        friendId: friendId,
        voiceFile: voiceFile,
        voiceDuration: durationSeconds,
      );
      state = [...state, newMsg];
    } catch (_) {}
  }

  Future<void> deleteMessage(int messageId) async {
    try {
      await _socialRepository.deleteMessage(messageId);
      state = state.where((m) => m.id != messageId).toList();
    } catch (_) {}
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    super.dispose();
  }
}

class SocialRepository {
  final ApiClient _apiClient;
  final WebSocketService _webSocketService;

  SocialRepository({
    required ApiClient apiClient,
    required WebSocketService webSocketService,
  })  : _apiClient = apiClient,
        _webSocketService = webSocketService;

  Future<List<FriendModel>> getFriends() async {
    final response = await _apiClient.get(ApiEndpoints.friends);
    final data = response is Map<String, dynamic> && response.containsKey('data') ? response['data'] : response;

    if (data is List) {
      return data.map((f) => FriendModel.fromJson(f as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<void> sendFriendRequest(int friendId) async {
    await _apiClient.post(
      ApiEndpoints.friendRequest,
      data: {'friend_id': friendId},
    );
  }

  Future<void> respondFriendRequest(int requestId, String status) async {
    await _apiClient.post(
      ApiEndpoints.friendRespond(requestId),
      data: {'status': status},
    );
  }

  Future<List<ConversationModel>> getConversations() async {
    final response = await _apiClient.get(ApiEndpoints.conversations);
    final data = response is Map<String, dynamic> && response.containsKey('data') ? response['data'] : response;

    if (data is List) {
      return data.map((c) => ConversationModel.fromJson(c as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<List<MessageModel>> getMessages(int friendId) async {
    final response = await _apiClient.get(ApiEndpoints.friendGetMessages(friendId));
    final data = response is Map<String, dynamic> && response.containsKey('data') ? response['data'] : response;

    if (data is List) {
      return data.map((m) => MessageModel.fromJson(m as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<MessageModel> sendTextMessage({required int friendId, required String message}) async {
    final response = await _apiClient.post(
      ApiEndpoints.friendSendMessage(friendId),
      data: {
        'type': 'text',
        'message': message,
      },
    );
    return MessageModel.fromJson(response);
  }

  Future<MessageModel> sendVoiceNote({
    required int friendId,
    required File voiceFile,
    required int voiceDuration,
  }) async {
    final response = await _apiClient.uploadMultipart(
      ApiEndpoints.friendSendMessage(friendId),
      fields: {
        'type': 'voice',
        'voice_duration': voiceDuration,
      },
      files: {
        'voice_note': voiceFile,
      },
    );
    return MessageModel.fromJson(response);
  }

  Future<void> deleteMessage(int messageId) async {
    await _apiClient.delete(ApiEndpoints.deleteMessage(messageId));
  }

  Future<List<LeaderboardItemModel>> getLeaderboard({String type = 'global'}) async {
    final response = await _apiClient.get(
      ApiEndpoints.leaderboard,
      queryParameters: {'type': type},
    );
    final data = response is Map<String, dynamic> && response.containsKey('data') ? response['data'] : response;

    if (data is List) {
      return data.map((l) => LeaderboardItemModel.fromJson(l as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
