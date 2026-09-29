import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/features/auth/screens/splash_screen.dart';
import 'package:ludo_vibe/features/auth/screens/welcome_screen.dart';
import 'package:ludo_vibe/features/battle/screens/battle_lobby_screen.dart';
import 'package:ludo_vibe/features/game/models/ludo_board_args.dart';
import 'package:ludo_vibe/features/game/screens/game_over_screen.dart';
import 'package:ludo_vibe/features/game/screens/ludo_board_screen.dart';
import 'package:ludo_vibe/features/game/screens/ludo_lobby_screen.dart';
import 'package:ludo_vibe/features/game/screens/tip_screen.dart';
import 'package:ludo_vibe/features/game/screens/victory_screen.dart';
import 'package:ludo_vibe/features/game/screens/waiting_room_screen.dart';
import 'package:ludo_vibe/features/game/screens/theme_gallery_screen.dart';
import 'package:ludo_vibe/features/home/screens/events_screen.dart';
import 'package:ludo_vibe/features/home/screens/friends_screen.dart';
import 'package:ludo_vibe/features/home/screens/home_screen.dart';
import 'package:ludo_vibe/features/home/screens/my_friends_screen.dart';
import 'package:ludo_vibe/features/profile/screens/badges_screen.dart';
import 'package:ludo_vibe/features/profile/screens/chat_room_screen.dart';
import 'package:ludo_vibe/features/profile/screens/edit_profile_screen.dart';
import 'package:ludo_vibe/features/profile/screens/favourite_dice_screen.dart';
import 'package:ludo_vibe/features/profile/screens/gifts_screen.dart';
import 'package:ludo_vibe/features/profile/screens/name_plates_screen.dart';
import 'package:ludo_vibe/features/profile/screens/profile_screen.dart';
import 'package:ludo_vibe/features/profile/screens/profile_settings_screen.dart';
import 'package:ludo_vibe/features/profile/screens/account_centre_screen.dart';
import 'package:ludo_vibe/features/profile/screens/privacy_settings_screen.dart';
import 'package:ludo_vibe/features/profile/screens/royal_level_screen.dart';
import 'package:ludo_vibe/features/profile/screens/supported_room_screen.dart';
import 'package:ludo_vibe/features/profile/screens/support_screen.dart';
import 'package:ludo_vibe/features/shop/screens/purchase_modal.dart';
import 'package:ludo_vibe/features/shop/screens/shop_hub_screen.dart';
import 'package:ludo_vibe/features/shop/screens/shop_screen.dart';
import 'package:ludo_vibe/features/shop/screens/subscription_screen.dart';
import 'package:ludo_vibe/features/rooms/models/room_models.dart';
import 'package:ludo_vibe/features/rooms/screens/room_entry_screens.dart';
import 'package:ludo_vibe/features/rooms/screens/room_lobby_screen.dart';
import 'package:ludo_vibe/features/rooms/screens/private_room_lobby_screen.dart';
import 'package:ludo_vibe/features/rooms/screens/private_room_create_screen.dart';
import 'package:ludo_vibe/features/rooms/screens/private_room_join_screen.dart';
import 'package:ludo_vibe/features/rooms/screens/vip_voice_lounge_screen.dart';
import 'package:ludo_vibe/features/social/screens/country_select_screen.dart';
import 'package:ludo_vibe/features/social/screens/create_room_screen.dart';
import 'package:ludo_vibe/features/social/screens/friend_request_screen.dart';
import 'package:ludo_vibe/features/wallet/screens/wallet_screen.dart';
import 'package:ludo_vibe/features/tournament/domain/tournament_mode.dart';
import 'package:ludo_vibe/features/tournament/presentation/screens/tournament_champion_screen.dart';
import 'package:ludo_vibe/features/tournament/presentation/screens/tournament_defeat_screen.dart';
import 'package:ludo_vibe/features/tournament/presentation/screens/tournament_history_screen.dart';
import 'package:ludo_vibe/features/tournament/presentation/screens/tournament_lobby_screen.dart';
import 'package:ludo_vibe/features/tournament/presentation/screens/tournament_matchmaking_screen.dart';
import 'package:ludo_vibe/features/tournament/presentation/screens/tournament_progress_screen.dart';
import 'package:ludo_vibe/features/tournament/presentation/screens/tournament_victory_screen.dart';
import 'package:ludo_vibe/features/tournament/presentation/screens/tournament_vs_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppConstants.splashRoute,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppConstants.splashRoute,
        name: 'splash',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const SplashScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: AppConstants.welcomeRoute,
        name: 'welcome',
        pageBuilder: (context, state) =>
            _fadePage(state, const WelcomeScreen()),
      ),
      GoRoute(
        path: AppConstants.homeRoute,
        name: 'home',
        pageBuilder: (context, state) => _fadePage(state, const HomeScreen()),
      ),
      GoRoute(
        path: AppConstants.eventsRoute,
        name: 'events',
        pageBuilder: (context, state) => _fadePage(state, const EventsScreen()),
      ),
      GoRoute(
        path: AppConstants.profileRoute,
        name: 'profile',
        pageBuilder: (context, state) =>
            _fadePage(state, const ProfileScreen()),
      ),
      GoRoute(
        path: AppConstants.profileSettingsRoute,
        name: 'profile-settings',
        pageBuilder: (context, state) =>
            _fadePage(state, const ProfileSettingsScreen()),
      ),
      GoRoute(
        path: AppConstants.royalLevelRoute,
        name: 'royal-level',
        pageBuilder: (context, state) =>
            _fadePage(state, const RoyalLevelScreen()),
      ),
      GoRoute(
        path: AppConstants.badgesRoute,
        name: 'badges',
        pageBuilder: (context, state) => _fadePage(state, const BadgesScreen()),
      ),
      GoRoute(
        path: AppConstants.favouriteDiceRoute,
        name: 'favourite-dice',
        pageBuilder: (context, state) =>
            _fadePage(state, const FavouriteDiceScreen()),
      ),
      GoRoute(
        path: AppConstants.namePlatesRoute,
        name: 'name-plates',
        pageBuilder: (context, state) =>
            _fadePage(state, const NamePlatesScreen()),
      ),
      GoRoute(
        path: AppConstants.giftsRoute,
        name: 'gifts',
        pageBuilder: (context, state) => _fadePage(state, const GiftsScreen()),
      ),
      GoRoute(
        path: AppConstants.chatRoomRoute,
        name: 'chat-room',
        pageBuilder: (context, state) =>
            _fadePage(state, const ChatRoomScreen()),
      ),
      GoRoute(
        path: AppConstants.supportedRoomRoute,
        name: 'supported-room',
        pageBuilder: (context, state) =>
            _fadePage(state, const SupportedRoomScreen()),
      ),
      GoRoute(
        path: AppConstants.editProfileRoute,
        name: 'edit-profile',
        pageBuilder: (context, state) =>
            _fadePage(state, const EditProfileScreen()),
      ),
      GoRoute(
        path: AppConstants.accountCentreRoute,
        name: 'account-centre',
        pageBuilder: (context, state) =>
            _fadePage(state, const AccountCentreScreen()),
      ),
      GoRoute(
        path: AppConstants.privacySettingsRoute,
        name: 'privacy-settings',
        pageBuilder: (context, state) =>
            _fadePage(state, const PrivacySettingsScreen()),
      ),
      GoRoute(
        path: AppConstants.supportRoute,
        name: 'support',
        pageBuilder: (context, state) =>
            _fadePage(state, const SupportScreen()),
      ),
      GoRoute(
        path: AppConstants.friendsRoute,
        name: 'friends',
        pageBuilder: (context, state) =>
            _fadePage(state, const FriendsScreen()),
      ),
      GoRoute(
        path: AppConstants.myFriendsRoute,
        name: 'my-friends',
        pageBuilder: (context, state) =>
            _fadePage(state, const MyFriendsScreen()),
      ),
      GoRoute(
        path: AppConstants.countrySelectRoute,
        name: 'country-select',
        pageBuilder: (context, state) =>
            _fadePage(state, const CountrySelectScreen()),
      ),
      GoRoute(
        path: AppConstants.battleLobbyRoute,
        name: 'battle-lobby',
        pageBuilder: (context, state) =>
            _fadePage(state, const BattleLobbyScreen()),
      ),
      GoRoute(
        path: AppConstants.createRoomRoute,
        name: 'create-room',
        pageBuilder: (context, state) =>
            _fadePage(state, const CreateRoomScreen()),
      ),
      GoRoute(
        path: AppConstants.privateRoomRoute,
        name: 'private-room',
        pageBuilder: (context, state) =>
            _fadePage(state, const PrivateRoomHubScreen()),
      ),
      GoRoute(
        path: AppConstants.privateRoomCreateRoute,
        name: 'private-room-create',
        pageBuilder: (context, state) =>
            _fadePage(state, const PrivateRoomCreateScreen()),
      ),
      GoRoute(
        path: AppConstants.privateRoomJoinRoute,
        name: 'private-room-join',
        pageBuilder: (context, state) =>
            _fadePage(state, const PrivateRoomJoinScreen()),
      ),
      GoRoute(
        path: AppConstants.privateRoomLobbyRoute,
        name: 'private-room-lobby',
        pageBuilder: (context, state) =>
            _fadePage(state, const PrivateRoomLobbyScreen()),
      ),
      if (kDebugMode) ...[
        GoRoute(
          path: '/debug/mock/private-room-create',
          pageBuilder: (context, state) => _fadePage(
            state,
            const CreateGameRoomScreen(type: RoomType.private),
          ),
        ),
        GoRoute(
          path: '/debug/mock/private-room-join',
          pageBuilder: (context, state) => _fadePage(
            state,
            const JoinGameRoomScreen(type: RoomType.private),
          ),
        ),
        GoRoute(
          path: '/debug/mock/private-room-lobby',
          pageBuilder: (context, state) => _fadePage(
            state,
            const RoomLobbyScreen(type: RoomType.private),
          ),
        ),
      ],
      GoRoute(
        path: AppConstants.vipRoomRoute,
        name: 'vip-room',
        pageBuilder: (context, state) =>
            _fadePage(state, const VipRoomEntryScreen()),
      ),
      GoRoute(
        path: AppConstants.vipRoomBrowserRoute,
        name: 'vip-room-browser',
        pageBuilder: (context, state) =>
            _fadePage(state, const VipRoomBrowserScreen()),
      ),
      GoRoute(
        path: AppConstants.vipRoomCreateRoute,
        name: 'vip-room-create',
        pageBuilder: (context, state) =>
            _fadePage(state, const CreateGameRoomScreen(type: RoomType.vip)),
      ),
      GoRoute(
        path: AppConstants.vipRoomJoinRoute,
        name: 'vip-room-join',
        pageBuilder: (context, state) =>
            _fadePage(state, const JoinGameRoomScreen(type: RoomType.vip)),
      ),
      GoRoute(
        path: AppConstants.vipRoomLobbyRoute,
        name: 'vip-room-lobby',
        pageBuilder: (context, state) =>
            _fadePage(state, const RoomLobbyScreen(type: RoomType.vip)),
      ),
      GoRoute(
        path: AppConstants.vipVoiceLoungeRoute,
        name: 'vip-voice-lounge',
        pageBuilder: (context, state) =>
            _fadePage(state, const VipVoiceLoungeScreen()),
      ),
      GoRoute(
        path: AppConstants.friendRequestRoute,
        name: 'friend-request',
        pageBuilder: (context, state) =>
            _fadePage(state, const FriendRequestScreen()),
      ),
      GoRoute(
        path: AppConstants.ludoBoardRoute,
        name: 'ludo-board',
        pageBuilder: (context, state) {
          final args = state.extra is LudoBoardArgs
              ? state.extra as LudoBoardArgs
              : (state.extra is Map<String, dynamic>
                  ? LudoBoardArgs.fromMap(state.extra as Map<String, dynamic>)
                  : const LudoBoardArgs());

          return _fadePage(
            state,
            LudoBoardScreen(
              playerCount: args.players,
              betAmount: args.bet,
              roomId: args.roomId,
              gameId: args.gameId,
              isOnline: args.isOnline,
              isTournament: args.isTournament,
              tournamentRound: args.tournamentRound,
              tournamentMode: args.tournamentMode,
              roomMode: args.roomMode,
              roomCode: args.roomCode,
            ),
          );
        },
      ),
      GoRoute(
        path: AppConstants.ludoLobbyRoute,
        name: 'ludo-lobby',
        pageBuilder: (context, state) =>
            _fadePage(state, const LudoLobbyScreen()),
      ),
      GoRoute(
        path: AppConstants.waitingRoomRoute,
        name: 'waiting-room',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final int players = extra?['players'] ?? 4;
          final int bet = extra?['bet'] ?? 500;
          final Map<String, dynamic>? initialMatchData =
              extra?['initialMatchData'] as Map<String, dynamic>?;
          return _fadePage(
            state,
            WaitingRoomScreen(
              playerCount: players,
              betAmount: bet,
              initialMatchData: initialMatchData,
            ),
          );
        },
      ),
      GoRoute(
        path: AppConstants.victoryRoute,
        name: 'victory',
        pageBuilder: (context, state) =>
            _fadePage(state, const VictoryScreen()),
      ),
      GoRoute(
        path: AppConstants.gameOverRoute,
        name: 'game-over',
        pageBuilder: (context, state) =>
            _fadePage(state, const GameOverScreen()),
      ),
      GoRoute(
        path: AppConstants.goldShopRoute,
        name: 'shop',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          if (extra != null && extra.containsKey('tab')) {
            final int initialTab =
                extra['tab'] is int ? extra['tab'] as int : 0;
            return _fadePage(state, ShopScreen(initialTabIndex: initialTab));
          }
          return _fadePage(state, const ShopHubScreen());
        },
      ),
      GoRoute(
        path: AppConstants.purchaseRoute,
        name: 'purchase',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final int initialTab =
              extra?['tab'] is int ? extra!['tab'] as int : 0;
          return _fadePage(state, PurchaseScreen(initialTabIndex: initialTab));
        },
      ),
      GoRoute(
        path: AppConstants.subscriptionRoute,
        name: 'subscription',
        pageBuilder: (context, state) =>
            _fadePage(state, const SubscriptionScreen()),
      ),
      GoRoute(
        path: AppConstants.roomDetailRoute,
        name: 'room-detail',
        pageBuilder: (context, state) =>
            _fadePage(state, const VipVoiceLoungeScreen()),
      ),
      GoRoute(
        path: AppConstants.walletRoute,
        name: 'wallet',
        pageBuilder: (context, state) => _fadePage(state, const WalletScreen()),
      ),
      GoRoute(
        path: AppConstants.tipRoute,
        name: 'tip',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const TipScreen(),
          opaque: false,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: AppConstants.tournamentLobbyRoute,
        name: 'tournament-lobby',
        pageBuilder: (context, state) =>
            _fadePage(state, const TournamentLobbyScreen()),
      ),
      GoRoute(
        path: AppConstants.tournamentProgressRoute,
        name: 'tournament-progress',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final modeStr = extra?['mode']?.toString() ?? 'classic';
          final mode = modeStr == 'quick'
              ? TournamentMode.quick
              : TournamentMode.classic;
          return _fadePage(
            state,
            TournamentProgressScreen(mode: mode),
          );
        },
      ),
      GoRoute(
        path: AppConstants.tournamentMatchmakingRoute,
        name: 'tournament-matchmaking',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final round = extra?['round'] is int ? extra!['round'] as int : 1;
          final modeStr = extra?['mode']?.toString() ?? 'classic';
          final tournamentId = extra?['tournamentId'];
          return _fadePage(
            state,
            TournamentMatchmakingScreen(
              round: round,
              modeName: modeStr,
              tournamentId: tournamentId,
            ),
          );
        },
      ),
      GoRoute(
        path: AppConstants.tournamentVsRoute,
        name: 'tournament-vs',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final round = extra?['round'] is int ? extra!['round'] as int : 1;
          final modeStr = extra?['mode']?.toString() ?? 'classic';
          final roomId = extra?['roomId'] as int?;
          final gameId = extra?['gameId'] as int?;
          final opponentName = extra?['opponentName']?.toString() ?? 'Sultan_Ludo';
          final opponentLevel = extra?['opponentLevel'] is int ? extra!['opponentLevel'] as int : 14;
          final opponentAvatar = extra?['opponentAvatar']?.toString();

          return _fadePage(
            state,
            TournamentVsScreen(
              round: round,
              mode: modeStr,
              roomId: roomId,
              gameId: gameId,
              opponentName: opponentName,
              opponentLevel: opponentLevel,
              opponentAvatar: opponentAvatar,
            ),
          );
        },
      ),
      GoRoute(
        path: AppConstants.tournamentVictoryRoute,
        name: 'tournament-victory',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final round = extra?['round'] is int ? extra!['round'] as int : 1;
          final modeStr = extra?['mode']?.toString() ?? 'classic';
          return _fadePage(
            state,
            TournamentVictoryScreen(round: round, mode: modeStr),
          );
        },
      ),
      GoRoute(
        path: AppConstants.tournamentDefeatRoute,
        name: 'tournament-defeat',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final round = extra?['round'] is int ? extra!['round'] as int : 1;
          final modeStr = extra?['mode']?.toString() ?? 'classic';
          return _fadePage(
            state,
            TournamentDefeatScreen(round: round, mode: modeStr),
          );
        },
      ),
      GoRoute(
        path: AppConstants.tournamentChampionRoute,
        name: 'tournament-champion',
        pageBuilder: (context, state) =>
            _fadePage(state, const TournamentChampionScreen()),
      ),
      GoRoute(
        path: AppConstants.tournamentHistoryRoute,
        name: 'tournament-history',
        pageBuilder: (context, state) =>
            _fadePage(state, const TournamentHistoryScreen()),
      ),
      GoRoute(
        path: AppConstants.themeGalleryRoute,
        name: 'theme-gallery',
        pageBuilder: (context, state) =>
            _fadePage(state, const ThemeGalleryScreen()),
      ),
    ],
  );
});

CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
        child: child,
      );
    },
  );
}
