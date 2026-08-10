# LudoVibe — Phase 2: Complete Code Blocks & Implementation Details Documentation

This document contains complete source code and technical specifications for **Phase 2: Data Models, Feature Repositories, Riverpod Providers, and UI Screen Bindings** in the Flutter `ludo_vibe` application.

> [!NOTE]
> This is a local documentation file for developer reference.

---

## 1. Data Models Source Code

### 1.1 `lib/features/auth/models/user_model.dart`
```dart
class UserModel {
  final int id;
  final String username;
  final String? email;
  final int coins;
  final int diamonds;
  final int level;
  final bool isGuest;
  final String? avatarUrl;
  final String? token;

  UserModel({
    required this.id,
    required this.username,
    this.email,
    required this.coins,
    required this.diamonds,
    required this.level,
    this.isGuest = false,
    this.avatarUrl,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    final userJson = json.containsKey('user') ? json['user'] as Map<String, dynamic> : json;
    final extractedToken = token ?? json['token']?.toString();

    return UserModel(
      id: userJson['id'] is int ? userJson['id'] : int.tryParse(userJson['id'].toString()) ?? 0,
      username: userJson['username']?.toString() ?? 'User',
      email: userJson['email']?.toString(),
      coins: userJson['coins'] is int ? userJson['coins'] : int.tryParse(userJson['coins'].toString()) ?? 0,
      diamonds: userJson['diamonds'] is int ? userJson['diamonds'] : int.tryParse(userJson['diamonds'].toString()) ?? 0,
      level: userJson['level'] is int ? userJson['level'] : int.tryParse(userJson['level'].toString()) ?? 1,
      isGuest: userJson['is_guest'] == true || userJson['is_guest'] == 1,
      avatarUrl: userJson['avatar_url']?.toString(),
      token: extractedToken,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'coins': coins,
      'diamonds': diamonds,
      'level': level,
      'is_guest': isGuest,
      'avatar_url': avatarUrl,
      if (token != null) 'token': token,
    };
  }

  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    int? coins,
    int? diamonds,
    int? level,
    bool? isGuest,
    String? avatarUrl,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      coins: coins ?? this.coins,
      diamonds: diamonds ?? this.diamonds,
      level: level ?? this.level,
      isGuest: isGuest ?? this.isGuest,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      token: token ?? this.token,
    );
  }
}
```

---

### 1.2 `lib/features/profile/models/profile_model.dart`
```dart
class ProfileModel {
  final int id;
  final String name;
  final int level;
  final String? avatarUrl;
  final String? country;
  final String? gender;
  final String? dob;
  final String? bio;
  final int totalGamesPlayed;
  final int totalWins;
  final int totalLosses;
  final double winRate;
  final LeagueInfo? leagueInfo;
  final AchievementsInfo? achievements;

  ProfileModel({
    required this.id,
    required this.name,
    required this.level,
    this.avatarUrl,
    this.country,
    this.gender,
    this.dob,
    this.bio,
    required this.totalGamesPlayed,
    required this.totalWins,
    required this.totalLosses,
    required this.winRate,
    this.leagueInfo,
    this.achievements,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final data = json.containsKey('data') ? json['data'] as Map<String, dynamic> : json;

    return ProfileModel(
      id: data['id'] is int ? data['id'] : int.tryParse(data['id'].toString()) ?? 0,
      name: data['name']?.toString() ?? 'Player',
      level: data['level'] is int ? data['level'] : int.tryParse(data['level'].toString()) ?? 1,
      avatarUrl: data['avatar_url']?.toString(),
      country: data['country']?.toString(),
      gender: data['gender']?.toString(),
      dob: data['dob']?.toString(),
      bio: data['bio']?.toString(),
      totalGamesPlayed: data['total_games_played'] is int ? data['total_games_played'] : int.tryParse(data['total_games_played'].toString()) ?? 0,
      totalWins: data['total_wins'] is int ? data['total_wins'] : int.tryParse(data['total_wins'].toString()) ?? 0,
      totalLosses: data['total_losses'] is int ? data['total_losses'] : int.tryParse(data['total_losses'].toString()) ?? 0,
      winRate: (data['win_rate'] is num) ? (data['win_rate'] as num).toDouble() : double.tryParse(data['win_rate'].toString()) ?? 0.0,
      leagueInfo: data['league_info'] is Map<String, dynamic> ? LeagueInfo.fromJson(data['league_info'] as Map<String, dynamic>) : null,
      achievements: data['achievements'] is Map<String, dynamic> ? AchievementsInfo.fromJson(data['achievements'] as Map<String, dynamic>) : null,
    );
  }
}

class LeagueInfo {
  final String currentTier;
  final int points;
  final String progressStatus;
  final String? nextTier;

  LeagueInfo({
    required this.currentTier,
    required this.points,
    required this.progressStatus,
    this.nextTier,
  });

  factory LeagueInfo.fromJson(Map<String, dynamic> json) {
    return LeagueInfo(
      currentTier: json['current_tier']?.toString() ?? 'Bronze',
      points: json['points'] is int ? json['points'] : int.tryParse(json['points'].toString()) ?? 0,
      progressStatus: json['progress_status']?.toString() ?? 'low',
      nextTier: json['next_tier']?.toString(),
    );
  }
}

class AchievementsInfo {
  final LevelBadge? levelBadge;
  final String? favoriteDice;

  AchievementsInfo({
    this.levelBadge,
    this.favoriteDice,
  });

  factory AchievementsInfo.fromJson(Map<String, dynamic> json) {
    return AchievementsInfo(
      levelBadge: json['level_badge'] is Map<String, dynamic> ? LevelBadge.fromJson(json['level_badge'] as Map<String, dynamic>) : null,
      favoriteDice: json['favorite_dice']?.toString(),
    );
  }
}

class LevelBadge {
  final String name;
  final String icon;
  final int level;

  LevelBadge({
    required this.name,
    required this.icon,
    required this.level,
  });

  factory LevelBadge.fromJson(Map<String, dynamic> json) {
    return LevelBadge(
      name: json['name']?.toString() ?? 'Badge',
      icon: json['icon']?.toString() ?? '',
      level: json['level'] is int ? json['level'] : int.tryParse(json['level'].toString()) ?? 1,
    );
  }
}
```

