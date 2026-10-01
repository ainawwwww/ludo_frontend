import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/core/network/api_endpoints.dart';
import 'package:ludo_vibe/core/network/websocket_service.dart';
import 'package:ludo_vibe/features/auth/providers/auth_provider.dart';
import 'package:ludo_vibe/features/battle/models/room_model.dart';
import 'package:ludo_vibe/features/battle/providers/battle_provider.dart';
import 'package:ludo_vibe/features/social/models/gift_model.dart';
import 'package:ludo_vibe/features/social/providers/chat_flow_provider.dart';
import 'package:ludo_vibe/features/social/widgets/gift_animation_overlay.dart';
import 'package:ludo_vibe/features/social/widgets/gift_bottom_sheet.dart';
import 'package:ludo_vibe/features/social/widgets/reaction_overlay.dart';
import 'package:ludo_vibe/features/social/widgets/room_music_disc.dart';
import 'package:ludo_vibe/features/social/widgets/room_options_dialog.dart';
import 'package:ludo_vibe/features/social/widgets/room_settings_modals.dart';
import 'package:ludo_vibe/features/social/widgets/user_profile_modal.dart';

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

class _RoomDetailScreenState extends ConsumerState<RoomDetailScreen> with TickerProviderStateMixin {
  bool _isMicMuted = false;
  bool _isSpeakerMuted = false;
  bool _showEmojiPicker = false;
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final ReactionOverlayController _reactionController = ReactionOverlayController();
  final GiftAnimationController _giftAnimationController = GiftAnimationController();

  RoomModel? _room;
  final List<_ChatMessageItem> _chatMessages = [];
  StreamSubscription? _wsSubscription;
  Timer? _mockActivityTimer;

  // Pulse animation for host speaking
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Dynamic Room Settings state
  String _roomAnnouncement = 'Add your room announcement here 📝';
  String _roomTag = 'Lucky 77';
  String _roomMicMode = 'Chat - 5 Mics';
  int _membershipFee = 0;
  bool _isMusicPlaying = false;
  String _currentMusicTrack = 'Lofi Chill Lounge';
  bool _isJoined = false;
  int _roomCharm = 115;

