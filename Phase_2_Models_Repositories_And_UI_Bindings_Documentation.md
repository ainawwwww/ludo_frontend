# LudoVibe — Phase 2: Models, Repositories & UI Screen Integration Documentation

This document details the complete implementation of **Phase 2: Data Models, Feature Repositories, Riverpod Providers, and UI Screen Bindings** for the LudoVibe Flutter application.

---

## 1. Data Models Created

| Model File | Associated API Endpoints | Key Fields / Structs |
|---|---|---|
| [`UserModel`](file:///c:/Users/SINC%2012/Desktop/ludo/lib/features/auth/models/user_model.dart) | `/auth/register`, `/auth/login`, `/auth/guest`, `/auth/google`, `/auth/me` | `id`, `username`, `email`, `coins`, `diamonds`, `level`, `is_guest`, `avatar_url`, `token` |
| [`ProfileModel`](file:///c:/Users/SINC%2012/Desktop/ludo/lib/features/profile/models/profile_model.dart) | `/profile` (GET, PUT) | `name`, `level`, `country`, `bio`, `total_wins`, `win_rate`, `league_info`, `achievements` |
| [`HomeDataModel`](file:///c:/Users/SINC%2012/Desktop/ludo/lib/features/home/models/home_data_model.dart) | `/home` (GET) | `username`, `coins`, `diamonds`, `level`, `global_rank`, `current_league`, `avatar_url` |
| [`WalletBalanceModel` & `TransactionModel`](file:///c:/Users/SINC%2012/Desktop/ludo/lib/features/wallet/models/wallet_model.dart) | `/wallet/balance`, `/wallet/transactions`, `/wallet/topup` | `coins`, `diamonds`, transaction history list (`type`, `amount`, `reference_id`) |
| [`StoreItemModel`](file:///c:/Users/SINC%2012/Desktop/ludo/lib/features/shop/models/store_item_model.dart) | `/store/items`, `/store/purchase`, `/store/inventory` | `id`, `name`, `type` (`avatar`, `dice_skin`, `board_theme`), `price`, `is_equipped` |
| [`RoomModel`](file:///c:/Users/SINC%2012/Desktop/ludo/lib/features/battle/models/room_model.dart) | `/matchmaking/join`, `/rooms`, `/rooms/join` | `room_id`, `room_code`, `status` (`waiting`/`matched`), `players` (`user_id`, `color`, `seat`) |
| [`GameStateModel`](file:///c:/Users/SINC%2012/Desktop/ludo/lib/features/game/models/game_state_model.dart) | `/game/state`, `/game/roll`, `/game/move` | `room_id`, `current_turn_user_id`, `dice_value`, `has_rolled`, `tokens` (`token_index`, `position`) |
| [`MessageModel` & `ConversationModel`](file:///c:/Users/SINC%2012/Desktop/ludo/lib/features/social/models/message_model.dart) | `/friends/{id}/message`, `/friends/{id}/messages`, `/friends/conversations` | DMs (`text`/`voice`), `voice_url`, `voice_duration`, inbox unread count |
| [`LeaderboardItemModel`](file:///c:/Users/SINC%2012/Desktop/ludo/lib/features/social/models/leaderboard_model.dart) | `/leaderboard?type=global\|country\|friends` | `rank`, `user_id`, `username`, `total_wins`, `win_rate` |

---

## 2. Feature Repositories & Riverpod Providers Created

| Feature | Provider File | Repositories & State Notifiers | Main Responsibilities |
|---|---|---|---|
| **Auth** | [`auth_provider.dart`](file:///c:/Users/SINC%2012/Desktop/ludo/lib/features/auth/providers/auth_provider.dart) | `AuthRepository`, `authProvider` | Guest Auth (persistent `device_id`), Register, Login, Google Sign-In, Me, token persistence, WS channel sub |
| **Home** | [`home_provider.dart`](file:///c:/Users/SINC%2012/Desktop/ludo/lib/features/home/providers/home_provider.dart) | `HomeRepository`, `homeDataProvider` | Fetch dashboard user stats (`GET /home`) |
| **Profile** | [`profile_provider.dart`](file:///c:/Users/SINC%2012/Desktop/ludo/lib/features/profile/providers/profile_provider.dart) | `ProfileRepository`, `profileDataProvider` | Profile view & `multipart/form-data` profile updates |
| **Wallet** | [`wallet_provider.dart`](file:///c:/Users/SINC%2012/Desktop/ludo/lib/features/wallet/providers/wallet_provider.dart) | `WalletRepository`, `walletBalanceProvider`, `walletTransactionsProvider` | Wallet balance, topup, transaction history |
| **Shop** | [`shop_provider.dart`](file:///c:/Users/SINC%2012/Desktop/ludo/lib/features/shop/providers/shop_provider.dart) | `ShopRepository`, `storeItemsProvider`, `userInventoryProvider` | Store items catalog, inventory, purchases |
| **Matchmaking & Rooms** | [`battle_provider.dart`](file:///c:/Users/SINC%2012/Desktop/ludo/lib/features/battle/providers/battle_provider.dart) | `BattleRepository`, `matchmakingProvider` | Quick Match queueing, room creation & WS `match.found` listening |
| **Game Engine** | [`game_provider.dart`](file:///c:/Users/SINC%2012/Desktop/ludo/lib/features/game/providers/game_provider.dart) | `GameRepository`, `gameEngineProvider` | Server-driven dice rolling (`POST /game/roll`), token moving (`POST /game/move`), real-time WS sync |
| **Social & DMs** | [`social_provider.dart`](file:///c:/Users/SINC%2012/Desktop/ludo/lib/features/social/providers/social_provider.dart) | `SocialRepository`, `directMessagesProvider`, `friendsListProvider` | Friend lists, DMs, voice note multipart uploads, real-time message stream |

---

## 3. UI Screen Integrations

1. **[`welcome_screen.dart`](file:///c:/Users/SINC%2012/Desktop/ludo/lib/features/auth/screens/welcome_screen.dart)**: Connected to `authProvider` — clicking "GET STARTED" or "SKIP" triggers `guestLogin()` with persistent `device_id` and connects WebSocket.
2. **[`home_screen.dart`](file:///c:/Users/SINC%2012/Desktop/ludo/lib/features/home/screens/home_screen.dart)**: Connected to `homeDataProvider` — dynamically feeds user coins, diamonds, level, and username to `TopBar`.
3. **[`battle_lobby_screen.dart`](file:///c:/Users/SINC%2012/Desktop/ludo/lib/features/battle/screens/battle_lobby_screen.dart)**: Bound to `matchmakingProvider` for Quick Match queueing and automatic navigation upon WS `match.found`.

---

## 4. Phase 2 Unit Tests

Unit tests created in [`test/phase_2_models_and_providers_test.dart`](file:///c:/Users/SINC%2012/Desktop/ludo/test/phase_2_models_and_providers_test.dart) verify JSON parsing and payload mapping for all 9 Phase 2 data models.
