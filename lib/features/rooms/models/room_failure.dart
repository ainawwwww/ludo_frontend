// lib/features/rooms/models/room_failure.dart
//
// Sealed failure hierarchy for private-room operations.
// Every public method in ApiRoomRepository throws one of these so callers
// pattern-match without catching raw Exceptions.

sealed class RoomFailure {
  const RoomFailure(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// HTTP 401 / missing token.
final class RoomUnauthenticated extends RoomFailure {
  const RoomUnauthenticated([super.message = 'Please log in to continue']);
}

/// HTTP 403 / not a member.
final class RoomForbidden extends RoomFailure {
  const RoomForbidden([super.message = 'You do not have access to this room']);
}

/// HTTP 404 / room code not found.
final class RoomNotFound extends RoomFailure {
  const RoomNotFound([super.message = 'Room not found']);
}

/// HTTP 409 / seat already taken or concurrent modification.
final class RoomConflict extends RoomFailure {
  const RoomConflict([super.message = 'Action could not be completed (conflict)']);
}

/// HTTP 422 / validation error (e.g. invalid code format).
final class RoomValidation extends RoomFailure {
  const RoomValidation(super.message);
}

/// HTTP 402 / insufficient coins.
final class RoomInsufficientBalance extends RoomFailure {
  const RoomInsufficientBalance(super.message);
}

/// User already has an active room (server ALREADY_IN_ROOM code).
final class RoomAlreadyActive extends RoomFailure {
  /// Server returns the existing room's id when this error fires.
  final int? existingRoomId;
  const RoomAlreadyActive({
    this.existingRoomId,
    String message = 'You already have an active room',
  }) : super(message);
}

/// Room is full.
final class RoomFull extends RoomFailure {
  const RoomFull([super.message = 'This room is full']);
}

/// Match already started — can't join/leave through this endpoint.
final class RoomAlreadyStarted extends RoomFailure {
  const RoomAlreadyStarted([super.message = 'Match is already in progress']);
}

/// Network or timeout error.
final class RoomNetworkFailure extends RoomFailure {
  const RoomNetworkFailure([super.message = 'Network error. Please try again']);
}

/// Unknown / unexpected error. Contains the original message.
final class RoomUnknown extends RoomFailure {
  const RoomUnknown([super.message = 'An unexpected error occurred']);
}
