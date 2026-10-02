# LudoVibe — Admin Panel Audit Report

> **Generated:** 2026-10-01 | **Auditor:** Read-only code audit | **Scope:** Full Flutter client + backend schema

---

## A. Tech Stack Summary

| Layer | Technology | Details |
|-------|-----------|---------|
| **Frontend** | Flutter 3.x (Dart ≥3.0) | `pubspec.yaml` L6-7 |
| **State Management** | Riverpod (flutter_riverpod 2.5.1) | StateNotifier + FutureProvider pattern |
| **Routing** | GoRouter 13.2 | `lib/core/router/app_router.dart` |
| **HTTP Client** | Dio 5.4 | `lib/core/network/api_client.dart` — Bearer token interceptor |
| **Realtime** | WebSocket (web_socket_channel 2.4) via **Laravel Reverb** (Pusher protocol) | `lib/core/network/websocket_service.dart` |
| **Backend** | **Laravel 11** (PHP) — NOT in this repo | Located at `G:\GAMES\ludo_backend` per docs |
| **Auth** | **Laravel Sanctum** (personal access tokens) | `personal_access_tokens` table |
| **Database** | **MySQL 8.4** | SQL dump: `dump-ludo-202609250009.sql` |
| **Live Game State** | **Redis** | Game state cached in Redis keys like `ludo:game:room:{id}` |
| **Payments** | **None real** — `wallet/topup` is a test endpoint | No JazzCash/Easypaisa/Google Play Billing integration |
| **Local Storage** | SharedPreferences + FlutterSecureStorage | `lib/core/storage/storage_service.dart` |
| **Base URL (dev)** | `http://127.0.0.1:8000/api/v1` | `lib/core/network/api_endpoints.dart` L3 |
| **WS URL (dev)** | `ws://127.0.0.1:8080/app/ludoreverbkey123` | `lib/core/network/api_endpoints.dart` L4-5 |

---

## B. Data Models & Database Tables

### B1. Database Tables (from SQL dump)

| Table | Key Columns | Notes |
|-------|------------|-------|
| `users` | id, device_id, username, email, google_id, auth_provider, phone, password, avatar_url, gender, dob, country, bio, name_change_count, name_change_reset_at, league_points, rank, country_code, level, xp, is_guest, metadata(JSON), is_active | **No `role` / `is_admin` / `is_banned` column** |
| `wallets` | id, user_id, coins_balance, diamonds_balance | One wallet per user |
| `transactions` | id, user_id, type(win/loss/purchase/topup/gift/entry_fee), currency_type, amount, reference_id, created_at | Full transaction log |
| `rooms` | id, room_code, type(public/private), max_players, entry_fee, status, created_by | Game rooms |
| `room_players` | id, room_id, user_id, seat_position, color(red/green/yellow/blue), is_ready | Room pivot |
| `games` | id, room_id, status, winner_id, started_at, ended_at | Game records |
| `game_moves` | id, game_id, user_id, token_id, dice_value, from_pos, to_pos, is_kill | Move history |
| `store_items` | id, name, type(avatar/dice_skin/board_theme), price, currency_type, image_url, **is_active** | Store catalog |
| `user_inventory` | id, user_id, item_id, is_equipped, purchased_at | Owned items |
| `friends` | id, user_id, friend_id, status(pending/accepted/blocked) | Friendship pairs |
| `chat_messages` | id, room_id, user_id, message, message_type, created_at | Room chat |
| `direct_messages` | id, sender_id, receiver_id, type(text/voice), message, voice_url, voice_duration, is_read, deleted_at(soft) | DM table |
| `leagues` | id, name, min_points, max_points, icon_url, tier_order | Legacy league tiers |
| `league_tiers` | id, name, tier_order, min_points, max_points, icon_url | New league tier config |
| `league_seasons` | id, season_number, starts_at, ends_at, status(upcoming/active/completed) | Seasonal leagues |
| `league_divisions` | id, league_season_id, league_tier_id, division_number, max_players | Divisions within tiers |
| `league_division_members` | id, league_division_id, user_id, points_in_division, final_rank, result | Members |
| `tournaments` | id, name, mode(classic/quick), entry_fee, currency_type, prize_pool, max_level, status(active/closed) | Tournament config |
| `tournament_levels` | id, tournament_id, level, reward_coins, reward_diamonds | Per-round rewards |
| `tournament_participants` | id, tournament_id, user_id, current_level, highest_level_reached, status | Player progress |
| `tournament_matches` | id, tournament_id, level, room_id, player1_id, player2_id, winner_id, status | Match brackets |

### B2. Flutter Data Models

