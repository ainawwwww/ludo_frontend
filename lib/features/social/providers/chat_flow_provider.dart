import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/features/battle/models/room_model.dart';

class ChatFriendModel {
  final int id;
  final String name;
  final String? avatarUrl;
  final bool isOnline;
  final String? currentRoomTitle;
  final int? currentRoomId;
  final bool isFollowed;

  const ChatFriendModel({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.isOnline,
    this.currentRoomTitle,
    this.currentRoomId,
    this.isFollowed = false,
  });

  ChatFriendModel copyWith({
    bool? isOnline,
    String? currentRoomTitle,
    int? currentRoomId,
    bool? isFollowed,
  }) {
    return ChatFriendModel(
      id: id,
      name: name,
      avatarUrl: avatarUrl,
      isOnline: isOnline ?? this.isOnline,
      currentRoomTitle: currentRoomTitle ?? this.currentRoomTitle,
      currentRoomId: currentRoomId ?? this.currentRoomId,
      isFollowed: isFollowed ?? this.isFollowed,
    );
  }
}

class ChatFlowState {
  final String? selectedCountry;
  final String searchQuery;
  final String? activeCategory;
  final List<RoomModel> allRooms;
  final List<RoomModel> recentlyVisited;
  final List<RoomModel> joinedRooms;
  final Set<String> followedHosts;
  final List<ChatFriendModel> friends;

  const ChatFlowState({
    this.selectedCountry,
    this.searchQuery = '',
    this.activeCategory,
    required this.allRooms,
    required this.recentlyVisited,
    required this.joinedRooms,
    required this.followedHosts,
    required this.friends,
  });

  ChatFlowState copyWith({
    String? selectedCountry,
    bool clearCountry = false,
    String? searchQuery,
    String? activeCategory,
    bool clearCategory = false,
    List<RoomModel>? allRooms,
    List<RoomModel>? recentlyVisited,
    List<RoomModel>? joinedRooms,
    Set<String>? followedHosts,
    List<ChatFriendModel>? friends,
  }) {
    return ChatFlowState(
      selectedCountry: clearCountry ? null : (selectedCountry ?? this.selectedCountry),
      searchQuery: searchQuery ?? this.searchQuery,
      activeCategory: clearCategory ? null : (activeCategory ?? this.activeCategory),
      allRooms: allRooms ?? this.allRooms,
      recentlyVisited: recentlyVisited ?? this.recentlyVisited,
      joinedRooms: joinedRooms ?? this.joinedRooms,
      followedHosts: followedHosts ?? this.followedHosts,
      friends: friends ?? this.friends,
    );
  }

  List<RoomModel> getFilteredExploreRooms() {
    return allRooms.where((room) {
      if (selectedCountry != null && room.countryCode != selectedCountry) {
        return false;
      }
      if (activeCategory != null && room.category.toLowerCase() != activeCategory!.toLowerCase()) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matchTitle = room.title.toLowerCase().contains(q);
        final matchTag = room.tags.any((t) => t.toLowerCase().contains(q));
        if (!matchTitle && !matchTag) return false;
      }
      return true;
    }).toList();
  }

  List<RoomModel> getFilteredHotRooms({String? roomQuery, String? country}) {
    var list = List<RoomModel>.from(allRooms);

    // Country filter
    final targetCountry = country ?? selectedCountry;
    if (targetCountry != null && targetCountry.isNotEmpty && targetCountry.toUpperCase() != 'ALL') {
      list = list.where((r) => r.countryCode?.toUpperCase() == targetCountry.toUpperCase()).toList();
    }

    // Room ID / Link / Name search query
    final query = (roomQuery ?? searchQuery).trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((r) {
        // Direct ID match
        if (r.roomId.toString() == query) return true;
        // Room code match (e.g. LV-8891 or 8891)
        if (r.roomCode?.toLowerCase().contains(query) ?? false) return true;
        // Link match (e.g. room/101 or 101 in URL)
        if (query.contains(r.roomId.toString())) return true;
        if (r.roomCode != null && query.contains(r.roomCode!.toLowerCase())) return true;
        // Title or tags match
        if (r.title.toLowerCase().contains(query)) return true;
        if (r.tags.any((t) => t.toLowerCase().contains(query))) return true;
        return false;
      }).toList();
    }

    list.sort((a, b) => b.memberCount.compareTo(a.memberCount));
    return list;
  }

  List<RoomModel> getFollowingRooms() {
    return allRooms.where((r) {
      final host = r.players.firstWhere((p) => p.seatPosition == 1, orElse: () => r.players.first);
      return followedHosts.contains(host.username);
    }).toList();
  }
}

