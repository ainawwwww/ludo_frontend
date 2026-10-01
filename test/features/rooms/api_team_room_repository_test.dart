import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_vibe/features/rooms/models/private_room_dto.dart';
import 'package:ludo_vibe/features/rooms/models/room_failure.dart';
import 'package:ludo_vibe/features/game/models/team_assignment.dart';

void main() {
  group('Team Mode DTO & TeamAssignment Unit Tests', () {
    test('PrivateRoomDto correctly parses team room server payload', () {
      final json = {
        'id': 101,
        'room_code': 'TEAM99',
        'type': 'team',
        'status': 'waiting',
        'max_players': 2,
        'member_count': 2,
        'entry_fee': 1000,
        'turn_seconds': 15,
        'created_by': 1,
        'players': [
          {
            'user_id': 1,
            'username': 'HostUser',
            'seat_position': 1,
            'color': 'red',
            'is_ready': true,
            'is_host': true,
          },
          {
            'user_id': 2,
            'username': 'PartnerUser',
            'seat_position': 2,
            'color': 'yellow',
            'is_ready': true,
            'is_host': false,
          },
        ],
      };

      final dto = PrivateRoomDto.fromApiResponse({'data': json});
      expect(dto.id, equals(101));
      expect(dto.roomCode, equals('TEAM99'));
      expect(dto.status, equals(RoomStatusDto.waiting));
      expect(dto.participants.length, equals(2));
      expect(dto.participants[0].username, equals('HostUser'));
      expect(dto.participants[1].username, equals('PartnerUser'));
    });

    test('TeamAssignment single source of truth helper assertions', () {
      expect(TeamAssignment.teamForSeat(1), equals(TeamAssignment.team1));
      expect(TeamAssignment.teamForSeat(3), equals(TeamAssignment.team1));
      expect(TeamAssignment.teamForSeat(2), equals(TeamAssignment.team2));
      expect(TeamAssignment.teamForSeat(4), equals(TeamAssignment.team2));

      expect(TeamAssignment.teammateSeat(1), equals(3));
      expect(TeamAssignment.teammateSeat(3), equals(1));
      expect(TeamAssignment.teammateSeat(2), equals(4));
      expect(TeamAssignment.teammateSeat(4), equals(2));

      expect(TeamAssignment.areTeammates(1, 3), isTrue);
      expect(TeamAssignment.areTeammates(2, 4), isTrue);
      expect(TeamAssignment.areTeammates(1, 2), isFalse);
      expect(TeamAssignment.areTeammates(3, 4), isFalse);
    });

    test('RoomFailure hierarchy properly maps network/conflict errors', () {
      final conflict = RoomAlreadyActive(existingRoomId: 42, message: 'Already in room');
      expect(conflict.existingRoomId, equals(42));
      expect(conflict.message, contains('Already in room'));

      final full = RoomFull('Room is full');
      expect(full.message, equals('Room is full'));
    });
  });
}