| Model | File | Key Fields |
|-------|------|------------|
| `UserModel` | `lib/features/auth/models/user_model.dart` | id, username, email, coins, diamonds, level, xp, isGuest, avatarUrl, token |
| `ProfileModel` | `lib/features/profile/models/profile_model.dart` | id, name, level, xp, avatarUrl, country, gender, dob, bio, totalGamesPlayed, totalWins, totalLosses, winRate, leagueInfo, achievements |
| `WalletBalanceModel` | `lib/features/wallet/models/wallet_model.dart` | coins, diamonds |
| `TransactionModel` | `lib/features/wallet/models/wallet_model.dart` | type, currencyType, amount, referenceId, createdAt |
| `HomeDataModel` | `lib/features/home/models/home_data_model.dart` | username, level, coins, diamonds, currentLeague, isLeagueLocked, globalRank, avatarUrl |
| `StoreItemModel` | `lib/features/shop/models/store_item_model.dart` | id, name, type, price, currencyType, imageUrl, isEquipped |
| `ShopItem` | `lib/features/shop/models/shop_item_model.dart` | id, name, category, imageAsset, price, currencyType, isOwned, isEquipped, isRoyalOnly, themeType, stickerType, royalVipLevel, glowColor |
| `PurchasePackage` | `lib/features/shop/models/purchase_models.dart` | id, amount, value, priceUsd, iconAsset, badgeType, bonusTag |
| `SubscriptionTierData` | `lib/features/shop/models/purchase_models.dart` | id, name, monthlyPrice, dailyCoins, dailyDiamonds, dailyChests, privileges |
| `SubscriptionDto` | `lib/features/subscription/models/subscription_models.dart` | tier, status, startedAt, currentPeriodEnd, autoRenew, canClaimDailyReward |
| `GameStateModel` | `lib/features/game/models/game_state_model.dart` | roomId, gameId, status, currentTurnUserId, currentTurnSeat, diceValue, canRoll, mustMove, consecutiveSixes, turnSeconds, tokenPositions, players, movableTokens, winnerUserId |
| `RoomModel` | `lib/features/battle/models/room_model.dart` | roomId, roomCode, gameId, status, title, category, tags, countryCode, maxPlayers, entryFee, players |
| `RoomSession` | `lib/features/rooms/models/room_models.dart` | id, code, type, settings, participants, currentUserRole, status |
| `PrivateRoomDto` | `lib/features/rooms/models/private_room_dto.dart` | id, roomCode, status, maxPlayers, entryFee, turnSeconds, stateVersion, participants, gameId, canStart |
| `TournamentCardModel` | `lib/features/tournament/domain/tournament_card_model.dart` | id, title, mode, prizeGold, currentRound, status, entryFeeGold, unlockLevel, participantCount, levels |
| `DailyTaskModel` | `lib/features/home/models/event_model.dart` | id, taskKey, title, rewardType, rewardAmount, currentProgress, totalProgress, isClaimed |
| `ArrivalChestModel` | `lib/features/home/models/event_model.dart` | isReady, lastClaimedAt, nextAvailableAt, secondsRemaining, baseCoins, baseDiamonds, isVip |
| `MessageModel` | `lib/features/social/models/message_model.dart` | id, senderId, receiverId, type, message, voiceUrl, voiceDuration, isRead |
| `FriendModel` | `lib/features/social/models/message_model.dart` | id, userId, username, avatarUrl, isOnline, status |
| `LeaderboardItemModel` | `lib/features/social/models/leaderboard_model.dart` | rank, userId, username, avatarUrl, totalWins, totalGames, winRate |
| `LeagueTierModel` | `lib/features/profile/models/league_model.dart` | id, name, tierOrder, minPoints, maxPoints, iconUrl |
| `LeagueSeasonInfo` | `lib/features/profile/models/league_model.dart` | id, seasonNumber, startsAt, endsAt, secondsRemaining |
| `LeagueDivisionMemberModel` | `lib/features/profile/models/league_model.dart` | rank, userId, username, avatarUrl, country, pointsInDivision, isMe |
| `ProfileThemeItem` | `lib/features/profile/models/profile_customization_model.dart` | id, title, assetPath, accentColor, isRoyal — **HARDCODED** list of 18 themes |
| `ProfileFrameItem` | `lib/features/profile/models/profile_customization_model.dart` | id, title, gradientColors, glowColor — **HARDCODED** list of 7 frames |
| `ProfileOrnamentItem` | `lib/features/profile/models/profile_customization_model.dart` | id, title, assetPath, glowColor — **HARDCODED** list of 10 ornaments |
| `ProfileAvatarPreset` | `lib/features/profile/models/profile_customization_model.dart` | id, title, assetPath — **HARDCODED** list of 8 presets |

---

## C. Feature-by-Feature Audit Tables

### C1. User Profile

| Feature | Exists? | Source | Key Files | Admin Can Control | Status | Work Needed |
|---------|---------|--------|-----------|-------------------|--------|-------------|
| Name / username | ✅ | API `GET/PUT /profile` | `profile_provider.dart` L155-166, `profile_model.dart` | View, force-rename | READY | Admin endpoint to update any user's name |
| Member since | ✅ | DB `users.created_at` | Not displayed in Flutter model | View | PARTIAL | Expose `created_at` in profile API |
| Level & XP | ✅ | API `/profile`, `/home` | `user_model.dart` L7-8, `profile_model.dart` L4-5 | View, manually adjust | PARTIAL | Admin endpoint to set level/xp |
| Games played, wins, losses, win rate | ✅ | API `/profile` | `profile_model.dart` L11-14 | View | READY | Read via existing profile endpoint |
| League status | ✅ | API `/profile` → `league_info` | `profile_model.dart` L15, `league_model.dart` | View, reset points | PARTIAL | Admin league management endpoints |
| Achievements | ✅ Partial | API `/profile` → `achievements` | `profile_model.dart` L16 | View, grant badges | PARTIAL | Admin badge management endpoints needed |
| Avatar / photo | ✅ | API `PUT /profile` multipart | `profile_provider.dart` L274-280 | View, remove offensive | PARTIAL | Admin endpoint to clear avatar |
| Profile frame | ✅ | **HARDCODED** in Flutter | `profile_customization_model.dart` L181-281 (7 frames) | Manage catalog | HARDCODED | Move to backend `store_items` |
| Ornament | ✅ | **HARDCODED** in Flutter | `profile_customization_model.dart` L302-373 (10 ornaments) | Manage catalog | HARDCODED | Move to backend `store_items` |
| Gender | ✅ | API `PUT /profile` | `profile_provider.dart` L168-180 | View | READY | — |
| Country | ✅ | API `PUT /profile` | `profile_provider.dart` L203-214 | View | READY | — |
| Bio | ✅ | API `PUT /profile` | `profile_provider.dart` L216-227 | View, moderate | READY | — |
| Rooms created count | ❌ | NOT FOUND | — | — | MISSING | New query on `rooms.created_by` |
| Wallet balance | ✅ | API `/wallet/balance` | `wallet_provider.dart` | View, adjust | PARTIAL | Admin wallet adjustment endpoint |

