import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/room_models.dart';
import '../repositories/room_repository.dart';

final roomRepositoryProvider = Provider<RoomRepository>(
  (ref) => MockRoomRepository(),
);

final roomFlowProvider =
    StateNotifierProvider<RoomFlowController, RoomFlowState>((ref) {
      return RoomFlowController(ref.watch(roomRepositoryProvider));
    });

class RoomFlowController extends StateNotifier<RoomFlowState> {
  RoomFlowController(this._repository) : super(const RoomFlowState());

  final RoomRepository _repository;

  Future<bool> createRoom(RoomType type, RoomSettings settings) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final session = await _repository.createRoom(type, settings);
      state = RoomFlowState(session: session);
      return true;
    } catch (error) {
      state = RoomFlowState(error: error.toString());
      return false;
    }
  }

  Future<bool> joinRoom(RoomType type, String code) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final session = await _repository.joinRoom(type, code.trim());
      state = RoomFlowState(session: session);
      return true;
    } on FormatException catch (error) {
      state = RoomFlowState(error: error.message);
      return false;
    } catch (_) {
      state = const RoomFlowState(
        error: 'Room is unavailable. Please try again.',
      );
      return false;
    }
  }

  void addMockGuest() {
    final session = state.session;
    if (session == null ||
        session.participants.length >= session.settings.maxPlayers)
      return;
    final seat = session.participants.length + 1;
    final guest = RoomParticipant(
      id: 'guest_$seat',
      name: ['Sara', 'Ayaan', 'Ludo Pro'][seat - 2],
      seat: seat,
      role: RoomRole.guest,
      ready: true,
    );
    state = state.copyWith(
      session: session.copyWith(participants: [...session.participants, guest]),
    );
  }

  void toggleReady() {
    final session = state.session;
    if (session == null) return;
    state = state.copyWith(
      session: session.copyWith(
        participants: session.participants
            .map(
              (p) => p.id == 'me' && p.role == RoomRole.guest
                  ? p.copyWith(ready: !p.ready)
                  : p,
            )
            .toList(),
      ),
    );
  }

  void markStarting() {
    final session = state.session;
    if (session != null)
      state = state.copyWith(
        session: session.copyWith(status: RoomStatus.starting),
      );
  }

  void leaveRoom() => state = const RoomFlowState();
}