---

### 1.3 `lib/features/home/models/home_data_model.dart`
```dart
class HomeDataModel {
  final String username;
  final int level;
  final int coins;
  final int diamonds;
  final LeagueSummary? currentLeague;
  final int globalRank;
  final String? avatarUrl;

  HomeDataModel({
    required this.username,
    required this.level,
    required this.coins,
    required this.diamonds,
    this.currentLeague,
    required this.globalRank,
    this.avatarUrl,
  });

  factory HomeDataModel.fromJson(Map<String, dynamic> json) {
    final data = json.containsKey('data') ? json['data'] as Map<String, dynamic> : json;

    return HomeDataModel(
      username: data['username']?.toString() ?? 'Player',
      level: data['level'] is int ? data['level'] : int.tryParse(data['level'].toString()) ?? 1,
      coins: data['coins'] is int ? data['coins'] : int.tryParse(data['coins'].toString()) ?? 0,
      diamonds: data['diamonds'] is int ? data['diamonds'] : int.tryParse(data['diamonds'].toString()) ?? 0,
      currentLeague: data['current_league'] is Map<String, dynamic>
          ? LeagueSummary.fromJson(data['current_league'] as Map<String, dynamic>)
          : null,
      globalRank: data['global_rank'] is int ? data['global_rank'] : int.tryParse(data['global_rank'].toString()) ?? 0,
      avatarUrl: data['avatar_url']?.toString(),
    );
  }
}

class LeagueSummary {
  final String name;
  final String? iconUrl;

  LeagueSummary({
    required this.name,
    this.iconUrl,
  });

  factory LeagueSummary.fromJson(Map<String, dynamic> json) {
    return LeagueSummary(
      name: json['name']?.toString() ?? 'Bronze',
      iconUrl: json['icon_url']?.toString(),
    );
  }
}
```

---

### 1.4 `lib/features/wallet/models/wallet_model.dart`
```dart
class WalletBalanceModel {
  final int coins;
  final int diamonds;

  WalletBalanceModel({
    required this.coins,
    required this.diamonds,
  });

  factory WalletBalanceModel.fromJson(Map<String, dynamic> json) {
    final data = json.containsKey('data') ? json['data'] as Map<String, dynamic> : json;
    return WalletBalanceModel(
      coins: data['coins'] is int ? data['coins'] : int.tryParse(data['coins'].toString()) ?? 0,
      diamonds: data['diamonds'] is int ? data['diamonds'] : int.tryParse(data['diamonds'].toString()) ?? 0,
    );
  }
}

class TransactionModel {
  final String type; // win, loss, purchase, topup, gift, entry_fee
  final String currencyType; // coins, diamonds
  final int amount;
  final String? referenceId;
  final String createdAt;

  TransactionModel({
    required this.type,
    required this.currencyType,
    required this.amount,
    this.referenceId,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      type: json['type']?.toString() ?? 'other',
      currencyType: json['currency_type']?.toString() ?? 'coins',
      amount: json['amount'] is int ? json['amount'] : int.tryParse(json['amount'].toString()) ?? 0,
      referenceId: json['reference_id']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
```

---

### 1.5 `lib/features/shop/models/store_item_model.dart`
```dart
class StoreItemModel {
  final int id;
  final String name;
  final String type; // avatar, dice_skin, board_theme
  final int price;
  final String currencyType; // coins, diamonds
  final String? imageUrl;
  final bool isEquipped;

  StoreItemModel({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.currencyType,
    this.imageUrl,
    this.isEquipped = false,
  });

  factory StoreItemModel.fromJson(Map<String, dynamic> json) {
    return StoreItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? 'Item',
      type: json['type']?.toString() ?? 'dice_skin',
      price: json['price'] is int ? json['price'] : int.tryParse(json['price'].toString()) ?? 0,
      currencyType: json['currency_type']?.toString() ?? 'coins',
      imageUrl: json['image_url']?.toString(),
      isEquipped: json['is_equipped'] == true || json['is_equipped'] == 1,
    );
  }
}
```

---