### C2. User Moderation

| Feature | Exists? | Source | Key Files | Admin Can Control | Status | Work Needed |
|---------|---------|--------|-----------|-------------------|--------|-------------|
| Ban / unban user | ❌ | `users.is_active` exists in DB but **no API endpoint** | — | Ban/unban toggle | MISSING | Add `PATCH /admin/users/{id}/ban` endpoint; add `is_banned` or use `is_active` |
| Device / IP blocking | ❌ | `users.device_id` stored | — | Block device_ids | MISSING | New `banned_devices` table + middleware |
| VIP access check | ✅ | Subscription state check | `vip_access_provider.dart` L9-12 | Grant/revoke VIP | MISSING | Admin endpoint to manage subscriptions |
| Knight/Baron subscription | ✅ | API (subscription module) | `subscription_models.dart`, `subscription_provider.dart` | View, grant, revoke | PARTIAL | Admin subscription management endpoints |
| Manual coin/gem adjustment | ❌ | `wallet/topup` is test-only | `wallet_provider.dart` L48-62 | Credit/debit | MISSING | Admin wallet adjustment endpoint |
| Admin role field | ❌ | **No `role` column in `users` table** | — | — | MISSING | Add `role` enum(user/admin/moderator) to `users` |
| View user list | ❌ | No `/admin/users` endpoint | — | Search, filter, paginate | MISSING | Full admin users CRUD |

### C3. Dashboard Data

| Feature | Exists? | Source | Key Files | Admin Can Control | Status | Work Needed |
|---------|---------|--------|-----------|-------------------|--------|-------------|
| Total users | ✅ Queryable | `users` table (45 rows in dump) | — | View | PARTIAL | New `GET /admin/dashboard` endpoint with `COUNT(*)` |
| New users (today/week) | ✅ Queryable | `users.created_at` | — | View | PARTIAL | Aggregate query in admin dashboard |
| Online players | ❌ | No online presence tracking | — | View | MISSING | Need presence tracking (Redis/WS) |
| Running games | ✅ Queryable | `games.status = 'in_progress'` | — | View | PARTIAL | Count query |
| Revenue | ❌ | No real payment = no revenue data | — | View | MISSING | Needs real payment integration first |
| In-app purchases | ❌ | `wallet/topup` is mock | — | View | MISSING | Google Play Billing / App Store receipts |
| Coins in circulation | ✅ Queryable | `SUM(wallets.coins_balance)` | — | View | PARTIAL | Aggregate query |
| Diamonds in circulation | ✅ Queryable | `SUM(wallets.diamonds_balance)` | — | View | PARTIAL | Aggregate query |

### C4. Game Rooms & Gameplay

| Feature | Exists? | Source | Key Files | Admin Can Control | Status | Work Needed |
|---------|---------|--------|-----------|-------------------|--------|-------------|
| Private rooms (create/join) | ✅ | API `/private-rooms/*` | `private_room_dto.dart`, `private_room_provider.dart` | View active rooms, force-close | PARTIAL | Admin room list + close endpoint |
| VIP rooms | ✅ | API (rooms module) + VIP guard | `vip_room_*_screen.dart`, `vip_access_provider.dart` | View, manage | PARTIAL | Admin endpoints |
| 2-player & 4-player modes | ✅ | `max_players: 2 or 4` | `room_models.dart` L20, `private_room_dto.dart` L16 | Configure allowed modes | READY | — |
| Matchmaking (quick match) | ✅ | API `/matchmaking/*` | `api_endpoints.dart` L59-62 | View queue sizes, flush | PARTIAL | Admin queue management |
| Entry fee | ✅ | `rooms.entry_fee` | `private_room_dto.dart` L10-13 | Configure allowed fees | HARDCODED | `kAllowedEntryFees` hardcoded at `[0,500,1000,5000]`; `kVipAllowedEntryFees` at `[1000,5000,10000,25000]` |
| House commission / rake | ❌ | NOT FOUND in code or DB | — | Set rake percentage | MISSING | Backend logic + DB config needed |
| Bots / AI | ❌ | NOT FOUND | — | Enable/disable bots | MISSING | Full bot engine needed |
| Win reasons | ✅ Partial | `GameEnded` event with `winner_id` | `game_state_model.dart` L146-152 | View | PARTIAL | Need to track disconnect/forfeit win reasons |
| Game history | ✅ | `games` + `game_moves` tables | `game_state_model.dart` | View, replay | READY | Admin game history query |
| Turn timer | ✅ | `turnSeconds` (default 15) | `game_state_model.dart` L35, `room_models.dart` L21 | Configure default | HARDCODED | Move default turn timer to backend config |
| Forfeit / leave match | ✅ | API `/quick-match/forfeit` | `api_endpoints.dart` L39 | View, refund | PARTIAL | Admin refund endpoint |
| Reconnect logic | ✅ Partial | `PlayerDisconnected` WS event | Backend docs section 7 | Monitor | PARTIAL | — |
| Stuck room handling | ❌ | No automatic cleanup visible | — | Force-close rooms | MISSING | Scheduled job to close stale rooms |
| Refunds | ❌ | NOT FOUND | — | Issue refunds | MISSING | Admin refund endpoint + transaction type |
| Team mode (team code invite) | ✅ | Routes + screens exist | `team_vs_screen.dart`, `app_constants.dart` L80-83 | — | PARTIAL | Verify backend team endpoints |

### C5. Chat & Social

