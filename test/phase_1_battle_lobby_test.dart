import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_vibe/features/battle/models/lobby_model.dart';
import 'package:ludo_vibe/features/battle/models/room_model.dart';

void main() {
  group('Battle Lobby Models & Serialization', () {
    test('RoomModel parses from JSON correctly', () {
      final json = {
        'id': 101,
        'room_id': 101,
        'room_code': 'LOBBY99',
        'title': 'Grand Ludo Palace',
        'category': 'social',
        'tags': ['Ludo', 'PK', 'Tournament'],
        'country_code': 'PK',
        'member_count': 250,
        'is_live': true,
        'status': 'waiting',
        'players': [
          {
            'user_id': 1,
            'username': 'King',
            'seat_position': 1,
            'color': 'red',
          },
        ],
      };

      final room = RoomModel.fromJson(json);

      expect(room.roomId, 101);
      expect(room.roomCode, 'LOBBY99');
      expect(room.title, 'Grand Ludo Palace');
      expect(room.countryCode, 'PK');
      expect(room.memberCount, 250);
      expect(room.isLive, true);
      expect(room.tags, contains('PK'));
      expect(room.players.length, 1);
      expect(room.players.first.username, 'King');
    });

    test('LobbyExploreData parses from JSON correctly', () {
      final json = {
        'data': {
          'quick_entry_cards': [
            {
              'id': 'new_here',
              'title': 'New here',
              'description': 'Casual hangout for newcomers',
              'bg_asset': 'assets/graphics/card_private.png',
              'gradient': ['#00B2FF', '#0072BC'],
              'filter_category': 'social',
              'tags': ['Beginner', 'Casual'],
            }
          ],
          'recommended_rooms': [
            {
              'id': 1,
              'room_code': 'REC01',
              'title': 'Recommended Lounge',
              'member_count': 120,
              'status': 'waiting',
              'players': [],
            }
          ],
          'pagination': {
            'current_page': 1,
            'last_page': 2,
            'per_page': 15,
            'total': 20,
            'has_more': true,
          }
        }
      };

      final explore = LobbyExploreData.fromJson(json);
      expect(explore.quickEntryCards.length, 1);
      expect(explore.quickEntryCards.first.title, 'New here');
      expect(explore.recommendedRooms.length, 1);
      expect(explore.recommendedRooms.first.title, 'Recommended Lounge');
      expect(explore.pagination?.total, 20);
      expect(explore.pagination?.hasMore, true);
    });

    test('LobbyHotData parses from JSON correctly', () {
      final json = {
        'data': {
          'popular_hosts': [
            {
              'id': 5,
              'user_id': 5,
              'username': 'SuperHost',
              'badge': '🔥',
              'active_room': {
                'room_id': 50,
                'room_code': 'HOT50',
                'title': 'Super Live Room',
                'member_count': 300,
              }
            }
          ],
          'trending_rooms': [
            {
              'id': 50,
              'room_code': 'HOT50',
              'title': 'Super Live Room',
              'member_count': 300,
              'status': 'waiting',
              'players': [],
            }
          ],
        }
      };

      final hot = LobbyHotData.fromJson(json);
      expect(hot.popularHosts.length, 1);
      expect(hot.popularHosts.first.username, 'SuperHost');
      expect(hot.popularHosts.first.activeRoomId, 50);
      expect(hot.trendingRooms.length, 1);
    });

    test('LobbyMyData parses from JSON correctly', () {
      final json = {
        'data': {
          'filter': 'recently',
          'rooms': [
            {
              'id': 7,
              'room_code': 'MY07',
              'title': 'My Recent Room',
              'member_count': 10,
              'status': 'waiting',
              'players': [],
            }
          ],
        }
      };

      final myData = LobbyMyData.fromJson(json);
      expect(myData.filter, 'recently');
      expect(myData.rooms.length, 1);
      expect(myData.rooms.first.roomCode, 'MY07');
    });
  });
}