### 1.6 `lib/features/battle/models/room_model.dart`
```dart
class RoomModel {
  final int roomId;
  final String? roomCode;
  final int? gameId;
  final String status; // waiting, matched, idle, queued
  final int? queuePosition;
  final int? queueSize;
  final List<RoomPlayerModel> players;

  RoomModel({
    required this.roomId,
    this.roomCode,
    this.gameId,
    required this.status,
    this.queuePosition,
    this.queueSize,
    required this.players,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    final data = json.containsKey('data') ? json['data'] as Map<String, dynamic> : json;

    final playersList = (data['players'] as List<dynamic>?)
            ?.map((p) => RoomPlayerModel.fromJson(p as Map<String, dynamic>))
            .toList() ??
        [];

    return RoomModel(
      roomId: data['room_id'] is int ? data['room_id'] : int.tryParse(data['room_id'].toString()) ?? 0,
      roomCode: data['room_code']?.toString(),
      gameId: data['game_id'] is int ? data['game_id'] : int.tryParse(data['game_id'].toString()),
      status: data['status']?.toString() ?? 'waiting',
      queuePosition: data['queue_position'] is int ? data['queue_position'] : int.tryParse(data['queue_position'].toString()),
      queueSize: data['queue_size'] is int ? data['queue_size'] : int.tryParse(data['queue_size'].toString()),
      players: playersList,
    );
  }
}

class RoomPlayerModel {
  final int userId;
  final String username;
  final String? avatarUrl;
  final int seatPosition;
  final String color; // red, green, yellow, blue

  RoomPlayerModel({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.seatPosition,
    required this.color,
  });

  factory RoomPlayerModel.fromJson(Map<String, dynamic> json) {
    return RoomPlayerModel(
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id'].toString()) ?? 0,
      username: json['username']?.toString() ?? 'Player',
      avatarUrl: json['avatar_url']?.toString(),
      seatPosition: json['seat_position'] is int ? json['seat_position'] : int.tryParse(json['seat_position'].toString()) ?? 1,
      color: json['color']?.toString() ?? 'red',
    );
  }
}
```

---

### 1.7 `lib/features/game/models/game_state_model.dart`
```dart
import 'package:ludo_vibe/features/battle/models/room_model.dart';

class GameStateModel {
  final int roomId;
  final int gameId;
  final int currentTurnUserId;
  final int? diceValue;
  final bool hasRolled;
  final List<TokenStateModel> tokens;
  final List<RoomPlayerModel> players;
  final int? winnerUserId;

  GameStateModel({
    required this.roomId,
    required this.gameId,
    required this.currentTurnUserId,
    this.diceValue,
    this.hasRolled = false,
    required this.tokens,
    required this.players,
    this.winnerUserId,
  });

  factory GameStateModel.fromJson(Map<String, dynamic> json) {
    final data = json.containsKey('data') ? json['data'] as Map<String, dynamic> : json;

    final tokensList = (data['tokens'] as List<dynamic>?)
            ?.map((t) => TokenStateModel.fromJson(t as Map<String, dynamic>))
            .toList() ??
        [];

    final playersList = (data['players'] as List<dynamic>?)
            ?.map((p) => RoomPlayerModel.fromJson(p as Map<String, dynamic>))
            .toList() ??
        [];

    return GameStateModel(
      roomId: data['room_id'] is int ? data['room_id'] : int.tryParse(data['room_id'].toString()) ?? 0,
      gameId: data['game_id'] is int ? data['game_id'] : int.tryParse(data['game_id'].toString()) ?? 0,
      currentTurnUserId: data['current_turn_user_id'] is int
          ? data['current_turn_user_id']
          : int.tryParse(data['current_turn_user_id'].toString()) ?? 0,
      diceValue: data['dice_value'] is int ? data['dice_value'] : int.tryParse(data['dice_value'].toString()),
      hasRolled: data['has_rolled'] == true,
      tokens: tokensList,
      players: playersList,
      winnerUserId: data['winner_user_id'] is int ? data['winner_user_id'] : int.tryParse(data['winner_user_id'].toString()),
    );
  }

  GameStateModel copyWith({
    int? roomId,
    int? gameId,
    int? currentTurnUserId,
    int? diceValue,
    bool? hasRolled,
    List<TokenStateModel>? tokens,
    List<RoomPlayerModel>? players,
    int? winnerUserId,
  }) {
    return GameStateModel(
      roomId: roomId ?? this.roomId,
      gameId: gameId ?? this.gameId,
      currentTurnUserId: currentTurnUserId ?? this.currentTurnUserId,
      diceValue: diceValue ?? this.diceValue,
      hasRolled: hasRolled ?? this.hasRolled,
      tokens: tokens ?? this.tokens,
      players: players ?? this.players,
      winnerUserId: winnerUserId ?? this.winnerUserId,
    );
  }
}

class TokenStateModel {
  final int userId;
  final int tokenIndex;
  final int position;
  final bool isHome;
  final bool isSafe;

  TokenStateModel({
    required this.userId,
    required this.tokenIndex,
    required this.position,
    this.isHome = false,
    this.isSafe = false,
  });

  factory TokenStateModel.fromJson(Map<String, dynamic> json) {
    return TokenStateModel(
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id'].toString()) ?? 0,
      tokenIndex: json['token_index'] is int ? json['token_index'] : int.tryParse(json['token_index'].toString()) ?? 0,
      position: json['position'] is int ? json['position'] : int.tryParse(json['position'].toString()) ?? 0,
      isHome: json['is_home'] == true || json['is_home'] == 1,
      isSafe: json['is_safe'] == true || json['is_safe'] == 1,
    );
  }
}
```

---