| Feature | Exists? | Source | Key Files | Admin Can Control | Status | Work Needed |
|---------|---------|--------|-----------|-------------------|--------|-------------|
| Room creation | ✅ | API `POST /rooms` | `create_room_screen.dart` | View, delete rooms | PARTIAL | Admin room management |
| Country-wise rooms | ✅ | API `/lobby/explore`, `/countries` | `api_endpoints.dart` L53-56 | Manage countries | READY | — |
| Room detail / joined users | ✅ | API `GET /rooms/{id}` | `room_detail_screen.dart` | View | READY | — |
| Friends system | ✅ | API `/friends/*` | `social_provider.dart` L167-219 | View, force-unfriend | PARTIAL | Admin friends management |
| Live chat messages | ✅ | API `/chat/message`, `/chat/messages` | `chat_flow_provider.dart` | View, delete messages | PARTIAL | Admin message moderation endpoints |
| Music playback | ✅ UI exists | Local sound service | `room_music_disc.dart`, `sound_service.dart` | — | HARDCODED | No admin control needed unless dynamic playlists |
| Emojis / stickers | ✅ | Asset-based | `reaction_overlay.dart`, sticker shop | Manage catalog | HARDCODED | Move to backend if dynamic |
| Gift system | ✅ | Asset-based | `gift_model.dart`, `gift_bottom_sheet.dart`, `gift_animation_overlay.dart` | Manage gifts | HARDCODED | Move gift catalog to backend |

### C6. Shop / Store

| Feature | Exists? | Source | Key Files | Admin Can Control | Status | Work Needed |
|---------|---------|--------|-----------|-------------------|--------|-------------|
| Dice skins (15 items) | ✅ | **HARDCODED** in `ShopCatalog.allItems` | `shop_item_model.dart` L117-268 | Add/remove/reprice | HARDCODED | Move full catalog to `store_items` DB table |
| Token skins (15 items) | ✅ | **HARDCODED** | `shop_item_model.dart` L273-424 | Add/remove/reprice | HARDCODED | Same as above |
| Board themes (12 basic + 9 royal) | ✅ | **HARDCODED** | `shop_item_model.dart` L430-670 | Add/remove/reprice | HARDCODED | Same |
| Tile skins (8 items) | ✅ | **HARDCODED** | `shop_item_model.dart` L675-748 | Add/remove/reprice | HARDCODED | Same |
| Bubble/Avatar frames (5+ items) | ✅ | **HARDCODED** | `shop_item_model.dart` L753-800+ | Add/remove/reprice | HARDCODED | Same |
| Sticker packs | ✅ | **HARDCODED** | `shop_item_model.dart` (>L800) | Manage | HARDCODED | Same |
| Ornaments (10 items) | ✅ | **HARDCODED** | `profile_customization_model.dart` L302-373 | Manage | HARDCODED | Same |
| Royal vehicles | ✅ | **HARDCODED** | `royal_vehicle_shop_screen.dart` | Manage | HARDCODED | Same |
| Backend store API | ✅ | API `/store/items`, `/store/purchase`, `/store/inventory`, `/store/equip` | `shop_provider.dart` L289-352 | CRUD items | PARTIAL | Backend table exists (`store_items`) but is **empty**; Flutter uses hardcoded `ShopCatalog` |
| Purchase flow | ✅ | Client-side balance check → API purchase → auto-equip | `shop_provider.dart` L231-263 | Monitor purchases | PARTIAL | — |
| Gold/Diamond purchase packages | ✅ | **HARDCODED** (6 gold tiers, 6 diamond tiers) | `purchase_models.dart` L67-179 | Reprice, add tiers | HARDCODED | Move to backend config |
| Knight/Baron subscription tiers | ✅ | **HARDCODED** prices ($11.99, $39.99) | `purchase_models.dart` L271-297 | Reprice | HARDCODED | Move to backend config |

### C7. Wallet & Payments

| Feature | Exists? | Source | Key Files | Admin Can Control | Status | Work Needed |
|---------|---------|--------|-----------|-------------------|--------|-------------|
| Coins & diamonds balance | ✅ | API `/wallet/balance` | `wallet_provider.dart` L28-31 | View all, adjust | PARTIAL | Admin wallet adjustment endpoint |
| Transaction history | ✅ | API `/wallet/transactions` | `wallet_provider.dart` L33-46 | View all users' transactions | PARTIAL | Admin transaction query endpoint |
| Deposits / top-up | ✅ Mock | API `/wallet/topup` (**no real payment**) | `wallet_provider.dart` L48-62 | — | MISSING | Real payment gateway integration |
| Withdrawals | ❌ | NOT FOUND | — | Approve/reject | MISSING | Full withdrawal system needed |
| JazzCash / Easypaisa | ❌ | NOT FOUND | — | — | MISSING | Payment gateway integration |
| Transaction types | ✅ | win, loss, purchase, topup, gift, entry_fee | DB enum | View | READY | — |

### C8. Tournaments & Leagues

