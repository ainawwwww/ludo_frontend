import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/core/network/api_endpoints.dart';
import 'package:ludo_vibe/core/network/websocket_service.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';
import 'package:ludo_vibe/features/auth/providers/auth_provider.dart';
import 'package:ludo_vibe/features/battle/models/room_model.dart';
import 'package:ludo_vibe/features/social/widgets/user_profile_modal.dart';
import 'package:ludo_vibe/shared/widgets/app_background.dart';

class RoomDetailScreen extends ConsumerStatefulWidget {
  const RoomDetailScreen({
    super.key,
    this.roomTitle = 'Ludo VIP Lounge',
    this.roomId = '1',
  });

  final String roomTitle;
  final String roomId;

  @override
  ConsumerState<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends ConsumerState<RoomDetailScreen> {
  bool _isMicMuted = false;
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  RoomModel? _room;
  bool _isLoadingRoom = true;
  final List<_ChatMessageItem> _chatMessages = [];
  StreamSubscription? _wsSubscription;

  @override
  void initState() {
    super.initState();
    _loadRoomDetails();
    _loadChatMessages();
    _setupWebSocketListener();
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  int get _parsedRoomId => int.tryParse(widget.roomId) ?? 1;

  Future<void> _loadRoomDetails() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      // Call join listener which auto-assigns seat and triggers Reverb broadcast
      final response = await apiClient.post(ApiEndpoints.roomJoinListener(_parsedRoomId));
      if (mounted) {
        setState(() {
          _room = RoomModel.fromJson(response);
          _isLoadingRoom = false;
        });
      }
    } catch (_) {
      try {
        final apiClient = ref.read(apiClientProvider);
        final response = await apiClient.get(ApiEndpoints.roomDetail(_parsedRoomId));
        if (mounted) {
          setState(() {
            _room = RoomModel.fromJson(response);
            _isLoadingRoom = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _isLoadingRoom = false;
          });
        }
      }
    }
  }

  Future<void> _loadChatMessages() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get(
        ApiEndpoints.chatMessages,
        queryParameters: {'room_id': _parsedRoomId},
      );

      final dataList = response['data'] as List<dynamic>? ?? [];
      final currentUserId = ref.read(authProvider).user?.id;