### 1.8 `lib/features/social/models/message_model.dart`
```dart
class MessageModel {
  final int id;
  final int senderId;
  final int receiverId;
  final String type; // text, voice
  final String? message;
  final String? voiceUrl;
  final int? voiceDuration;
  final bool isRead;
  final String createdAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.type,
    this.message,
    this.voiceUrl,
    this.voiceDuration,
    this.isRead = false,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final data = json.containsKey('data') ? json['data'] as Map<String, dynamic> : json;

    return MessageModel(
      id: data['id'] is int ? data['id'] : int.tryParse(data['id'].toString()) ?? 0,
      senderId: data['sender_id'] is int ? data['sender_id'] : int.tryParse(data['sender_id'].toString()) ?? 0,
      receiverId: data['receiver_id'] is int ? data['receiver_id'] : int.tryParse(data['receiver_id'].toString()) ?? 0,
      type: data['type']?.toString() ?? 'text',
      message: data['message']?.toString(),
      voiceUrl: data['voice_url']?.toString(),
      voiceDuration: data['voice_duration'] is int ? data['voice_duration'] : int.tryParse(data['voice_duration'].toString()),
      isRead: data['is_read'] == true || data['is_read'] == 1,
      createdAt: data['created_at']?.toString() ?? '',
    );
  }
}

class ConversationModel {
  final int friendId;
  final String username;
  final String? avatarUrl;
  final String? lastMessage;
  final String lastMessageType;
  final String lastMessageAt;
  final int unreadCount;

  ConversationModel({
    required this.friendId,
    required this.username,
    this.avatarUrl,
    this.lastMessage,
    required this.lastMessageType,
    required this.lastMessageAt,
    required this.unreadCount,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final friendMap = json['friend'] is Map<String, dynamic> ? json['friend'] as Map<String, dynamic> : {};

    return ConversationModel(
      friendId: friendMap['id'] is int ? friendMap['id'] : int.tryParse(friendMap['id'].toString()) ?? 0,
      username: friendMap['username']?.toString() ?? 'Friend',
      avatarUrl: friendMap['avatar_url']?.toString(),
      lastMessage: json['last_message']?.toString(),
      lastMessageType: json['last_message_type']?.toString() ?? 'text',
      lastMessageAt: json['last_message_at']?.toString() ?? '',
      unreadCount: json['unread_count'] is int ? json['unread_count'] : int.tryParse(json['unread_count'].toString()) ?? 0,
    );
  }
}

class FriendModel {
  final int id;
  final String username;
  final String? avatarUrl;
  final bool isOnline;

  FriendModel({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.isOnline = false,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      username: json['username']?.toString() ?? 'Friend',
      avatarUrl: json['avatar_url']?.toString(),
      isOnline: json['is_online'] == true || json['is_online'] == 1,
    );
  }
}
```

---

### 1.9 `lib/features/social/models/leaderboard_model.dart`
```dart
class LeaderboardItemModel {
  final int rank;
  final int userId;
  final String username;
  final String? avatarUrl;
  final int totalWins;
  final int totalGames;
  final double winRate;

  LeaderboardItemModel({
    required this.rank,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.totalWins,
    required this.totalGames,
    required this.winRate,
  });

  factory LeaderboardItemModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardItemModel(
      rank: json['rank'] is int ? json['rank'] : int.tryParse(json['rank'].toString()) ?? 0,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id'].toString()) ?? 0,
      username: json['username']?.toString() ?? 'Player',
      avatarUrl: json['avatar_url']?.toString(),
      totalWins: json['total_wins'] is int ? json['total_wins'] : int.tryParse(json['total_wins'].toString()) ?? 0,
      totalGames: json['total_games'] is int ? json['total_games'] : int.tryParse(json['total_games'].toString()) ?? 0,
      winRate: (json['win_rate'] is num) ? (json['win_rate'] as num).toDouble() : double.tryParse(json['win_rate'].toString()) ?? 0.0,
    );
  }
}
```

---

## 2. Feature Repositories & Riverpod Providers

### 2.1 `lib/features/auth/providers/auth_provider.dart`
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/core/network/api_endpoints.dart';
import 'package:ludo_vibe/core/network/websocket_service.dart';
import 'package:ludo_vibe/core/storage/storage_service.dart';
import 'package:ludo_vibe/features/auth/models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storageService = ref.watch(storageServiceProvider);
  final webSocketService = ref.watch(webSocketServiceProvider);
  return AuthRepository(
    apiClient: apiClient,
    storageService: storageService,
    webSocketService: webSocketService,
  );
});

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(AuthState()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authRepository.getMe();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(user: null, isLoading: false);
    }
  }

  Future<bool> guestLogin() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authRepository.guestLogin();
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Guest login failed.');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authRepository.login(email: email, password: password);
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Login failed.');
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authRepository.register(
        username: username,
        email: email,
        password: password,
      );
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Registration failed.');
      return false;
    }
  }

  Future<bool> googleSignIn(String idToken) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authRepository.googleSignIn(idToken: idToken);
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Google sign-in failed.');
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = AuthState();
  }
}

class AuthRepository {
  final ApiClient _apiClient;
  final StorageService _storageService;
  final WebSocketService _webSocketService;

  AuthRepository({
    required ApiClient apiClient,
    required StorageService storageService,
    required WebSocketService webSocketService,
  })  : _apiClient = apiClient,
        _storageService = storageService,
        _webSocketService = webSocketService;

  Future<UserModel> guestLogin() async {
    final deviceId = await _storageService.getDeviceId();
    final response = await _apiClient.post(
      ApiEndpoints.guest,
      data: {'device_id': deviceId},
    );

    final user = UserModel.fromJson(response);
    if (user.token != null) {
      await _storageService.saveToken(user.token!);
      await _storageService.saveUserInfo(user.id, user.username);
      
      await _webSocketService.connect();
      _webSocketService.subscribeToUserChannel(user.id);
    }
    return user;
  }