| Feature | Exists? | Source | Key Files | Admin Can Control | Status | Work Needed |
|---------|---------|--------|-----------|-------------------|--------|-------------|
| Tournament list | ✅ | API `GET /tournaments` | `api_tournament_repository.dart` L29-95 | Create, edit, close | PARTIAL | Admin tournament CRUD endpoints |
| Tournament join/leave | ✅ | API `/tournaments/{id}/join`, `/leave` | `api_tournament_repository.dart` L98-113 | — | READY | — |
| Tournament progress | ✅ | API `/tournaments/{id}/progress` | `api_tournament_repository.dart` L122-129 | Monitor | READY | — |
| Tournament history | ✅ | API `/tournaments/my-history` | `api_tournament_repository.dart` L192-224 | View all | PARTIAL | Admin view for all users |
| Prize claim | ✅ | API `/tournaments/{id}/claim` | `api_tournament_repository.dart` L116-119 | Monitor | READY | — |
| Tournament winners | ✅ | API `/tournaments/winners` | `api_endpoints.dart` L101 | View | READY | — |
| Tournament round configs | ✅ | **HARDCODED** `defaultRounds` and `quickRounds` | `tournament_config.dart` L39-107 | Configure round rewards | HARDCODED | Move to `tournament_levels` table (exists but empty) |
| League tiers | ✅ | DB `league_tiers` (empty), `leagues` (empty) | `league_model.dart` | Configure tiers | PARTIAL | Seed league tiers; add admin CRUD |
| League seasons | ✅ | DB `league_seasons` (1 row exists) | `league_model.dart` L40-72 | Create/end seasons | PARTIAL | Admin season management |
| League divisions + rankings | ✅ | DB `league_divisions`, `league_division_members` | `league_model.dart` L124-190 | View, adjust | PARTIAL | Admin endpoints |
| Top 10 rankings / Leaderboard | ✅ | API `GET /leaderboard?type=global/country/friends` | `social_provider.dart` L286-303 | View, reset | READY | — |

### C9. Events, Rewards & Promotions

| Feature | Exists? | Source | Key Files | Admin Can Control | Status | Work Needed |
|---------|---------|--------|-----------|-------------------|--------|-------------|
| Daily tasks | ✅ | API `/events/daily-tasks`, `/events/daily-tasks/{id}/claim` | `events_provider.dart` L169-183 | Configure tasks, rewards | PARTIAL | Admin task management endpoints |
| Arrival chest (daily bonus) | ✅ | API `/events/arrival-chest`, `/events/arrival-chest/claim` | `events_provider.dart` L185-198 | Configure rewards, cooldown | PARTIAL | Admin config endpoints |
| Spin wheel | ❌ | NOT FOUND | — | Configure prizes | MISSING | Full feature build needed |
| Promo codes | ❌ | NOT FOUND | — | Create/manage codes | MISSING | New `promo_codes` table + endpoint |
| Achievements system | ✅ Partial | `achievements` in profile response | `profile_model.dart` L104-121 | Define badges | PARTIAL | Admin achievement CRUD |
| Events screen | ✅ | UI exists | `events_screen.dart` | — | PARTIAL | — |

### C10. Moderation & Notifications

| Feature | Exists? | Source | Key Files | Admin Can Control | Status | Work Needed |
|---------|---------|--------|-----------|-------------------|--------|-------------|
| Reports / complaints | ❌ | NOT FOUND | — | View, action | MISSING | New `reports` table + endpoints |
| Mute user | ❌ | NOT FOUND | — | Mute in rooms | MISSING | Backend mute logic |
| Push notifications (FCM) | ❌ | NOT FOUND in pubspec or code | — | Send targeted/broadcast | MISSING | FCM integration needed |
| In-app announcements | ❌ | NOT FOUND | — | Create/schedule | MISSING | New `announcements` table + endpoint |
| Chat message moderation | ❌ | No admin delete endpoint | — | Delete messages | MISSING | Admin message moderation endpoint |

---

## D. Complete List of Hardcoded Values That Should Become Admin-Configurable

| # | Value | File | Line(s) | Current Value | Admin Should |
|---|-------|------|---------|--------------|-------------|
| 1 | Full shop catalog (dice, tokens, themes, tiles, bubbles, stickers) | `lib/features/shop/models/shop_item_model.dart` | L113-1107 (entire `ShopCatalog.allItems` const list) | ~80+ items with prices, assets, descriptions | CRUD items via admin panel |
| 2 | Gold purchase packages (6 tiers) | `lib/features/shop/models/purchase_models.dart` | L67-122 | $0.99-$199.99, 33k-17M coins | Reprice, add/remove tiers |
| 3 | Diamond purchase packages (6 tiers) | `lib/features/shop/models/purchase_models.dart` | L124-179 | $0.99-$199.99, 300-161.7K diamonds | Reprice, add/remove tiers |
| 4 | Knight subscription tier (price, daily rewards) | `lib/features/shop/models/purchase_models.dart` | L271-283 | $11.99/mo, 28K daily coins, 20 daily diamonds | Reprice |
| 5 | Baron subscription tier (price, daily rewards) | `lib/features/shop/models/purchase_models.dart` | L285-297 | $39.99/mo, 57,777 daily coins, 60 daily diamonds | Reprice |
| 6 | Knight tier fallback (in enum) | `lib/features/subscription/models/subscription_models.dart` | L32-33 | $4.99, 200 coins/day, 5 diamonds/day | Reprice |
| 7 | Baron tier fallback (in enum) | `lib/features/subscription/models/subscription_models.dart` | L33 | $14.99, 500 coins/day, 15 diamonds/day | Reprice |
| 8 | Profile themes (18 items) | `lib/features/profile/models/profile_customization_model.dart` | L21-158 | Static theme list | Manage via admin |
| 9 | Profile frames (7 items) | `lib/features/profile/models/profile_customization_model.dart` | L181-281 | Static frame list | Manage via admin |
| 10 | Profile ornaments (10 items) | `lib/features/profile/models/profile_customization_model.dart` | L302-373 | Static ornament list | Manage via admin |
| 11 | Avatar presets (8 items) | `lib/features/profile/models/profile_customization_model.dart` | L388-429 | Static preset list | Manage via admin |
| 12 | Allowed private room entry fees | `lib/features/rooms/models/private_room_dto.dart` | L10 | `[0, 500, 1000, 5000]` | Configure via admin |
| 13 | Allowed VIP room entry fees | `lib/features/rooms/models/private_room_dto.dart` | L13 | `[1000, 5000, 10000, 25000]` | Configure via admin |
| 14 | Allowed turn seconds | `lib/features/rooms/models/private_room_dto.dart` | L19 | `[10, 15, 30]` | Configure via admin |
| 15 | Default turn timer | `lib/features/game/models/game_state_model.dart` | L35 | 15 seconds | Configure via admin |
| 16 | Tournament round rewards (classic mode, 6 rounds) | `lib/features/tournament/domain/tournament_config.dart` | L39-72 | 209K-88K gold per round | Configure per tournament |
| 17 | Tournament round rewards (quick mode, 6 rounds) | `lib/features/tournament/domain/tournament_config.dart` | L74-107 | 104K-44K gold per round | Configure per tournament |
| 18 | Default coin balance for new users | Backend (not in Flutter) | DB: `wallets.coins_balance` default | 500 coins | Configure via admin |
| 19 | Default diamond balance for new users | Backend (not in Flutter) | DB: `wallets.diamonds_balance` default | 10 diamonds | Configure via admin |
| 20 | League unlock level | `lib/features/home/models/home_data_model.dart` | L19 | Level 4 | Configure via admin |
| 21 | Name change limit | Backend (`name_change_count` check) | `users.name_change_count` | 3 per 24 hours | Configure via admin |
| 22 | API base URL | `lib/core/network/api_endpoints.dart` | L3 | `http://127.0.0.1:8000/api/v1` | Environment config |
| 23 | App name | `lib/core/constants/app_constants.dart` | L2 | `LudoVibe` | — |
| 24 | Initial user coins/diamonds in ShopState | `lib/features/shop/providers/shop_provider.dart` | L26-27 | 50000 coins, 1200 diamonds (fallback) | — |