class ChatFlowNotifier extends StateNotifier<ChatFlowState> {
  ChatFlowNotifier() : super(_initialState());

  static ChatFlowState _initialState() {
    final sampleRooms = [
      RoomModel(
        roomId: 101,
        roomCode: 'LV-8891',
        title: 'MADRID🇪🇸 🇵🇰',
        status: 'active',
        category: 'social',
        tags: const ['BIENVENIDOS / WELCOME TO MAD...', 'MADRID', 'VIP'],
        countryCode: 'PK',
        memberCount: 32,
        coverImage: 'assets/graphics/rooms/room_madrid.jpg',
        createdBy: 201,
        players: [
          RoomPlayerModel(
            userId: 201,
            username: 'Ali Khan',
            seatPosition: 1,
            color: 'yellow',
            avatarUrl: 'assets/graphics/profile/avatars/avatar_golden_sheikh.png',
          ),
          RoomPlayerModel(
            userId: 202,
            username: 'Ayesha',
            seatPosition: 2,
            color: 'red',
            avatarUrl: 'assets/graphics/profile/avatars/avatar_royal_queen.png',
          ),
        ],
      ),
      RoomModel(
        roomId: 102,
        roomCode: 'LV-4432',
        title: 'OPEN MINDED_🔥',
        status: 'active',
        category: 'social',
        tags: const ['feel me bebe', 'LateNight'],
        countryCode: 'PK',
        memberCount: 15,
        coverImage: 'assets/graphics/rooms/room_night_couple.jpg',
        createdBy: 205,
        players: [
          RoomPlayerModel(
            userId: 205,
            username: 'Salman Malik',
            seatPosition: 1,
            color: 'yellow',
            avatarUrl: 'assets/graphics/wealthy_avatar.png',
          ),
        ],
      ),
      RoomModel(
        roomId: 103,
        roomCode: 'LV-7761',
        title: 'PUNJAB CAFE🖤',
        status: 'active',
        category: 'friends',
        tags: const ['ہم اپنی ریاست کے نواب لوگ تیرے معیار...', 'Punjab', 'Dosti'],
        countryCode: 'PK',
        memberCount: 13,
        coverImage: 'assets/graphics/rooms/room_punjab.jpg',
        createdBy: 208,
        players: [
          RoomPlayerModel(
            userId: 208,
            username: 'Hamza',
            seatPosition: 1,
            color: 'yellow',
            avatarUrl: 'assets/graphics/profile/avatars/avatar_lion_king.png',
          ),
        ],
      ),
      RoomModel(
        roomId: 104,
        roomCode: 'LV-3120',
        title: '❤️Diamond Heart❤️',
        status: 'active',
        category: 'chat',
        tags: const ['WElLcOME EvErYOne DiaMonD...', 'ROCKSTAR', 'GAMING ROOM'],
        countryCode: 'PK',
        memberCount: 19,
        coverImage: 'assets/graphics/rooms/room_diamond_heart.jpg',
        createdBy: 210,
        players: [
          RoomPlayerModel(
            userId: 210,
            username: 'Rockstar',
            seatPosition: 1,
            color: 'yellow',
            avatarUrl: 'assets/graphics/musician_avatar.png',
          ),
        ],
      ),
      RoomModel(
        roomId: 105,
        roomCode: 'LV-5599',
        title: 'Pakistan Lounge & Dosti Point 🔥',
        status: 'active',
        category: 'social',
        tags: const ['Desi Friends', 'Masti', 'Chai'],
        countryCode: 'PK',
        memberCount: 34,
        coverImage: 'assets/graphics/card_quick_find_friends.png',
        createdBy: 211,
        players: [
          RoomPlayerModel(
            userId: 211,
            username: 'Rohit',
            seatPosition: 1,
            color: 'yellow',
            avatarUrl: 'assets/graphics/profile/avatars/avatar_panda_warrior.png',
          ),
        ],
      ),
      RoomModel(
        roomId: 106,
        roomCode: 'LV-9921',
        title: 'Friends Masti 🎉',
        status: 'active',
        category: 'music',
        tags: const ['Party Music', 'Bollywood', 'Beats'],
        countryCode: 'PK',
        memberCount: 104,
        coverImage: 'assets/graphics/card_quick_enjoy_music.png',
        createdBy: 213,
        players: [
          RoomPlayerModel(
            userId: 213,
            username: 'Tanvir',
            seatPosition: 1,
            color: 'yellow',
            avatarUrl: 'assets/graphics/profile/avatars/avatar_cyber_tiger.png',
          ),
        ],
      ),
      RoomModel(
        roomId: 107,
        roomCode: 'LV-1088',
        title: 'Ludo Masters Club 🎲',
        status: 'active',
        category: 'chat',
        tags: const ['LudoPro', 'Championship', 'India'],
        countryCode: 'IN',
        memberCount: 220,
        coverImage: 'assets/graphics/card_tournament.png',
        createdBy: 214,
        players: [
          RoomPlayerModel(
            userId: 214,
            username: 'Rohit Sharma',
            seatPosition: 1,
            color: 'yellow',
            avatarUrl: 'assets/graphics/profile/avatars/avatar_lion_king.png',
          ),
        ],
      ),
      RoomModel(
        roomId: 108,
        roomCode: 'LV-4011',
        title: 'Delhi Chills & Beats ☕',
        status: 'active',
        category: 'social',
        tags: const ['Delhi', 'Chai', 'Music'],
        countryCode: 'IN',
        memberCount: 65,
        coverImage: 'assets/graphics/card_quick_small_talk.png',
        createdBy: 215,
        players: [
          RoomPlayerModel(
            userId: 215,
            username: 'Pooja',
            seatPosition: 1,
            color: 'yellow',
            avatarUrl: 'assets/graphics/profile/avatars/avatar_royal_queen.png',
          ),
        ],
      ),
      RoomModel(
        roomId: 109,
        roomCode: 'LV-7210',
        title: 'Riyadh VIP Lounge 👑',
        status: 'active',
        category: 'social',
        tags: const ['Riyadh', 'VIP', 'Coffee'],
        countryCode: 'SA',
        memberCount: 95,
        coverImage: 'assets/graphics/card_vip.png',
        createdBy: 216,
        players: [
          RoomPlayerModel(
            userId: 216,
            username: 'Fahad Al-Saud',
            seatPosition: 1,
            color: 'yellow',
            avatarUrl: 'assets/graphics/profile/avatars/avatar_golden_sheikh.png',
          ),
        ],
      ),
      RoomModel(
        roomId: 110,
        roomCode: 'LV-9340',
        title: 'Music Corner & Beats 🎧',
        status: 'active',
        category: 'music',
        tags: const ['Dubai', 'Party', 'Acoustic'],
        countryCode: 'AE',
        memberCount: 180,
        coverImage: 'assets/graphics/card_night_ludo.png',
        createdBy: 217,
        players: [
          RoomPlayerModel(
            userId: 217,
            username: 'DJ Zain',
            seatPosition: 1,
            color: 'yellow',
            avatarUrl: 'assets/graphics/musician_avatar.png',
          ),
        ],
      ),
      RoomModel(
        roomId: 111,
        roomCode: 'LV-5120',
        title: 'Dhaka Friendship Club 🇧🇩',
        status: 'active',
        category: 'friends',
        tags: const ['Bangla', 'Friends', 'Fun'],
        countryCode: 'BD',
        memberCount: 74,
        coverImage: 'assets/graphics/card_team.png',
        createdBy: 218,
        players: [
          RoomPlayerModel(
            userId: 218,
            username: 'Tanvir Ahmed',
            seatPosition: 1,
            color: 'yellow',
            avatarUrl: 'assets/graphics/profile/avatars/avatar_cyber_tiger.png',
          ),
        ],
      ),
    ];

    final initialFriends = [
      const ChatFriendModel(
        id: 301,
        name: 'Salman Malik',
        avatarUrl: 'assets/graphics/wealthy_avatar.png',
        isOnline: true,
        currentRoomTitle: 'Pakistan Lounge 🔥',
        currentRoomId: 102,
        isFollowed: true,
      ),
      const ChatFriendModel(
        id: 302,
        name: 'Sara',
        avatarUrl: 'assets/graphics/profile/avatars/avatar_fox_magician.png',
        isOnline: true,
        currentRoomTitle: 'Chill & Chat Vibes',
        currentRoomId: 101,
        isFollowed: true,
      ),
      const ChatFriendModel(
        id: 303,
        name: 'DJ Zain',
        avatarUrl: 'assets/graphics/musician_avatar.png',
        isOnline: true,
        currentRoomTitle: 'Music Corner & Beats 🎧',
        currentRoomId: 104,
        isFollowed: false,
      ),
      const ChatFriendModel(
        id: 304,
        name: 'Hamza',
        avatarUrl: 'assets/graphics/profile/avatars/avatar_cyber_tiger.png',
        isOnline: false,
        currentRoomTitle: null,
        currentRoomId: null,
        isFollowed: true,
      ),
    ];

    return ChatFlowState(
      allRooms: sampleRooms,
      recentlyVisited: [sampleRooms[0], sampleRooms[1]],
      joinedRooms: [sampleRooms[0]],
      followedHosts: {'Ali Khan', 'Salman Malik'},
      friends: initialFriends,
    );
  }