  Future<UserModel> login({required String email, required String password}) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    final user = UserModel.fromJson(response);
    if (user.token != null) {
      await _storageService.saveToken(user.token!);
      await _storageService.saveUserInfo(user.id, user.username);
      
      await _webSocketService.connect();
      _webSocketService.subscribeToUserChannel(user.id);
    }
    return user;
  }

  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: {
        'username': username,
        'email': email,
        'password': password,
        'password_confirmation': password,
      },
    );

    final user = UserModel.fromJson(response);
    if (user.token != null) {
      await _storageService.saveToken(user.token!);
      await _storageService.saveUserInfo(user.id, user.username);
      
      await _webSocketService.connect();
      _webSocketService.subscribeToUserChannel(user.id);
    }
    return user;
  }

  Future<UserModel> googleSignIn({required String idToken}) async {
    final response = await _apiClient.post(
      ApiEndpoints.google,
      data: {'id_token': idToken},
    );

    final user = UserModel.fromJson(response);
    if (user.token != null) {
      await _storageService.saveToken(user.token!);
      await _storageService.saveUserInfo(user.id, user.username);
      
      await _webSocketService.connect();
      _webSocketService.subscribeToUserChannel(user.id);
    }
    return user;
  }

  Future<UserModel?> getMe() async {
    final token = await _storageService.getToken();
    if (token == null || token.isEmpty) return null;

    final response = await _apiClient.get(ApiEndpoints.me);
    final user = UserModel.fromJson(response, token: token);
    
    await _webSocketService.connect();
    _webSocketService.subscribeToUserChannel(user.id);

    return user;
  }

  Future<void> logout() async {
    try {
      await _apiClient.post(ApiEndpoints.logout);
    } catch (_) {}
    _webSocketService.disconnect();
    await _storageService.clearAll();
  }
}
```

---

### 2.2 `lib/features/home/providers/home_provider.dart`
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/core/network/api_endpoints.dart';
import 'package:ludo_vibe/features/home/models/home_data_model.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HomeRepository(apiClient: apiClient);
});

final homeDataProvider = FutureProvider.autoDispose<HomeDataModel>((ref) async {
  final homeRepository = ref.watch(homeRepositoryProvider);
  return await homeRepository.getHomeData();
});

class HomeRepository {
  final ApiClient _apiClient;

  HomeRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<HomeDataModel> getHomeData() async {
    final response = await _apiClient.get(ApiEndpoints.home);
    return HomeDataModel.fromJson(response);
  }
}
```

---

### 2.3 `lib/features/profile/providers/profile_provider.dart`
```dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/core/network/api_endpoints.dart';
import 'package:ludo_vibe/features/profile/models/profile_model.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileRepository(apiClient: apiClient);
});

final profileDataProvider = FutureProvider.autoDispose<ProfileModel>((ref) async {
  final profileRepository = ref.watch(profileRepositoryProvider);
  return await profileRepository.getProfile();
});

class ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<ProfileModel> getProfile() async {
    final response = await _apiClient.get(ApiEndpoints.profile);
    return ProfileModel.fromJson(response);
  }

  Future<ProfileModel> updateProfile({
    String? name,
    File? avatarFile,
    String? gender,
    String? dob,
    String? country,
    String? bio,
  }) async {
    final fields = <String, dynamic>{
      if (name != null) 'name': name,
      if (gender != null) 'gender': gender,
      if (dob != null) 'dob': dob,
      if (country != null) 'country': country,
      if (bio != null) 'bio': bio,
    };

    dynamic response;
    if (avatarFile != null) {
      response = await _apiClient.uploadMultipart(
        ApiEndpoints.profile,
        fields: fields,
        files: {'avatar': avatarFile},
        method: 'PUT',
      );
    } else {
      response = await _apiClient.put(
        ApiEndpoints.profile,
        data: fields,
      );
    }

    return ProfileModel.fromJson(response);
  }
}
```

---

### 2.4 `lib/features/wallet/providers/wallet_provider.dart`
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/core/network/api_endpoints.dart';
import 'package:ludo_vibe/features/wallet/models/wallet_model.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WalletRepository(apiClient: apiClient);
});

final walletBalanceProvider = FutureProvider.autoDispose<WalletBalanceModel>((ref) async {
  final walletRepository = ref.watch(walletRepositoryProvider);
  return await walletRepository.getBalance();
});

final walletTransactionsProvider = FutureProvider.autoDispose<List<TransactionModel>>((ref) async {
  final walletRepository = ref.watch(walletRepositoryProvider);
  return await walletRepository.getTransactions();
});

class WalletRepository {
  final ApiClient _apiClient;

  WalletRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<WalletBalanceModel> getBalance() async {
    final response = await _apiClient.get(ApiEndpoints.walletBalance);
    return WalletBalanceModel.fromJson(response);
  }