---

## E. Existing API Endpoints & Socket Events

### E1. REST API Endpoints (All under `/api/v1`)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/auth/register` | User registration |
| POST | `/auth/login` | Email login |
| POST | `/auth/guest` | Guest login (device_id persistence) |
| POST | `/auth/google` | Google OAuth |
| GET | `/auth/me` | Current user |
| POST | `/auth/logout` | Logout (invalidate token) |
| GET | `/home` | Home screen data |
| GET | `/profile` | View profile |
| PUT | `/profile` | Edit profile (multipart) |
| GET | `/wallet/balance` | Wallet balance |
| GET | `/wallet/transactions` | Transaction history |
| POST | `/wallet/topup` | Top-up (**test only**) |
| POST | `/rooms` | Create room |
| GET | `/rooms` | List rooms |
| GET | `/rooms/{id}` | Room detail |
| POST | `/rooms/join` | Join room by code |
| POST | `/rooms/{id}/seat` | Take seat |
| POST | `/rooms/{id}/leave-seat` | Leave seat |
| POST | `/matchmaking/join` | Join matchmaking queue |
| POST | `/matchmaking/leave` | Leave queue |
| GET | `/matchmaking/status` | Queue status |
| GET | `/matchmaking/active-match` | Active match check |
| POST | `/game/start` | Start game |
| GET | `/game/state` | Get game state |
| POST | `/game/roll` | Roll dice |
| POST | `/game/move` | Move token |
| POST | `/quick-match/join` | Quick match join |
| POST | `/quick-match/leave` | Quick match leave |
| GET | `/quick-match/status` | Quick match status |
| GET | `/quick-match/active-match` | Quick match active |
| POST | `/quick-match/start` | Quick match start |
| GET | `/quick-match/state` | Quick match state |
| POST | `/quick-match/roll` | Quick match roll |
| POST | `/quick-match/move` | Quick match move |
| POST | `/quick-match/forfeit` | Forfeit match |
| POST | `/quick-match/message` | In-game message |
| GET | `/quick-match/messages` | In-game messages |
| GET | `/store/items` | List store items |
| POST | `/store/purchase` | Purchase item |
| GET | `/store/inventory` | User inventory |
| POST | `/store/equip` | Equip item |
| GET | `/friends` | List friends |
| GET | `/friends/requests` | Friend requests |
| POST | `/friends/request` | Send friend request |
| POST | `/friends/{id}/respond` | Accept/reject request |
| POST | `/users/{id}/follow` | Follow user |
| POST | `/users/{id}/unfollow` | Unfollow user |
| GET | `/users/{id}/follow-status` | Follow status |
| POST | `/chat/message` | Send room chat |
| GET | `/chat/messages` | Get room chat |
| POST | `/friends/{id}/message` | Send DM |
| GET | `/friends/{id}/messages` | Get DM history |
| GET | `/friends/conversations` | Conversations list |
| DELETE | `/friends/messages/{id}` | Delete message |
| GET | `/leaderboard` | Leaderboard (global/country/friends) |
| GET | `/lobby/explore` | Lobby explore |
| GET | `/lobby/hot` | Hot lobbies |
| GET | `/lobby/my` | My lobbies |
| GET | `/countries` | Country list |
| GET | `/tournaments` | List tournaments |
| GET | `/tournaments/winners` | Tournament winners |
| GET | `/tournaments/my-history` | My tournament history |
| GET | `/tournaments/{id}` | Tournament detail |
| POST | `/tournaments/{id}/join` | Join tournament |
| POST | `/tournaments/{id}/continue` | Continue tournament |
| POST | `/tournaments/{id}/leave` | Leave tournament |
| POST | `/tournaments/{id}/claim` | Claim prize |
| GET | `/tournaments/{id}/progress` | Tournament progress |
| GET | `/events/daily-tasks` | Daily tasks |
| POST | `/events/daily-tasks/{id}/claim` | Claim task reward |
| GET | `/events/arrival-chest` | Arrival chest status |
| POST | `/events/arrival-chest/claim` | Claim chest |
| POST | `/private-rooms` | Create private room |
| POST | `/private-rooms/join` | Join private room |
| GET | `/private-rooms/active` | Active private rooms |
| GET | `/private-rooms/{id}` | Private room detail |
| POST | `/private-rooms/{id}/ready` | Ready up |
| POST | `/private-rooms/{id}/start` | Start private game |
| POST | `/private-rooms/{id}/leave` | Leave private room |
| POST | `/broadcasting/auth` | WebSocket auth |