      if (mounted) {
        setState(() {
          _chatMessages.clear();
          for (final item in dataList) {
            final sender = item['user'] as Map<String, dynamic>?;
            final username = sender?['username'] ?? item['username'] ?? 'Player';
            final avatarUrl = sender?['avatar_url'] ?? item['avatar_url'];
            final text = item['message']?.toString() ?? '';
            final rawSenderId = sender?['id'] ?? item['user_id'];
            final senderId = rawSenderId is int ? rawSenderId : int.tryParse(rawSenderId?.toString() ?? '');
            final isMe = currentUserId != null && senderId == currentUserId;
            _chatMessages.add(_ChatMessageItem(
              userId: senderId,
              username: username,
              avatarUrl: avatarUrl,
              message: text,
              isMe: isMe,
            ));
          }
        });
        _scrollToBottom();
      }
    } catch (_) {}
  }

  void _setupWebSocketListener() {
    final ws = ref.read(webSocketServiceProvider);
    if (!ws.isConnected) {
      ws.connect();
    }
    ws.subscribeToRoomChannel(_parsedRoomId);

    _wsSubscription = ws.eventStream.listen((event) {
      if (event.event == 'chat.message' || event.event == 'ChatMessageSent' || event.event == '.chat.message') {
        final payload = event.payload;
        final sender = payload['user'] as Map<String, dynamic>? ?? payload['sender'] as Map<String, dynamic>?;
        final username = sender?['username'] ?? payload['username'] ?? 'Player';
        final avatarUrl = sender?['avatar_url'] ?? payload['avatar_url'];
        final text = payload['message']?.toString() ?? '';
        final rawSenderId = sender?['id'] ?? payload['user_id'];
        final senderId = rawSenderId is int ? rawSenderId : int.tryParse(rawSenderId?.toString() ?? '');
        final currentUserId = ref.read(authProvider).user?.id;
        final isMe = currentUserId != null && senderId == currentUserId;

        if (mounted) {
          // If message is from another user, append to list in real-time
          if (!isMe) {
            setState(() {
              _chatMessages.add(_ChatMessageItem(
                userId: senderId,
                username: username,
                avatarUrl: avatarUrl,
                message: text,
                isMe: false,
              ));
            });
            _scrollToBottom();
          }
        }
      } else if (event.event == 'room.updated' || event.event == 'RoomUpdated' || event.event == '.room.updated') {
        final roomPayload = event.payload['room'] ?? event.payload;
        if (mounted && roomPayload is Map<String, dynamic>) {
          setState(() {
            _room = RoomModel.fromJson(roomPayload);
          });
        }
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    _msgController.clear();
    final currentUser = ref.read(authProvider).user;
    final username = currentUser?.username ?? 'You';
    final avatarUrl = currentUser?.avatarUrl;
    final userId = currentUser?.id;

    // Optimistic local add
    setState(() {
      _chatMessages.add(_ChatMessageItem(
        userId: userId,
        username: username,
        avatarUrl: avatarUrl,
        message: text,
        isMe: true,
      ));
    });
    _scrollToBottom();

    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.post(
        ApiEndpoints.chatMessage,
        data: {
          'room_id': _parsedRoomId,
          'message': text,
          'message_type': 'text',
        },
      );
    } catch (_) {}
  }

  Future<void> _handleTakeSeat(int seatIndex) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post(
        ApiEndpoints.roomTakeSeat(_parsedRoomId),
        data: {'seat_position': seatIndex},
      );
      if (mounted) {
        setState(() {
          _room = RoomModel.fromJson(response);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You are now seated at Seat $seatIndex!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.redAccent),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to take seat'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _handleLeaveSeat() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post(
        ApiEndpoints.roomLeaveSeat(_parsedRoomId),
      );
      if (mounted) {
        setState(() {
          _room = RoomModel.fromJson(response);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Left mic seat'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;
    final roomTitle = _room?.title ?? widget.roomTitle;
    final memberCount = _room?.memberCount ?? 1;
    final roomCode = _room?.roomCode ?? widget.roomId;
    final currentUserId = ref.watch(authProvider).user?.id;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22 * scale),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            roomTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.headingMedium.copyWith(
                              fontSize: 16 * scale,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Code: $roomCode • $memberCount Online',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11 * scale,
                              color: const Color(0xFFB173FF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.share_rounded, color: Colors.white, size: 22 * scale),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Room Code: $roomCode copied to share!'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // 8 Mic Seats Grid (Dynamic & Real)
              Padding(
                padding: EdgeInsets.all(16 * scale),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12 * scale,
                    mainAxisSpacing: 12 * scale,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    final seatPosition = index + 1;
                    final seatedPlayer = _room?.players.cast<RoomPlayerModel?>().firstWhere(
                          (p) => p?.seatPosition == seatPosition,
                          orElse: () => null,
                        );

                    final isHost = seatPosition == 1;
                    final isMySeat = seatedPlayer != null && currentUserId != null && seatedPlayer.userId == currentUserId;

                    return _buildSeatItem(
                      seatIndex: seatPosition,
                      player: seatedPlayer,
                      isHost: isHost,
                      isMySeat: isMySeat,
                      scale: scale,
                    );
                  },
                ),
              ),

              // Real-time Chat Stream
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16 * scale),
                  padding: EdgeInsets.all(12 * scale),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C073E).withOpacity(0.55),
                    borderRadius: BorderRadius.circular(16 * scale),
                    border: Border.all(color: AppColors.primaryBorder.withOpacity(0.3)),
                  ),
                  child: _chatMessages.isNotEmpty
                      ? ListView.builder(
                          controller: _scrollController,
                          itemCount: _chatMessages.length,
                          itemBuilder: (context, index) {
                            final chat = _chatMessages[index];
                            return Padding(
                              padding: EdgeInsets.only(bottom: 8 * scale),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Clickable Avatar / Tag
                                  GestureDetector(
                                    onTap: () {
                                      if (chat.userId != null) {
                                        UserProfileModal.show(
                                          context,
                                          userId: chat.userId!,
                                          username: chat.username,
                                          avatarUrl: chat.avatarUrl,
                                          isHost: chat.userId == _room?.createdBy,
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 6 * scale, vertical: 2 * scale),
                                      margin: EdgeInsets.only(right: 6 * scale),
                                      decoration: BoxDecoration(
                                        color: chat.isMe
                                            ? const Color(0xFFFFD200).withOpacity(0.2)
                                            : const Color(0xFF8E2DE2).withOpacity(0.25),
                                        borderRadius: BorderRadius.circular(6 * scale),
                                        border: Border.all(
                                          color: chat.isMe
                                              ? const Color(0xFFFFD200).withOpacity(0.6)
                                              : const Color(0xFF8E2DE2).withOpacity(0.6),
                                          width: 0.8 * scale,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.person_rounded,
                                            size: 11 * scale,
                                            color: chat.isMe ? const Color(0xFFFFD200) : const Color(0xFFB173FF),
                                          ),
                                          SizedBox(width: 3 * scale),
                                          Text(
                                            chat.username,
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 11.5 * scale,
                                              fontWeight: FontWeight.bold,
                                              color: chat.isMe ? const Color(0xFFFFD200) : const Color(0xFFD6A2E8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Chat text
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 2 * scale),
                                      child: Text(
                                        chat.message,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12 * scale,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            'Welcome to $roomTitle!\nTap an empty seat to join audio/mic or type a message to chat.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12 * scale,
                              color: Colors.white38,
                            ),
                          ),
                        ),
                ),
              ),
              SizedBox(height: 8 * scale),

              // Bottom Control & Input Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                child: Row(
                  children: [
                    // Mic toggle
                    IconButton(
                      icon: Icon(
                        _isMicMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                        color: _isMicMuted ? Colors.white38 : const Color(0xFF56AB2F),
                        size: 26 * scale,
                      ),
                      onPressed: () {
                        setState(() => _isMicMuted = !_isMicMuted);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_isMicMuted ? 'Mic Muted' : 'Mic Live!'),
                            duration: const Duration(milliseconds: 900),
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 4 * scale),

                    // Chat input field
                    Expanded(
                      child: TextField(
                        controller: _msgController,
                        style: TextStyle(color: Colors.white, fontSize: 13 * scale),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: Colors.white38, fontSize: 13 * scale),
                          filled: true,
                          fillColor: const Color(0xFF1C1354),
                          contentPadding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 8 * scale),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20 * scale),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    SizedBox(width: 8 * scale),

                    // Send Button
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: Color(0xFFFF9B63)),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeatItem({
    required int seatIndex,
    required RoomPlayerModel? player,
    required bool isHost,
    required bool isMySeat,
    required double scale,
  }) {
    if (player == null) {
      return GestureDetector(
        onTap: () => _handleTakeSeat(seatIndex),
        child: Column(
          children: [
            Container(
              width: 48 * scale,
              height: 48 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white10,
                border: Border.all(color: Colors.white24),
              ),
              child: Icon(Icons.add_rounded, color: Colors.white38, size: 24 * scale),
            ),
            SizedBox(height: 4 * scale),
            Text(
              'Seat $seatIndex',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 9 * scale, color: Colors.white38),
            ),
          ],
        ),
      );
    }

    final displayName = isHost ? '${player.username} (Host)' : player.username;
    final avatar = player.avatarUrl;

    return GestureDetector(
      onTap: () {
        if (isMySeat && !isHost) {
          showModalBottomSheet(
            context: context,
            backgroundColor: const Color(0xFF1C135C),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * scale)),
            builder: (ctx) => SafeArea(
              child: Wrap(
                children: [
                  ListTile(
                    leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
                    title: const Text('Leave Mic Seat', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(ctx);
                      _handleLeaveSeat();
                    },
                  ),
                ],
              ),
            ),
          );
        } else {
          UserProfileModal.show(
            context,
            userId: player.userId,
            username: player.username,
            avatarUrl: player.avatarUrl,
            isHost: isHost,
          );
        }
      },
      child: Column(
        children: [
          Container(
            width: 48 * scale,
            height: 48 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isHost ? const Color(0xFFFFD200) : (isMySeat ? const Color(0xFF00D2FF) : const Color(0xFF56AB2F)),
                width: 2.0 * scale,
              ),
              boxShadow: [
                BoxShadow(
                  color: isHost
                      ? const Color(0xFFFFD200).withOpacity(0.4)
                      : (isMySeat ? const Color(0xFF00D2FF).withOpacity(0.4) : const Color(0xFF56AB2F).withOpacity(0.4)),
                  blurRadius: 8 * scale,
                ),
              ],
            ),
            child: ClipOval(
              child: avatar != null && avatar.isNotEmpty
                  ? Image.network(
                      avatar,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white),
                    )
                  : const Icon(Icons.person, color: Colors.white),
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 9 * scale,
              fontWeight: FontWeight.bold,
              color: isHost ? const Color(0xFFFFD200) : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessageItem {
  final int? userId;
  final String username;
  final String? avatarUrl;
  final String message;
  final bool isMe;

  _ChatMessageItem({
    this.userId,
    required this.username,
    this.avatarUrl,
    required this.message,
    required this.isMe,
  });
}