  // Locked seats set (Seats 3 and 4 initially locked to match screenshot)
  final Set<int> _lockedSeats = {3, 4};

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _loadRoomDetails();
    _loadChatMessages();
    _setupWebSocketListener();
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    _mockActivityTimer?.cancel();
    _pulseController.dispose();
    _msgController.dispose();
    _scrollController.dispose();
    ref.read(battleLobbyProvider.notifier).leaveRoom(_parsedRoomId);
    super.dispose();
  }

  int get _parsedRoomId => int.tryParse(widget.roomId) ?? 1;

  Future<void> _loadRoomDetails() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post(ApiEndpoints.roomJoinListener(_parsedRoomId));
      if (mounted) {
        setState(() {
          _room = RoomModel.fromJson(response);
          if (_room!.tags.isNotEmpty) {
            _roomTag = _room!.tags.first;
          }
          if (_room!.isMine) {
            _lockedSeats.clear();
          }
        });
        ref.read(chatFlowProvider.notifier).visitRoom(_room!);
      }
    } catch (_) {
      final localRoom = ref.read(chatFlowProvider).allRooms.cast<RoomModel?>().firstWhere(
            (r) => r?.roomId == _parsedRoomId || r?.title == widget.roomTitle,
            orElse: () => null,
          );

      if (localRoom != null && mounted) {
        setState(() {
          _room = localRoom;
          if (localRoom.tags.isNotEmpty) {
            _roomTag = localRoom.tags.first;
          }
          if (localRoom.isMine) {
            _lockedSeats.clear();
          }
        });
        ref.read(chatFlowProvider.notifier).visitRoom(localRoom);
      }
    }
  }

  Future<void> _loadChatMessages() async {
    if (_chatMessages.isEmpty) {
      _chatMessages.add(
        _ChatMessageItem(
          username: 'System',
          message: 'Welcome to ${widget.roomTitle}! Tap a mic seat or type a message.',
          isMe: false,
          isSystem: true,
        ),
      );
    }

    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get(
        ApiEndpoints.chatMessages,
        queryParameters: {'room_id': _parsedRoomId},
      );

      final dataList = response['data'] as List<dynamic>? ?? [];
      final currentUserId = ref.read(authProvider).user?.id;

      if (mounted && dataList.isNotEmpty) {
        setState(() {
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
        final messageType = payload['message_type']?.toString() ?? 'text';
        final sender = payload['user'] as Map<String, dynamic>? ?? payload['sender'] as Map<String, dynamic>?;
        final username = sender?['username'] ?? payload['username'] ?? 'Player';
        final avatarUrl = sender?['avatar_url'] ?? payload['avatar_url'];
        final text = payload['message']?.toString() ?? '';
        final rawSenderId = sender?['id'] ?? payload['user_id'];
        final senderId = rawSenderId is int ? rawSenderId : int.tryParse(rawSenderId?.toString() ?? '');
        final currentUserId = ref.read(authProvider).user?.id;
        final isMe = currentUserId != null && senderId == currentUserId;

        if (mounted && !isMe) {
          if (messageType == 'reaction' || messageType == 'emoji') {
            _reactionController.trigger(text);
          } else if (messageType == 'gift') {
            _reactionController.trigger('🌹');
            setState(() {
              _roomCharm += 10;
              _chatMessages.add(_ChatMessageItem(
                username: username,
                message: text,
                isMe: false,
                isSystem: true,
              ));
            });
            _scrollToBottom();
          } else {
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
        final payload = event.payload;
        final roomMap = payload['room'] as Map<String, dynamic>? ?? payload;
        if (mounted && roomMap.isNotEmpty) {
          setState(() {
            _room = RoomModel.fromJson(roomMap);
          });
        }
      }
    });
  }

  void _setupMockRoomActivity() {
    // If it's my room or user is host, do NOT start mock activity timer
    if (_isHost || (_room?.isMine ?? false)) {
      return;
    }

    final events = [
      () {
        if (!mounted) return;
        _reactionController.trigger('❤️');
        _addSystemMessage('Sara followed the room ✨');
      },
      () {
        if (!mounted) return;
        _reactionController.trigger('🔥');
        setState(() {
          _chatMessages.add(_ChatMessageItem(
            userId: 203,
            username: 'Hamza',
            message: 'Hello everyone in the lobby! 🔥',
            isMe: false,
            avatarUrl: 'assets/graphics/profile/avatars/avatar_cyber_tiger.png',
          ));
        });
        _scrollToBottom();
      },
      () {
        if (!mounted) return;
        final rose = GiftModel.defaultGifts.first;
        final giftEvent = SentGiftEvent(
          id: UniqueKey().toString(),
          gift: rose,
          senderName: 'Hamza',
          recipientName: _hostName,
          timestamp: DateTime.now(),
        );
        _giftAnimationController.show(giftEvent);
        _addSystemMessage('Hamza sent 🌹 Crystal Rose to $_hostName');
      },
    ];

    int eventIndex = 0;
    _mockActivityTimer = Timer.periodic(const Duration(seconds: 16), (timer) {
      if (!mounted) return;
      events[eventIndex % events.length]();
      eventIndex++;
    });
  }

  void _addSystemMessage(String text) {
    if (!mounted) return;
    setState(() {
      _chatMessages.add(_ChatMessageItem(
        username: 'Room Event',
        message: text,
        isMe: false,
        isSystem: true,
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    _msgController.clear();
    setState(() {
      _showEmojiPicker = false;
    });

    final currentUserId = ref.read(authProvider).user?.id ?? 999;
    final currentUsername = ref.read(authProvider).user?.username ?? 'You';

    setState(() {
      _chatMessages.add(_ChatMessageItem(
        userId: currentUserId,
        username: currentUsername,
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

  void _handleSendGift(GiftModel gift, String recipient) {
    final currentUsername = ref.read(authProvider).user?.username ?? 'You';
    final event = SentGiftEvent(
      id: UniqueKey().toString(),
      gift: gift,
      senderName: currentUsername,
      recipientName: recipient,
      timestamp: DateTime.now(),
    );

    _giftAnimationController.show(event);

    setState(() {
      _roomCharm += gift.cost > 0 ? gift.cost : 10;
      _chatMessages.add(_ChatMessageItem(
        username: currentUsername,
        message: 'sent ${gift.name} to $recipient 🎁',
        isMe: true,
        isSystem: true,
        giftAsset: gift.assetPath,
      ));
    });
    _scrollToBottom();

    try {
      final apiClient = ref.read(apiClientProvider);
      apiClient.post(
        ApiEndpoints.chatMessage,
        data: {
          'room_id': _parsedRoomId,
          'message': 'sent ${gift.name} to $recipient 🎁',
          'message_type': 'gift',
        },
      );
    } catch (_) {}
  }

  void _handleReactionTapped(String emoji) {
    _reactionController.trigger(emoji);
    setState(() {
      _showEmojiPicker = false;
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      apiClient.post(
        ApiEndpoints.chatMessage,
        data: {
          'room_id': _parsedRoomId,
          'message': emoji,
          'message_type': 'reaction',
        },
      );
    } catch (_) {}
  }

  Future<void> _handleTakeSeat(int seatIndex) async {
    final currentUserId = ref.read(authProvider).user?.id ?? 999;
    final currentUsername = ref.read(authProvider).user?.username ?? 'You';

    final updatedPlayers = List<RoomPlayerModel>.from(_room?.players ?? []);
    updatedPlayers.removeWhere((p) => p.userId == currentUserId);
    updatedPlayers.add(RoomPlayerModel(
      userId: currentUserId,
      username: currentUsername,
      seatPosition: seatIndex,
      color: 'blue',
      avatarUrl: 'assets/graphics/wealthy_avatar.png',
    ));

    setState(() {
      if (_room != null) {
        _room = RoomModel(
          roomId: _room!.roomId,
          roomCode: _room!.roomCode,
          title: _room!.title,
          status: _room!.status,
          category: _room!.category,
          tags: _room!.tags,
          countryCode: _room!.countryCode,
          memberCount: _room!.memberCount + 1,
          isMine: _room!.isMine,
          players: updatedPlayers,
        );
      }
    });

    _addSystemMessage('$currentUsername took Seat $seatIndex 🎙️');

    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.post(
        ApiEndpoints.roomTakeSeat(_parsedRoomId),
        data: {'seat_position': seatIndex},
      );
    } catch (_) {}
  }

  bool get _isHost {
    final authUser = ref.read(authProvider).user;
    final currentUserId = authUser?.id;
    final currentUsername = authUser?.username;

    // 1. Explicitly marked as user's created room
    if (_room?.isMine == true) return true;

    // 2. Room created by current user
    if (currentUserId != null && _room?.createdBy != null && _room!.createdBy == currentUserId) {
      return true;
    }

    // 3. User is seated at Seat 1 (the Host seat)
    if (_room != null) {
      final seat1 = _room!.players.cast<RoomPlayerModel?>().firstWhere(
            (p) => p?.seatPosition == 1,
            orElse: () => null,
          );
      if (seat1 != null) {
        if (currentUserId != null && seat1.userId == currentUserId) return true;
        if (currentUsername != null &&
            currentUsername.isNotEmpty &&
            seat1.username.toLowerCase() == currentUsername.toLowerCase()) {
          return true;
        }
      }
    }

    // 4. Room title matches current user's name
    if (currentUsername != null &&
        currentUsername.isNotEmpty &&
        widget.roomTitle.toLowerCase() == currentUsername.toLowerCase()) {
      return true;
    }

    return false;
  }

  String get _hostName {
    final host = _room?.players.cast<RoomPlayerModel?>().firstWhere(
          (p) => p?.seatPosition == 1,
          orElse: () => null,
        );
    if (host != null) return host.username;
    if (_isHost) {
      final currentUsername = ref.read(authProvider).user?.username;
      if (currentUsername != null && currentUsername.isNotEmpty) return currentUsername;
    }
    return widget.roomTitle.isNotEmpty ? widget.roomTitle : 'khumaro';
  }

  String get _hostAvatar {
    final host = _room?.players.cast<RoomPlayerModel?>().firstWhere(
          (p) => p?.seatPosition == 1,
          orElse: () => null,
        );
    if (host != null && host.avatarUrl != null) return host.avatarUrl!;
    if (_isHost) {
      final currentAvatar = ref.read(authProvider).user?.avatarUrl;
      if (currentAvatar != null && currentAvatar.isNotEmpty) return currentAvatar;
    }
    return 'assets/graphics/profile/avatars/avatar_royal_queen.png';
  }

  List<String> get _recipientsList {
    final names = <String>['Host ($_hostName)', 'All Seats'];
    for (final p in _room?.players ?? []) {
      if (p.seatPosition != 1 && !names.contains(p.username)) {
        names.add(p.username);
      }
    }
    return names;
  }

  void _openRoomProfile() {
    final authUser = ref.read(authProvider).user;
    final currentUserId = authUser?.id ?? 9958;
    final isHostUser = _isHost;

    final roomToUse = _room ??
        RoomModel(
          roomId: _parsedRoomId,
          roomCode: '59329311$_parsedRoomId',
          title: widget.roomTitle,
          status: 'active',
          category: 'social',
          tags: [_roomTag],
          memberCount: isHostUser ? 1 : 2,
          isMine: isHostUser,
          createdBy: isHostUser ? currentUserId : 204,
          players: [
            RoomPlayerModel(
              userId: isHostUser ? currentUserId : 204,
              username: _hostName,
              seatPosition: 1,
              color: 'yellow',
              avatarUrl: _hostAvatar,
            ),
          ],
        );

    RoomProfileModal.show(
      context,
      room: roomToUse,
      hostName: _hostName,
      announcement: _roomAnnouncement,
      activeTag: _roomTag,
      micMode: _roomMicMode,
      membershipFee: _membershipFee,
      isHost: isHostUser,
      onSettingsUpdated: ({newName, newAnnouncement, newTag, newMicMode, newMembershipFee}) {
        setState(() {
          if (newName != null && newName.isNotEmpty && _room != null) {
            _room = RoomModel(
              roomId: _room!.roomId,
              roomCode: _room!.roomCode,
              title: newName,
              status: _room!.status,
              category: _room!.category,
              tags: _room!.tags,
              memberCount: _room!.memberCount,
              players: _room!.players,
            );
          }
          if (newAnnouncement != null) _roomAnnouncement = newAnnouncement;
          if (newTag != null) _roomTag = newTag;
          if (newMicMode != null) _roomMicMode = newMicMode;
          if (newMembershipFee != null) _membershipFee = newMembershipFee;
        });
      },
    );
  }

  void _showLuckyRewardDialog(double scale) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1D144A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18 * scale)),
        title: Center(
          child: Column(
            children: [
              Text('🎉', style: TextStyle(fontSize: 36 * scale)),
              SizedBox(height: 6 * scale),
              Text(
                'Lucky Room Spin!',
                style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontSize: 16 * scale, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        content: Text(
          'Congratulations! You received +50 Free Gold Coins and a Lucky Charm for active participation in the lobby! 🍀',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Poppins', color: Colors.white70, fontSize: 12 * scale),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD200),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18 * scale)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Claim Reward',
                style: TextStyle(fontFamily: 'Poppins', color: const Color(0xFF2C198E), fontWeight: FontWeight.bold, fontSize: 12 * scale),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;
    final roomCode = _room?.roomCode ?? '59329311691';
    final isHostFollowed = ref.watch(chatFlowProvider).followedHosts.contains(_hostName);

    return Scaffold(
      body: GiftAnimationOverlay(
        controller: _giftAnimationController,
        child: ReactionOverlay(
          controller: _reactionController,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Night City Skyline Background
              _buildNightCitySkylineBackground(),

              // 2. Main Room Content
              SafeArea(
                child: Column(
                  children: [
                    // Top Header Bar
                    _buildTopHeaderBar(roomCode, isHostFollowed, scale),

                    // Mic Seating Layout (1 Large Host Seat + 4 Guest Seats)
                    _buildSeatingLayout(scale),

                    // Room Announcement Bar
                    _buildAnnouncementBar(scale),

                    // Real-time Chat Feed with in-chat action cards
                    Expanded(
                      child: _buildChatFeed(isHostFollowed, scale),
                    ),

                    // Bottom Control & Input Bar
                    _buildBottomControlBar(scale),
                  ],
                ),
              ),

              // 3. Floating Right Action Stack (Spinning Music Disc & Lucky Spin)
              Positioned(
                right: 14 * scale,
                bottom: 64 * scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Lucky Spin / Box Icon
                    GestureDetector(
                      onTap: () => _showLuckyRewardDialog(scale),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 42 * scale,
                            height: 42 * scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF8E2DE2).withOpacity(0.5),
                                  blurRadius: 8 * scale,
                                ),
                              ],
                              border: Border.all(color: const Color(0xFFFFD200), width: 1.5 * scale),
                            ),
                            child: Center(
                              child: Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 22 * scale),
                            ),
                          ),
                          SizedBox(height: 2 * scale),
                          Text(
                            'Lucky s..',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 9 * scale,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(color: Colors.black, blurRadius: 4 * scale),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14 * scale),

                    // Spinning Music Disc Player
                    RoomMusicDisc(
                      isPlaying: _isMusicPlaying,
                      currentTrack: _currentMusicTrack,
                      onPlayPauseChanged: (playing) {
                        setState(() => _isMusicPlaying = playing);
                        _addSystemMessage(playing ? '🎵 Music is now playing in the room' : '🔇 Room music paused');
                      },
                      onTrackSelected: (track) {
                        setState(() {
                          _currentMusicTrack = track;
                          _isMusicPlaying = true;
                        });
                        _addSystemMessage('🎵 Now Playing: $track');
                      },
                    ),
                  ],
                ),
              ),

              // 4. Floating Emoji Bar when toggled
              if (_showEmojiPicker)
                Positioned(
                  bottom: 58 * scale,
                  left: 14 * scale,
                  child: ReactionSelectorBar(
                    scale: scale,
                    onSelectEmoji: _handleReactionTapped,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ======================== Night City Skyline Background ========================
  Widget _buildNightCitySkylineBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF07031E),
            Color(0xFF14083F),
            Color(0xFF200C5E),
            Color(0xFF120638),
          ],
          stops: [0.0, 0.35, 0.75, 1.0],
        ),
      ),
      child: CustomPaint(
        painter: _NightSkyAndCityPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }

  // ======================== Top Header Bar ========================
  Widget _buildTopHeaderBar(String roomCode, bool isHostFollowed, double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 4 * scale),
      child: Row(
        children: [
          // Host Pill (Tapping opens Room Profile Modal)
          Flexible(
            child: GestureDetector(
              onTap: _openRoomProfile,
              child: Container(
                padding: EdgeInsets.only(left: 3 * scale, right: 8 * scale, top: 3 * scale, bottom: 3 * scale),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(20 * scale),
                  border: Border.all(color: Colors.white24, width: 0.8 * scale),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Host Avatar
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 32 * scale,
                          height: 32 * scale,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFFFD200), width: 1.5 * scale),
                          ),
                          child: ClipOval(
                            child: Image.asset(_hostAvatar, fit: BoxFit.cover),
                          ),
                        ),
                        Container(
                          width: 8 * scale,
                          height: 8 * scale,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF00FF88),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 5 * scale),

                    // Room Title & Room ID
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _room?.title ?? widget.roomTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10.5 * scale,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'ID:$roomCode',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 8 * scale,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 6 * scale),

                    // Follow Heart Button
                    GestureDetector(
                      onTap: () {
                        ref.read(chatFlowProvider.notifier).toggleFollowHost(_hostName);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isHostFollowed ? 'Unfollowed $_hostName' : 'Following $_hostName! ❤️'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        width: 22 * scale,
                        height: 22 * scale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isHostFollowed ? const Color(0xFFFF2D75) : Colors.white12,
                        ),
                        child: Icon(
                          isHostFollowed ? Icons.favorite : Icons.favorite_border,
                          color: Colors.white,
                          size: 13 * scale,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),

          // Friends & Requests Button
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Friends & Requests',
            icon: Icon(Icons.person_add_alt_1_rounded, color: const Color(0xFFFFD200), size: 21 * scale),
            onPressed: () => context.push(AppConstants.friendRequestRoute),
          ),
          SizedBox(width: 10 * scale),

          // More Options Button (...)
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(Icons.more_horiz_rounded, color: Colors.white, size: 24 * scale),
            onPressed: () {
              RoomOptionsDialog.show(
                context,
                roomTitle: _room?.title ?? widget.roomTitle,
                roomCode: roomCode,
                hostName: _hostName,
                onLeaveRoom: () => context.pop(),
              );
            },
          ),
          SizedBox(width: 10 * scale),

          // Leave Room Power Button (⏻)
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(Icons.power_settings_new_rounded, color: Colors.white, size: 22 * scale),
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }

  // ======================== Seating Layout ========================
  Widget _buildSeatingLayout(double scale) {
    final currentUserId = ref.watch(authProvider).user?.id ?? 999;
    final players = _room?.players ?? [];

    final guestSeats = [2, 3, 4, 5];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 4 * scale),
      child: Column(
        children: [
          // Top Row: Trophy badge (left) + Audience avatars (right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Trophy pill: 🏆 115 >
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 3 * scale),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(12 * scale),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🏆', style: TextStyle(fontSize: 12 * scale)),
                    SizedBox(width: 4 * scale),
                    Text(
                      '$_roomCharm >',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10 * scale,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFD200),
                      ),
                    ),
                  ],
                ),
              ),

              // Audience Avatars + Counter
              Row(
                children: [
                  ...players.take(2).map((p) => Padding(
                    padding: EdgeInsets.only(right: 3 * scale),
                    child: CircleAvatar(
                      radius: 11 * scale,
                      backgroundImage: AssetImage(p.avatarUrl ?? 'assets/graphics/profile/avatars/avatar_royal_queen.png'),
                    ),
                  )),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6 * scale, vertical: 2 * scale),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10 * scale),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person, color: Colors.white70, size: 10 * scale),
                        SizedBox(width: 2 * scale),
                        Text(
                          '${math.max(players.length, 1)}',
                          style: TextStyle(fontSize: 9 * scale, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 6 * scale),

          // Main Host Seat (Large Circle Centered)
          GestureDetector(
            onTap: _openRoomProfile,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Animated speaking glow ring
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 74 * scale * _pulseAnimation.value,
                          height: 74 * scale * _pulseAnimation.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFFD200).withOpacity(0.6),
                              width: 2 * scale,
                            ),
                          ),
                        );
                      },
                    ),
                    // Host Avatar
                    Container(
                      width: 68 * scale,
                      height: 68 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFFD200), width: 2.5 * scale),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD200).withOpacity(0.4),
                            blurRadius: 10 * scale,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(_hostAvatar, fit: BoxFit.cover),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4 * scale),
                Text(
                  _hostName,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 4 * scale),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12 * scale),

          // Guest Seats Row (4 Seats: 2, 3, 4, 5)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: guestSeats.map((seatIndex) {
              final seated = players.cast<RoomPlayerModel?>().firstWhere(
                    (p) => p?.seatPosition == seatIndex,
                    orElse: () => null,
                  );
              final isLocked = _lockedSeats.contains(seatIndex) && seated == null;

              return _buildGuestSeatItem(
                seatIndex: seatIndex,
                player: seated,
                isLocked: isLocked,
                isMe: seated != null && seated.userId == currentUserId,
                scale: scale,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestSeatItem({
    required int seatIndex,
    required RoomPlayerModel? player,
    required bool isLocked,
    required bool isMe,
    required double scale,
  }) {
    if (player != null) {
      return GestureDetector(
        onTap: () {
          UserProfileModal.show(
            context,
            userId: player.userId,
            username: player.username,
            avatarUrl: player.avatarUrl,
            isHost: false,
          );
        },
        child: Column(
          children: [
            Container(
              width: 48 * scale,
              height: 48 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isMe ? const Color(0xFF00D2FF) : const Color(0xFF56AB2F),
                  width: 2 * scale,
                ),
              ),
              child: ClipOval(
                child: player.avatarUrl != null
                    ? Image.asset(player.avatarUrl!, fit: BoxFit.cover)
                    : const Icon(Icons.person, color: Colors.white),
              ),
            ),
            SizedBox(height: 3 * scale),
            Text(
              player.username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 9 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (isLocked) {
      return GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This mic seat is currently locked by the Host.')),
          );
        },
        child: Column(
          children: [
            Container(
              width: 48 * scale,
              height: 48 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
                border: Border.all(color: Colors.white12, width: 1 * scale),
              ),
              child: Icon(Icons.lock_rounded, color: Colors.white38, size: 20 * scale),
            ),
            SizedBox(height: 3 * scale),
            Text(
              'Locked',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 9 * scale, color: Colors.white38),
            ),
          ],
        ),
      );
    }

    // Open mic seat
    return GestureDetector(
      onTap: () => _handleTakeSeat(seatIndex),
      child: Column(
        children: [
          Container(
            width: 48 * scale,
            height: 48 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
              border: Border.all(color: const Color(0xFF8E2DE2).withOpacity(0.6), width: 1.2 * scale),
            ),
            child: Icon(Icons.mic_none_rounded, color: Colors.white70, size: 22 * scale),
          ),
          SizedBox(height: 3 * scale),
          Text(
            '$seatIndex',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 9.5 * scale, fontWeight: FontWeight.bold, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // ======================== Room Announcement Bar ========================
  Widget _buildAnnouncementBar(double scale) {
    return GestureDetector(
      onTap: _openRoomProfile,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 4 * scale),
        padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
        decoration: BoxDecoration(
          color: const Color(0xFF1E0E52).withOpacity(0.65),
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(color: const Color(0xFF8E2DE2).withOpacity(0.4), width: 0.8 * scale),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6 * scale, vertical: 2 * scale),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF9000), Color(0xFFF05A00)],
                ),
                borderRadius: BorderRadius.circular(8 * scale),
              ),
              child: Text(
                'Announcement',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 8.5 * scale, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            SizedBox(width: 8 * scale),
            Expanded(
              child: Text(
                _roomAnnouncement,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10 * scale,
                  color: Colors.white70,
                ),
              ),
            ),
            Icon(Icons.edit_note_rounded, color: const Color(0xFFFFD200), size: 16 * scale),
          ],
        ),
      ),
    );
  }

  // ======================== Real-time Chat Feed ========================
  Widget _buildChatFeed(bool isHostFollowed, double scale) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12 * scale),
      child: Column(
        children: [
          // Banner notice box: "sent Sara... and chat in a decent manner [Go]"
          Container(
            margin: EdgeInsets.only(bottom: 6 * scale),
            padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 5 * scale),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00FFCC).withOpacity(0.15),
                  const Color(0xFF8E2DE2).withOpacity(0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(color: const Color(0xFF00FFCC).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.security_rounded, color: const Color(0xFF00FFCC), size: 14 * scale),
                SizedBox(width: 6 * scale),
                Expanded(
                  child: Text(
                    'Welcome to $_hostName room! Please chat in a decent manner.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10 * scale, color: Colors.white70, fontFamily: 'Poppins'),
                  ),
                ),
              ],
            ),
          ),

          // Chat messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final chat = _chatMessages[index];
                if (chat.isSystem) {
                  return _buildSystemMessageBubble(chat, scale);
                }
                return _buildUserMessageBubble(chat, scale);
              },
            ),
          ),

          // In-Chat Action Cards (Follow Room & Join Room - Hidden for Host)
          if (!_isHost)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4 * scale),
              child: Row(
                children: [
                  // Follow Room Card
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ref.read(chatFlowProvider.notifier).toggleFollowHost(_hostName);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(isHostFollowed ? 'Unfollowed $_hostName' : 'Following room! ❤️')),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 6 * scale),
                        decoration: BoxDecoration(
                          color: isHostFollowed ? const Color(0xFFFF2D75).withOpacity(0.3) : const Color(0xFF130A3C).withOpacity(0.75),
                          borderRadius: BorderRadius.circular(10 * scale),
                          border: Border.all(color: const Color(0xFFFF2D75).withOpacity(0.8)),
                        ),
                        child: Row(
                          children: [
                            Icon(isHostFollowed ? Icons.favorite : Icons.favorite_border, color: const Color(0xFFFF2D75), size: 14 * scale),
                            SizedBox(width: 4 * scale),
                            Expanded(
                              child: Text(
                                isHostFollowed ? 'Following ❤️' : 'Follow room',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10 * scale,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            CircleAvatar(
                              radius: 9 * scale,
                              backgroundImage: AssetImage(_hostAvatar),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8 * scale),

                  // Join Room Card
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (!_isJoined) {
                          setState(() {
                            _isJoined = true;
                          });
                          if (_room != null) {
                            ref.read(chatFlowProvider.notifier).joinRoom(_room!);
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Joined room as permanent member! 👥')),
                          );
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 6 * scale),
                        decoration: BoxDecoration(
                          color: _isJoined ? const Color(0xFF00FFCC).withOpacity(0.25) : const Color(0xFF130A3C).withOpacity(0.75),
                          borderRadius: BorderRadius.circular(10 * scale),
                          border: Border.all(color: const Color(0xFF00FFCC).withOpacity(0.8)),
                        ),
                        child: Row(
                          children: [
                            Icon(_isJoined ? Icons.check_circle_rounded : Icons.person_add_alt_1_rounded, color: const Color(0xFF00FFCC), size: 14 * scale),
                            SizedBox(width: 4 * scale),
                            Expanded(
                              child: Text(
                                _isJoined ? 'Joined ✅' : 'Join room',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10 * scale,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            CircleAvatar(
                              radius: 9 * scale,
                              backgroundImage: AssetImage(_hostAvatar),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ======================== Bottom Control & Input Bar ========================
  Widget _buildBottomControlBar(double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 6 * scale),
      child: Row(
        children: [
          // 1. Speaker Toggle Button
          _buildCircleIconButton(
            icon: _isSpeakerMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
            color: _isSpeakerMuted ? Colors.white54 : Colors.white,
            scale: scale,
            onTap: () {
              setState(() => _isSpeakerMuted = !_isSpeakerMuted);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isSpeakerMuted ? 'Lobby Audio Muted' : 'Lobby Audio Unmuted 🔊'),
                  duration: const Duration(milliseconds: 800),
                ),
              );
            },
          ),
          SizedBox(width: 6 * scale),

          // 2. Mic Toggle Button
          _buildCircleIconButton(
            icon: _isMicMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
            color: _isMicMuted ? Colors.white54 : const Color(0xFF00FF88),
            scale: scale,
            onTap: () {
              setState(() => _isMicMuted = !_isMicMuted);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isMicMuted ? 'Microphone Muted' : 'Microphone Live 🎙️'),
                  duration: const Duration(milliseconds: 800),
                ),
              );
            },
          ),
          SizedBox(width: 6 * scale),

          // 3. Emoji 😀 Button
          _buildCircleIconButton(
            child: Text('😀', style: TextStyle(fontSize: 16 * scale)),
            scale: scale,
            onTap: () => setState(() => _showEmojiPicker = !_showEmojiPicker),
          ),
          SizedBox(width: 6 * scale),

          // 4. "Say something" Pencil Input Bar
          Expanded(
            child: Container(
              height: 38 * scale,
              padding: EdgeInsets.symmetric(horizontal: 10 * scale),
              decoration: BoxDecoration(
                color: const Color(0xFF0E0730).withOpacity(0.85),
                borderRadius: BorderRadius.circular(19 * scale),
                border: Border.all(color: Colors.white24, width: 0.8 * scale),
              ),
              child: Row(
                children: [
                  Icon(Icons.edit_rounded, color: Colors.white54, size: 14 * scale),
                  SizedBox(width: 6 * scale),
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      style: TextStyle(color: Colors.white, fontSize: 11.5 * scale),
                      cursorColor: const Color(0xFFFFD200),
                      decoration: InputDecoration(
                        hintText: 'Say something',
                        hintStyle: TextStyle(color: Colors.white38, fontSize: 11.5 * scale),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        filled: false,
                        fillColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Icon(Icons.send_rounded, color: const Color(0xFFFFD200), size: 16 * scale),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 6 * scale),

          // 5. Gamepad 🎮 Button (Ludo Match Prompt)
          _buildCircleIconButton(
            icon: Icons.sports_esports_rounded,
            color: const Color(0xFF00FFCC),
            scale: scale,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Quick Ludo mini-game challenge sent to room seats! 🎲')),
              );
            },
          ),
          SizedBox(width: 6 * scale),

          // 6. 3D Gift Box 🎁 Button
          GestureDetector(
            onTap: () {
              GiftBottomSheet.show(
                context,
                recipients: _recipientsList,
                initialRecipient: 'Host ($_hostName)',
                onSendGift: _handleSendGift,
              );
            },
            child: Container(
              width: 42 * scale,
              height: 42 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFFFF2D75), Color(0xFFB1003E)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF2D75).withOpacity(0.5),
                    blurRadius: 8 * scale,
                  ),
                ],
                border: Border.all(color: const Color(0xFFFFD200), width: 1.5 * scale),
              ),
              child: Center(
                child: Image.asset(
                  'assets/graphics/gifts/gift_box.png',
                  width: 24 * scale,
                  height: 24 * scale,
                  errorBuilder: (_, __, ___) => const Icon(Icons.card_giftcard, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIconButton({
    IconData? icon,
    Widget? child,
    Color? color,
    required double scale,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36 * scale,
        height: 36 * scale,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF1B0E4E).withOpacity(0.85),
          border: Border.all(color: Colors.white24, width: 0.8 * scale),
        ),
        child: Center(
          child: child ?? Icon(icon, color: color ?? Colors.white, size: 18 * scale),
        ),
      ),
    );
  }

  Widget _buildSystemMessageBubble(_ChatMessageItem chat, double scale) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6 * scale),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width - 32 * scale),
          padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 3 * scale),
          decoration: BoxDecoration(
            color: const Color(0xFF8E2DE2).withOpacity(0.2),
            borderRadius: BorderRadius.circular(10 * scale),
            border: Border.all(color: const Color(0xFF8E2DE2).withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (chat.giftAsset != null)
                Image.asset(chat.giftAsset!, width: 14 * scale, height: 14 * scale)
              else
                Icon(Icons.stars_rounded, color: const Color(0xFFFFD200), size: 13 * scale),
              SizedBox(width: 4 * scale),
              Flexible(
                child: Text(
                  chat.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10 * scale,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFD200),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserMessageBubble(_ChatMessageItem chat, double scale) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8 * scale),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12 * scale,
            backgroundImage: chat.avatarUrl != null
                ? AssetImage(chat.avatarUrl!)
                : const AssetImage('assets/graphics/wealthy_avatar.png'),
          ),
          SizedBox(width: 6 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      chat.username,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10.5 * scale,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFD200),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2 * scale),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 5 * scale),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10 * scale),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    chat.message,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11 * scale,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
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
  final bool isSystem;
  final String? giftAsset;

  _ChatMessageItem({
    this.userId,
    required this.username,
    this.avatarUrl,
    required this.message,
    required this.isMe,
    this.isSystem = false,
    this.giftAsset,
  });
}

