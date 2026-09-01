abstract final class ApiEndpoints {
  // Base URLs (Update host for physical device / emulator testing, e.g. 10.0.2.2 for Android Emulator)
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';
  static const String wsUrl = 'ws://127.0.0.1:8080/app/ludovibekey?protocol=7&client=js&version=8.4.0-reverb&flash=false';
  static const String broadcastingAuth = 'http://127.0.0.1:8000/broadcasting/auth';

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

  // Quick Match Module
  static const String quickMatch = '/quick-match';
  static const String quickMatchJoin = '/quick-match/join';
  static const String quickMatchLeave = '/quick-match/leave';
  static const String quickMatchStatus = '/quick-match/status';
  static const String quickMatchActiveMatch = '/quick-match/active-match';
  static const String quickMatchStart = '/quick-match/start';
  static const String quickMatchState = '/quick-match/state';
  static const String quickMatchRoll = '/quick-match/roll';
  static const String quickMatchMove = '/quick-match/move';
  static const String quickMatchForfeit = '/quick-match/forfeit';
  static const String quickMatchMessage = '/quick-match/message';
  static const String quickMatchMessages = '/quick-match/messages';

  // Rooms Module
  static const String rooms = '/rooms';
  static const String roomsQuickMatch = '/quick-match';
  static const String joinRoom = '/rooms/join';
  static String roomDetail(int id) => '/rooms/$id';
  static String roomJoinListener(int id) => '/rooms/$id/join';
  static String roomTakeSeat(int id) => '/rooms/$id/seat';
  static String roomLeaveSeat(int id) => '/rooms/$id/leave-seat';

  // Lobby Data Module (Phase 1)
  static const String lobbyExplore = '/lobby/explore';
  static const String lobbyHot = '/lobby/hot';
  static const String lobbyMy = '/lobby/my';
  static const String countries = '/countries';

  // Matchmaking
  static const String matchmakingJoin = '/matchmaking/join';
  static const String matchmakingLeave = '/matchmaking/leave';
  static const String matchmakingStatus = '/matchmaking/status';
  static const String matchmakingActiveMatch = '/matchmaking/active-match';

  // Game Engine
  static const String gameStart = '/game/start';
  static const String gameState = '/game/state';
  static const String gameRoll = '/game/roll';
  static const String gameMove = '/game/move';

  // Store
  static const String storeItems = '/store/items';
  static const String storePurchase = '/store/purchase';
  static const String storeInventory = '/store/inventory';

  // Social & Friends
  static const String friends = '/friends';
  static const String friendRequests = '/friends/requests';
  static const String friendRequest = '/friends/request';
  static String friendRespond(int id) => '/friends/$id/respond';
  static String userFollow(int id) => '/users/$id/follow';
  static String userUnfollow(int id) => '/users/$id/unfollow';
  static String userFollowStatus(int id) => '/users/$id/follow-status';

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