### E2. WebSocket Events

| Channel | Event | Direction | Purpose |
|---------|-------|-----------|---------|
| `private-user.{userId}` | `match.found` / `MatchFound` | Server→Client | Matchmaking found |
| `private-user.{userId}` | `direct.message.sent` | Server→Client | DM received |
| `private-user.{userId}` | `direct.message.deleted` | Server→Client | DM deleted |
| `private-user.{userId}` | `tournament.match.found` | Server→Client | Tournament match |
| `room.{roomId}` / `private-room.{roomId}` | `GameStarted` | Server→Client | Game started |
| `room.{roomId}` | `DiceRolled` | Server→Client | Dice result |
| `room.{roomId}` | `TokenMoved` | Server→Client | Token moved |
| `room.{roomId}` | `TurnChanged` | Server→Client | Turn changed |
| `room.{roomId}` | `GameEnded` | Server→Client | Game ended |
| `room.{roomId}` | `RoomUpdated` | Server→Client | Room state updated |
| `room.{roomId}` | `PlayerDisconnected` | Server→Client | Player disconnected |
| `private-room.{roomId}` | `PrivateRoomUpdated` | Server→Client | Private room snapshot |
| System | `pusher:connection_established` | Server→Client | WS connected |
| System | `pusher:ping` / `pusher:pong` | Bidirectional | Heartbeat |
| System | `pusher:subscribe` / `pusher:unsubscribe` | Client→Server | Channel management |

---

## F. Missing Backend Pieces for Admin Panel

### F1. New Database Tables Needed

| Table | Purpose | Key Columns |
|-------|---------|-------------|
| `admin_users` or add `role` to `users` | Admin authentication and RBAC | role(admin/moderator/user), permissions |
| `banned_devices` | Device/IP blocking | device_id, ip_address, reason, banned_at, banned_by |
| `reports` | User reports / complaints | id, reporter_id, reported_user_id, reason, status, created_at |
| `announcements` | In-app announcements | id, title, body, type, target_audience, starts_at, ends_at, is_active |
| `promo_codes` | Promotion codes | id, code, reward_type, reward_amount, max_uses, used_count, expires_at |
| `admin_audit_log` | Admin action log | id, admin_user_id, action, target_type, target_id, details, created_at |
| `app_config` | Dynamic app configuration | key, value, group, description |
| `spin_wheel_prizes` | Spin wheel configuration | id, prize_type, prize_amount, probability, is_active |

### F2. New API Endpoints Needed

| Priority | Endpoint | Purpose |
|----------|----------|---------|
| P0 | `POST /admin/auth/login` | Admin login (separate or role-based) |
| P0 | `GET /admin/dashboard` | Aggregated stats (users, games, revenue, etc.) |
| P0 | `GET /admin/users` | Paginated user list with search and filters |
| P0 | `GET /admin/users/{id}` | Full user detail (profile + wallet + games + transactions) |
| P0 | `PATCH /admin/users/{id}/ban` | Ban/unban user |
| P0 | `PATCH /admin/users/{id}/wallet` | Adjust coins/diamonds |
| P1 | `GET /admin/games` | Game history with filters |
| P1 | `GET /admin/games/{id}` | Game detail with move replay |
| P1 | `DELETE /admin/games/{id}` | Force-close stuck game + refund |
| P1 | `GET /admin/rooms` | Active rooms list |
| P1 | `DELETE /admin/rooms/{id}` | Force-close room |
| P1 | `GET /admin/transactions` | All transactions, filterable |
| P1 | `CRUD /admin/store/items` | Manage store catalog |
| P1 | `CRUD /admin/tournaments` | Create/edit/close tournaments |
| P1 | `CRUD /admin/tournaments/{id}/levels` | Configure round rewards |
| P2 | `CRUD /admin/leagues/tiers` | Manage league tiers |
| P2 | `CRUD /admin/leagues/seasons` | Manage league seasons |
| P2 | `CRUD /admin/events/daily-tasks` | Configure daily tasks |
| P2 | `PATCH /admin/events/arrival-chest/config` | Configure chest rewards |
| P2 | `CRUD /admin/announcements` | In-app announcements |
| P2 | `POST /admin/notifications/send` | Push notifications (FCM) |
| P2 | `GET /admin/reports` | View user reports |
| P2 | `PATCH /admin/reports/{id}` | Action on report |
| P3 | `CRUD /admin/promo-codes` | Promo code management |
| P3 | `CRUD /admin/subscriptions` | Subscription management |
| P3 | `GET /admin/chat/messages` | Chat message search/moderate |
| P3 | `DELETE /admin/chat/messages/{id}` | Delete chat message |
| P3 | `GET /admin/matchmaking/queues` | View live queue stats |

---

## G. Risks & Issues Found

### G1. Security Gaps

