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
