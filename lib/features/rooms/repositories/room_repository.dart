import '../models/room_models.dart';

abstract class RoomRepository {
  Future<RoomSession> createRoom(RoomType type, RoomSettings settings);
  Future<RoomSession> joinRoom(RoomType type, String code);
}

class MockRoomRepository implements RoomRepository {
  int _nextId = 7000;

  @override
  Future<RoomSession> createRoom(RoomType type, RoomSettings settings) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final id = _nextId++;
    return RoomSession(
      id: id,
      code: id.toString().padLeft(6, '0'),
      type: type,
      settings: settings,
      currentUserRole: RoomRole.host,
      participants: const [
        RoomParticipant(
          id: 'me',
          name: 'You',
          seat: 1,
          role: RoomRole.host,
          ready: true,
        ),
      ],
    );
  }

  @override
  Future<RoomSession> joinRoom(RoomType type, String code) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      throw const FormatException('Enter a valid 6-digit room code.');
    }
    return RoomSession(
      id: int.parse(code),
      code: code,
      type: type,
      settings: const RoomSettings(),
      currentUserRole: RoomRole.guest,
      participants: const [
        RoomParticipant(
          id: 'host',
          name: 'Royal Host',
          seat: 1,
          role: RoomRole.host,
          ready: true,
        ),
        RoomParticipant(id: 'me', name: 'You', seat: 2, role: RoomRole.guest),
      ],
    );
  }
}