  Future<List<TransactionModel>> getTransactions() async {
    final response = await _apiClient.get(ApiEndpoints.walletTransactions);
    final data = response is Map<String, dynamic> && response.containsKey('data') ? response['data'] : response;
    
    if (data is List) {
      return data.map((t) => TransactionModel.fromJson(t as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<WalletBalanceModel> topup({
    required int amount,
    String currencyType = 'coins',
    String paymentMethod = 'test',
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.walletTopup,
      data: {
        'amount': amount,
        'currency_type': currencyType,
        'payment_method': paymentMethod,
      },
    );
    return WalletBalanceModel.fromJson(response);
  }
}
```

---

### 2.5 `lib/features/shop/providers/shop_provider.dart`
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/core/network/api_endpoints.dart';
import 'package:ludo_vibe/features/shop/models/store_item_model.dart';

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ShopRepository(apiClient: apiClient);
});

final storeItemsProvider = FutureProvider.autoDispose<List<StoreItemModel>>((ref) async {
  final shopRepository = ref.watch(shopRepositoryProvider);
  return await shopRepository.getStoreItems();
});

final userInventoryProvider = FutureProvider.autoDispose<List<StoreItemModel>>((ref) async {
  final shopRepository = ref.watch(shopRepositoryProvider);
  return await shopRepository.getInventory();
});

class ShopRepository {
  final ApiClient _apiClient;

  ShopRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<StoreItemModel>> getStoreItems() async {
    final response = await _apiClient.get(ApiEndpoints.storeItems);
    final data = response is Map<String, dynamic> && response.containsKey('data') ? response['data'] : response;
    
    if (data is List) {
      return data.map((item) => StoreItemModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<List<StoreItemModel>> getInventory() async {
    final response = await _apiClient.get(ApiEndpoints.storeInventory);
    final data = response is Map<String, dynamic> && response.containsKey('data') ? response['data'] : response;
    
    if (data is List) {
      return data.map((item) => StoreItemModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<bool> purchaseItem(int itemId) async {
    final response = await _apiClient.post(
      ApiEndpoints.storePurchase,
      data: {'item_id': itemId},
    );
    return response != null;
  }
}
```

---

### 2.6 `lib/features/battle/providers/battle_provider.dart`
```dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/core/network/api_endpoints.dart';
import 'package:ludo_vibe/core/network/websocket_service.dart';
import 'package:ludo_vibe/features/battle/models/room_model.dart';

final battleRepositoryProvider = Provider<BattleRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final webSocketService = ref.watch(webSocketServiceProvider);
  return BattleRepository(apiClient: apiClient, webSocketService: webSocketService);
});

class MatchmakingState {
  final RoomModel? room;
  final bool isQueueing;
  final String? statusMessage;
  final String? error;

  MatchmakingState({
    this.room,
    this.isQueueing = false,
    this.statusMessage,
    this.error,
  });

  MatchmakingState copyWith({
    RoomModel? room,
    bool? isQueueing,
    String? statusMessage,
    String? error,
  }) {
    return MatchmakingState(
      room: room ?? this.room,
      isQueueing: isQueueing ?? this.isQueueing,
      statusMessage: statusMessage,
      error: error,
    );
  }
}

final matchmakingProvider = StateNotifierProvider<MatchmakingNotifier, MatchmakingState>((ref) {
  final battleRepository = ref.watch(battleRepositoryProvider);
  final webSocketService = ref.watch(webSocketServiceProvider);
  return MatchmakingNotifier(battleRepository: battleRepository, webSocketService: webSocketService);
});

class MatchmakingNotifier extends StateNotifier<MatchmakingState> {
  final BattleRepository _battleRepository;
  final WebSocketService _webSocketService;
  StreamSubscription? _wsSubscription;

  MatchmakingNotifier({
    required BattleRepository battleRepository,
    required WebSocketService webSocketService,
  })  : _battleRepository = battleRepository,
        _webSocketService = webSocketService,
        super(MatchmakingState()) {
    _listenToMatchFoundEvents();
  }

  void _listenToMatchFoundEvents() {
    _wsSubscription = _webSocketService.eventStream.listen((event) {
      if (event.event == 'match.found' || event.event == 'MatchFound') {
        final room = RoomModel.fromJson(event.payload);
        state = state.copyWith(
          room: room,
          isQueueing: false,
          statusMessage: 'Match Found! Starting Game...',
        );
      }
    });
  }

  Future<void> joinQuickMatch({int maxPlayers = 2, int entryFee = 0}) async {
    state = state.copyWith(isQueueing: true, statusMessage: 'Searching for players...', error: null);
    try {
      final room = await _battleRepository.joinMatchmaking(maxPlayers: maxPlayers, entryFee: entryFee);
      if (room.status == 'matched') {
        state = state.copyWith(room: room, isQueueing: false, statusMessage: 'Match Found!');
      } else {
        state = state.copyWith(room: room, isQueueing: true, statusMessage: 'Waiting in queue...');
      }
    } on ApiException catch (e) {
      state = state.copyWith(isQueueing: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isQueueing: false, error: 'Failed to join matchmaking.');
    }
  }

  Future<void> leaveQuickMatch() async {
    try {
      await _battleRepository.leaveMatchmaking();
      state = MatchmakingState();
    } catch (_) {}
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    super.dispose();
  }
}

class BattleRepository {
  final ApiClient _apiClient;
  final WebSocketService _webSocketService;

  BattleRepository({
    required ApiClient apiClient,
    required WebSocketService webSocketService,
  })  : _apiClient = apiClient,
        _webSocketService = webSocketService;

  Future<RoomModel> joinMatchmaking({required int maxPlayers, required int entryFee}) async {
    final response = await _apiClient.post(
      ApiEndpoints.matchmakingJoin,
      data: {
        'max_players': maxPlayers,
        'entry_fee': entryFee,
      },
    );
    return RoomModel.fromJson(response);
  }

  Future<void> leaveMatchmaking() async {
    await _apiClient.post(ApiEndpoints.matchmakingLeave);
  }

  Future<RoomModel> createRoom({String type = 'public', int maxPlayers = 4, int entryFee = 0}) async {
    final response = await _apiClient.post(
      ApiEndpoints.rooms,
      data: {
        'type': type,
        'max_players': maxPlayers,
        'entry_fee': entryFee,
      },
    );
    final room = RoomModel.fromJson(response);
    _webSocketService.subscribeToRoomChannel(room.roomId);
    return room;
  }

  Future<RoomModel> joinRoom(String roomCode) async {
    final response = await _apiClient.post(
      ApiEndpoints.joinRoom,
      data: {'room_code': roomCode},
    );
    final room = RoomModel.fromJson(response);
    _webSocketService.subscribeToRoomChannel(room.roomId);
    return room;
  }
}
```

---

### 2.7 `lib/features/game/providers/game_provider.dart`
```dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/core/network/api_endpoints.dart';
import 'package:ludo_vibe/core/network/websocket_service.dart';
import 'package:ludo_vibe/features/game/models/game_state_model.dart';

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final webSocketService = ref.watch(webSocketServiceProvider);
  return GameRepository(apiClient: apiClient, webSocketService: webSocketService);
});

final gameEngineProvider = StateNotifierProvider.family<GameEngineNotifier, GameStateModel?, int>((ref, roomId) {
  final gameRepository = ref.watch(gameRepositoryProvider);
  final webSocketService = ref.watch(webSocketServiceProvider);
  return GameEngineNotifier(roomId: roomId, gameRepository: gameRepository, webSocketService: webSocketService);
});

class GameEngineNotifier extends StateNotifier<GameStateModel?> {
  final int roomId;
  final GameRepository _gameRepository;
  final WebSocketService _webSocketService;
  StreamSubscription? _wsSubscription;
  String? _lastError;

  GameEngineNotifier({
    required this.roomId,
    required GameRepository gameRepository,
    required WebSocketService webSocketService,
  })  : _gameRepository = gameRepository,
        _webSocketService = webSocketService,
        super(null) {
    initGame();
  }

  String? get lastError => _lastError;

  Future<void> initGame() async {
    _webSocketService.subscribeToRoomChannel(roomId);
    _listenToRoomEvents();
    await fetchGameState();
  }

  Future<void> fetchGameState() async {
    try {
      final gameState = await _gameRepository.getGameState(roomId);
      state = gameState;
      _lastError = null;
    } on ApiException catch (e) {
      _lastError = e.message;
    } catch (e) {
      _lastError = 'Failed to fetch game state: $e';
    }
  }

  void _listenToRoomEvents() {
    _wsSubscription = _webSocketService.eventStream.listen((wsEvent) {
      if (wsEvent.channel != 'private-room.$roomId' && wsEvent.channel != 'room.$roomId') return;

      final evt = wsEvent.event.toLowerCase();

      if (evt == 'dice.rolled' || evt == 'dicerolled') {
        final diceValue = wsEvent.payload['dice_value'] is int
            ? wsEvent.payload['dice_value'] as int
            : int.tryParse(wsEvent.payload['dice_value']?.toString() ?? '1') ?? 1;
        final userId = wsEvent.payload['user_id'] is int
            ? wsEvent.payload['user_id'] as int
            : int.tryParse(wsEvent.payload['user_id']?.toString() ?? '0') ?? 0;

        if (state != null) {
          state = state!.copyWith(
            diceValue: diceValue,
            hasRolled: true,
            currentTurnUserId: userId,
          );
        }
      } else if (evt == 'token.moved' || evt == 'tokenmoved' || evt == 'game.started' || evt == 'gamestarted' || evt == 'room.updated' || evt == 'roomupdated') {
        fetchGameState();
      } else if (evt == 'turn.changed' || evt == 'turnchanged') {
        final nextUserId = wsEvent.payload['next_user_id'] is int
            ? wsEvent.payload['next_user_id'] as int
            : int.tryParse(wsEvent.payload['next_user_id']?.toString() ?? '0') ?? 0;

        if (state != null) {
          state = state!.copyWith(
            currentTurnUserId: nextUserId,
            hasRolled: false,
            diceValue: null,
          );
        }
      } else if (evt == 'game.ended' || evt == 'gameended') {
        final winnerId = wsEvent.payload['winner_id'] is int
            ? wsEvent.payload['winner_id'] as int
            : int.tryParse(wsEvent.payload['winner_id']?.toString() ?? '0');

        if (state != null) {
          state = state!.copyWith(winnerUserId: winnerId);
        }
      } else if (evt == 'player.disconnected' || evt == 'playerdisconnected') {
        fetchGameState();
      }
    });
  }

  Future<bool> rollDice() async {
    if (state == null) return false;
    try {
      await _gameRepository.rollDice(roomId);
      _lastError = null;
      return true;
    } on ApiException catch (e) {
      _lastError = e.message;
      return false;
    } catch (e) {
      _lastError = 'Dice roll failed.';
      return false;
    }
  }

  Future<bool> moveToken(int tokenIndex) async {
    if (state == null) return false;
    try {
      await _gameRepository.moveToken(roomId, tokenIndex);
      _lastError = null;
      return true;
    } on ApiException catch (e) {
      _lastError = e.message;
      return false;
    } catch (e) {
      _lastError = 'Token move failed.';
      return false;
    }
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    _webSocketService.unsubscribeChannel('private-room.$roomId');
    super.dispose();
  }
}

class GameRepository {
  final ApiClient _apiClient;
  final WebSocketService _webSocketService;

  GameRepository({
    required ApiClient apiClient,
    required WebSocketService webSocketService,
  })  : _apiClient = apiClient,
        _webSocketService = webSocketService;

  Future<void> startGame(int roomId) async {
    await _apiClient.post(
      ApiEndpoints.gameStart,
      data: {'room_id': roomId},
    );
  }

  Future<GameStateModel> getGameState(int roomId) async {
    final response = await _apiClient.get(
      ApiEndpoints.gameState,
      queryParameters: {'room_id': roomId},
    );
    return GameStateModel.fromJson(response);
  }

  Future<void> rollDice(int roomId) async {
    await _apiClient.post(
      ApiEndpoints.gameRoll,
      data: {'room_id': roomId},
    );
  }

  Future<void> moveToken(int roomId, int tokenIndex) async {
    await _apiClient.post(
      ApiEndpoints.gameMove,
      data: {
        'room_id': roomId,
        'token_index': tokenIndex,
      },
    );
  }
}
```

---

### 2.8 `lib/features/social/providers/social_provider.dart`
```dart
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
```

---

## 3. Phase 2 Unit Tests Source Code

### 3.1 `test/phase_2_models_and_providers_test.dart`
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_vibe/features/auth/models/user_model.dart';
import 'package:ludo_vibe/features/battle/models/room_model.dart';
import 'package:ludo_vibe/features/game/models/game_state_model.dart';
import 'package:ludo_vibe/features/home/models/home_data_model.dart';
import 'package:ludo_vibe/features/profile/models/profile_model.dart';
import 'package:ludo_vibe/features/shop/models/store_item_model.dart';
import 'package:ludo_vibe/features/social/models/leaderboard_model.dart';
import 'package:ludo_vibe/features/social/models/message_model.dart';
import 'package:ludo_vibe/features/wallet/models/wallet_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 2 — Data Models & API Payload Parsing Tests', () {
    test('UserModel parses register/login response correctly', () {
      final json = {
        'user': {
          'id': 101,
          'username': 'TestUser',
          'email': 'test@ludo.com',
          'coins': 5000,
          'diamonds': 50,
          'level': 5,
          'is_guest': false,
        },
        'token': '1|testtoken123'
      };

      final user = UserModel.fromJson(json);
      expect(user.id, equals(101));
      expect(user.username, equals('TestUser'));
      expect(user.coins, equals(5000));
      expect(user.isGuest, isFalse);
      expect(user.token, equals('1|testtoken123'));
    });

    test('ProfileModel parses nested achievements and league info', () {
      final json = {
        'data': {
          'id': 1,
          'name': 'Wania',
          'level': 12,
          'avatar_url': '/avatars/1.png',
          'total_games_played': 40,
          'total_wins': 25,
          'total_losses': 15,
          'win_rate': 62.5,
          'league_info': {
            'current_tier': 'Silver',
            'points': 1200,
            'progress_status': 'mid',
          },
          'achievements': {
            'favorite_dice': 'Golden Dragon'
          }
        }
      };

      final profile = ProfileModel.fromJson(json);
      expect(profile.name, equals('Wania'));
      expect(profile.winRate, equals(62.5));
      expect(profile.leagueInfo?.currentTier, equals('Silver'));
      expect(profile.achievements?.favoriteDice, equals('Golden Dragon'));
    });

    test('HomeDataModel parses dashboard data correctly', () {
      final json = {
        'data': {
          'username': 'Player1',
          'level': 8,
          'coins': 12000,
          'diamonds': 100,
          'global_rank': 42,
          'current_league': {'name': 'Gold'}
        }
      };

      final homeData = HomeDataModel.fromJson(json);
      expect(homeData.username, equals('Player1'));
      expect(homeData.coins, equals(12000));
      expect(homeData.globalRank, equals(42));
      expect(homeData.currentLeague?.name, equals('Gold'));
    });

    test('RoomModel parses matched quick match response', () {
      final json = {
        'data': {
          'status': 'matched',
          'room_id': 12,
          'game_id': 9,
          'players': [
            {'user_id': 1, 'username': 'P1', 'seat_position': 1, 'color': 'red'},
            {'user_id': 2, 'username': 'P2', 'seat_position': 2, 'color': 'green'}
          ]
        }
      };

      final room = RoomModel.fromJson(json);
      expect(room.status, equals('matched'));
      expect(room.roomId, equals(12));
      expect(room.players.length, equals(2));
      expect(room.players.first.color, equals('red'));
    });

    test('GameStateModel parses live turn and token positions', () {
      final json = {
        'data': {
          'room_id': 12,
          'game_id': 9,
          'current_turn_user_id': 1,
          'dice_value': 6,
          'has_rolled': true,
          'tokens': [
            {'user_id': 1, 'token_index': 0, 'position': 5, 'is_home': false}
          ],
          'players': []
        }
      };

      final gameState = GameStateModel.fromJson(json);
      expect(gameState.roomId, equals(12));
      expect(gameState.diceValue, equals(6));
      expect(gameState.hasRolled, isTrue);
      expect(gameState.tokens.first.position, equals(5));
    });

    test('MessageModel parses text and voice note DMs', () {
      final json = {
        'data': {
          'id': 55,
          'sender_id': 1,
          'receiver_id': 2,
          'type': 'voice',
          'voice_url': '/voice/1/test.mp3',
          'voice_duration': 8,
          'created_at': '2026-08-10 12:00:00'
        }
      };

      final message = MessageModel.fromJson(json);
      expect(message.id, equals(55));
      expect(message.type, equals('voice'));
      expect(message.voiceDuration, equals(8));
      expect(message.voiceUrl, contains('test.mp3'));
    });

    test('LeaderboardItemModel parses ranking correctly', () {
      final json = {
        'rank': 1,
        'user_id': 100,
        'username': 'Champ',
        'total_wins': 150,
        'total_games': 200,
        'win_rate': 75.0
      };

      final item = LeaderboardItemModel.fromJson(json);
      expect(item.rank, equals(1));
      expect(item.username, equals('Champ'));
      expect(item.winRate, equals(75.0));
    });
  });
}
```