  void selectCountry(String? countryCode) {
    if (countryCode == null) {
      state = state.copyWith(clearCountry: true);
    } else {
      state = state.copyWith(selectedCountry: countryCode);
    }
  }

  void setFilterCategory(String? category) {
    if (category == null || category == state.activeCategory) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(activeCategory: category);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void visitRoom(RoomModel room) {
    final updatedRecent = [
      room,
      ...state.recentlyVisited.where((r) => r.roomId != room.roomId),
    ];
    state = state.copyWith(recentlyVisited: updatedRecent);
  }

  void toggleFollowHost(String hostName) {
    final updated = Set<String>.from(state.followedHosts);
    if (updated.contains(hostName)) {
      updated.remove(hostName);
    } else {
      updated.add(hostName);
    }

    // Also update friend followed state if matching
    final updatedFriends = state.friends.map((f) {
      if (f.name == hostName) {
        return f.copyWith(isFollowed: updated.contains(hostName));
      }
      return f;
    }).toList();

    state = state.copyWith(
      followedHosts: updated,
      friends: updatedFriends,
    );
  }

  bool isHostFollowed(String hostName) {
    return state.followedHosts.contains(hostName);
  }

  void joinRoom(RoomModel room) {
    if (!state.joinedRooms.any((r) => r.roomId == room.roomId)) {
      state = state.copyWith(joinedRooms: [room, ...state.joinedRooms]);
    }
  }

  RoomModel createRoom({
    required String title,
    required String category,
    required int maxPlayers,
    required int entryFee,
    String? countryCode,
    String? hostUsername,
    String? hostAvatarUrl,
    int? hostUserId,
    String? roomCode,
  }) {
    final newId = 1000 + state.allRooms.length + 1;
    final currentHostName = (hostUsername != null && hostUsername.isNotEmpty) ? hostUsername : 'You (Host)';
    final currentHostId = hostUserId ?? 999;
    final currentAvatar = hostAvatarUrl ?? 'assets/graphics/profile/avatars/avatar_royal_queen.png';
    final code = roomCode ?? '59329311$newId';

    final newRoom = RoomModel(
      roomId: newId,
      roomCode: code,
      title: title.isNotEmpty ? title : currentHostName,
      status: 'active',
      category: category,
      tags: ['Lucky 77', category.toUpperCase()],
      countryCode: countryCode ?? state.selectedCountry ?? 'PK',
      memberCount: 1,
      isMine: true,
      maxPlayers: maxPlayers,
      entryFee: entryFee,
      coverImage: null,
      createdBy: currentHostId,
      players: [
        RoomPlayerModel(
          userId: currentHostId,
          username: currentHostName,
          seatPosition: 1,
          color: 'yellow',
          avatarUrl: currentAvatar,
        ),
      ],
    );

    state = state.copyWith(
      allRooms: [newRoom, ...state.allRooms],
      recentlyVisited: [newRoom, ...state.recentlyVisited.where((r) => r.roomId != newId)],
      joinedRooms: [newRoom, ...state.joinedRooms.where((r) => r.roomId != newId)],
    );

    return newRoom;
  }

  List<RoomModel> getFilteredExploreRooms() {
    return state.allRooms.where((room) {
      if (state.selectedCountry != null && room.countryCode != state.selectedCountry) {
        return false;
      }
      if (state.activeCategory != null && room.category.toLowerCase() != state.activeCategory!.toLowerCase()) {
        return false;
      }
      if (state.searchQuery.isNotEmpty) {
        final q = state.searchQuery.toLowerCase();
        final matchTitle = room.title.toLowerCase().contains(q);
        final matchTag = room.tags.any((t) => t.toLowerCase().contains(q));
        if (!matchTitle && !matchTag) return false;
      }
      return true;
    }).toList();
  }

  List<RoomModel> getFilteredHotRooms({String? roomQuery, String? country}) {
    return state.getFilteredHotRooms(roomQuery: roomQuery, country: country);
  }

  List<RoomModel> getFollowingRooms() {
    return state.allRooms.where((r) {
      final host = r.players.firstWhere((p) => p.seatPosition == 1, orElse: () => r.players.first);
      return state.followedHosts.contains(host.username);
    }).toList();
  }
}

final chatFlowProvider = StateNotifierProvider<ChatFlowNotifier, ChatFlowState>((ref) {
  return ChatFlowNotifier();
});