| # | Risk | Severity | Details |
|---|------|----------|---------|
| 1 | **No admin role/auth** | CRITICAL | `users` table has no `role` column. No admin middleware exists. Must be built from scratch. |
| 2 | **Wallet topup has no payment verification** | CRITICAL | `POST /wallet/topup` credits coins with `payment_method: 'test'`. Anyone can call this. (Documented in backend known issues #3) |
| 3 | **No rate limiting visible** | HIGH | No evidence of rate limiting on API endpoints. Brute-force login or wallet abuse possible. |
| 4 | **No input sanitization for chat** | HIGH | Chat messages (`chat_messages`, `direct_messages`) have no content filtering or profanity check. |
| 5 | **Bearer tokens never expire** | MEDIUM | `personal_access_tokens.expires_at` is NULL for all tokens. Tokens live forever once issued. |
| 6 | **Guest accounts are not cleanupable** | MEDIUM | 45 users, mostly guests, accumulate indefinitely. No cleanup mechanism. |

### G2. Scaling Risks

| # | Risk | Details |
|---|------|---------|
| 1 | **Redis game state without TTL** | Cache keys like `ludo:game:room:1` may persist after game ends if cleanup fails |
| 2 | **No voice file cleanup** | Backend docs mention a daily cleanup job for soft-deleted voice messages doesn't exist yet (known issue #2) |
| 3 | **is_read never updates** | `GET /friends/{friend_id}/messages` doesn't mark messages as read (known issue #1) |
| 4 | **Leaderboard rank recalculation lag** | Rank only updates every 10 minutes via scheduler (known issue #4) |

### G3. Stuck Game / Room Risks

| # | Risk | Details |
|---|------|---------|
| 1 | **No stuck room auto-close** | If both players disconnect, the room + game stay `in_progress` forever in both MySQL and Redis |
| 2 | **No game timeout** | Turn timer auto-skips, but there's no overall game time limit or abandonment detection |
| 3 | **No refund mechanism** | If a game is stuck/cancelled, entry fees can't be refunded — no refund transaction type or endpoint |

### G4. Data Integrity

| # | Risk | Details |
|---|------|---------|
| 1 | **Dual shop catalog** | `store_items` DB table exists (with `is_active` flag — admin-friendly) but is **empty**. Flutter uses hardcoded `ShopCatalog` (80+ items). These are completely disconnected — purchases via backend API hit empty table, while client uses local list. |
| 2 | **Inconsistent subscription pricing** | `purchase_models.dart` says Knight=$11.99/Baron=$39.99; `subscription_models.dart` enum says Knight=$4.99/Baron=$14.99. Two different hardcoded sources. |
| 3 | **Tournament levels table empty** | `tournament_levels` table exists but has no data. Flutter falls back to hardcoded `TournamentConfig.defaultRounds`. |

---

## H. Final Summary

### H1. Readiness Breakdown

| Status | Count | Percentage | Description |
|--------|-------|------------|-------------|
| **READY** | 8 | **11%** | API exists, admin can query with minimal work |
| **PARTIAL** | 30 | **42%** | Data/API partially exists, needs admin-specific endpoints |
| **HARDCODED** | 18 | **25%** | Data exists in Flutter code/assets, needs migration to backend |
| **MISSING** | 16 | **22%** | Feature doesn't exist at all, needs full build |

### H2. Suggested Admin Panel Build Order

#### Phase 1 — Foundation & User Management (Weeks 1-3)
> **Goal:** Admin can log in, view users, and perform basic moderation.

1. Add `role` column to `users` table (admin / moderator / user)
2. Build admin authentication (separate login or role-gated Sanctum tokens)
3. Build `GET /admin/dashboard` — aggregate stats endpoint
4. Build `GET /admin/users` — paginated user list with search
5. Build `GET /admin/users/{id}` — full user detail
6. Build `PATCH /admin/users/{id}/ban` — ban/unban
7. Build `PATCH /admin/users/{id}/wallet` — adjust coins/diamonds
8. Build admin audit log table + middleware

#### Phase 2 — Store & Economy (Weeks 4-6)
> **Goal:** Admin can manage the shop, view transactions, and control the economy.

1. **Migrate hardcoded `ShopCatalog` to `store_items` table** — this is the single biggest refactoring task
2. Build `CRUD /admin/store/items` — add/edit/remove/reprice items
3. Refactor Flutter `ShopProvider` to load from API instead of `ShopCatalog.allItems`
4. Build `GET /admin/transactions` — filterable transaction log
5. Move purchase package tiers and subscription pricing to `app_config` table
6. Build `CRUD /admin/app-config` — dynamic config management

#### Phase 3 — Games, Tournaments & Rooms (Weeks 7-9)
> **Goal:** Admin can monitor live games, manage tournaments, and handle stuck rooms.

1. Build `GET /admin/games` + `GET /admin/rooms` — live monitoring
2. Build force-close room + refund endpoint
3. Build stuck-room auto-cleanup scheduled job
4. Build `CRUD /admin/tournaments` — create/edit tournaments
5. Migrate hardcoded tournament round configs to `tournament_levels` table
6. Build `CRUD /admin/leagues/*` — league tier/season management
7. Seed league tiers with initial data

#### Phase 4 — Events, Notifications & Moderation (Weeks 10-12)
> **Goal:** Admin can manage events, send notifications, and moderate content.

1. Build `CRUD /admin/events/daily-tasks` + arrival chest config
2. Build `reports` table + `GET/PATCH /admin/reports`
3. Integrate FCM for push notifications
4. Build `CRUD /admin/announcements`
5. Build `CRUD /admin/promo-codes`
6. Build chat message moderation endpoints
7. Build device/IP blocking system

#### Phase 5 — Payments & Polish (Weeks 13+)
> **Goal:** Real payments, withdrawal system, and production hardening.

1. Integrate real payment gateway (Google Play Billing / JazzCash / Easypaisa)
2. Build withdrawal request flow
3. Add rate limiting to all API endpoints
4. Token expiration policy
5. Guest account cleanup job
6. Revenue dashboard with real payment data
7. Spin wheel feature build

---

> **Bottom line:** The Flutter client is feature-rich with well-structured models and API integration. However, ~47% of admin-controllable features are either **hardcoded in Flutter** or **completely missing from the backend**. The biggest single blocker is the **disconnected shop catalog** — 80+ items hardcoded in Dart while the `store_items` DB table sits empty. Fixing this in Phase 2 will unlock the most admin value.