/// Custom painter for starry night sky and illuminated city skyline
class _NightSkyAndCityPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rand = math.Random(42);

    // 1. Paint stars
    final starPaint = Paint()..color = Colors.white;
    for (int i = 0; i < 70; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * (size.height * 0.7);
      final r = (rand.nextDouble() * 1.5) + 0.5;
      final opacity = rand.nextDouble() * 0.7 + 0.3;
      starPaint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), r, starPaint);
    }

    // 2. City Skyline Silhouette at bottom
    final buildingPaint = Paint()..color = const Color(0xFF09031D).withOpacity(0.92);
    final windowPaint = Paint()..color = const Color(0xFF00FFCC).withOpacity(0.6);
    final warmWindowPaint = Paint()..color = const Color(0xFFFFD200).withOpacity(0.6);

    double curX = 0;
    while (curX < size.width) {
      final bWidth = 24.0 + (rand.nextDouble() * 32.0);
      final bHeight = 40.0 + (rand.nextDouble() * 90.0);
      final bTop = size.height - bHeight;

      // Draw building
      canvas.drawRect(Rect.fromLTWH(curX, bTop, bWidth, bHeight), buildingPaint);

      // Draw windows
      for (double wy = bTop + 8; wy < size.height - 12; wy += 10) {
        for (double wx = curX + 5; wx < curX + bWidth - 6; wx += 8) {
          if (rand.nextBool()) {
            final p = rand.nextBool() ? windowPaint : warmWindowPaint;
            canvas.drawRect(Rect.fromLTWH(wx, wy, 3, 4), p);
          }
        }
      }
      curX += bWidth + 2;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
