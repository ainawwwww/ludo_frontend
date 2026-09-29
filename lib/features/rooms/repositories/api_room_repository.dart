// lib/features/rooms/repositories/api_room_repository.dart
//
// Real implementation of the private-room API contract.
//
// Endpoints used (all under /api/v1/private-rooms):
//   POST   /                    -> create
//   POST   /join                -> join
//   GET    /{id}                -> show (member-only, numeric ID)
//   POST   /{id}/ready          -> toggleReady
//   POST   /{id}/start          -> start
//   POST   /{id}/leave          -> leave
//   GET    /active              -> getActiveRoom
//
// All methods throw RoomFailure subtypes on error.
// All methods return PrivateRoomDto on success.

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/features/rooms/models/private_room_dto.dart';
import 'package:ludo_vibe/features/rooms/models/room_failure.dart';

// ---------------------------------------------------------------------------
// Provider

final apiRoomRepositoryProvider = Provider<ApiRoomRepository>((ref) {
  return ApiRoomRepository(ref.watch(apiClientProvider));
});

// ---------------------------------------------------------------------------
// API path constants

abstract final class _P {
  static const base = '/private-rooms';
  static const join = '/private-rooms/join';
  static const active = '/private-rooms/active';
  static String show(int id) => '/private-rooms/$id';
  static String ready(int id) => '/private-rooms/$id/ready';
  static String start(int id) => '/private-rooms/$id/start';
  static String leave(int id) => '/private-rooms/$id/leave';
}

// ---------------------------------------------------------------------------

class ApiRoomRepository {
  ApiRoomRepository(this._client);

  final ApiClient _client;

  // ---- CREATE -------------------------------------------------------------

  /// POST /api/v1/private-rooms
  /// [maxPlayers] must be 2 or 4.
  /// [entryFee]   must be 0, 500, 1000, or 5000.
  /// [turnSeconds] must be 10, 15, or 30 (nullable -> server picks default).
  Future<PrivateRoomDto> create({
    required int maxPlayers,
    required int entryFee,
    int? turnSeconds,
    String? title,
  }) async {
    final body = <String, dynamic>{
      'max_players': maxPlayers,
      'entry_fee': entryFee,
      if (turnSeconds != null) 'turn_seconds': turnSeconds,
      if (title != null && title.isNotEmpty) 'title': title,
    };
    final data = await _call(() => _client.post(_P.base, data: body));
    return PrivateRoomDto.fromApiResponse(data as Map<String, dynamic>);
  }

  // ---- JOIN ---------------------------------------------------------------

  /// POST /api/v1/private-rooms/join  { room_code: "ABCDE1" }
  Future<PrivateRoomDto> join(String roomCode) async {
    final data = await _call(
      () => _client.post(_P.join, data: {'room_code': roomCode.trim().toUpperCase()}),
    );
    return PrivateRoomDto.fromApiResponse(data as Map<String, dynamic>);
  }

  // ---- SHOW ---------------------------------------------------------------

  /// GET /api/v1/private-rooms/{id}
  /// Returns 404 (RoomNotFound) if caller is not a member, so existence does not leak.
  Future<PrivateRoomDto> show(int roomId) async {
    final data = await _call(() => _client.get(_P.show(roomId)));
    return PrivateRoomDto.fromApiResponse(data as Map<String, dynamic>);
  }

  // ---- ACTIVE ROOM --------------------------------------------------------

  /// GET /api/v1/private-rooms/active
  /// Returns null if the user has no active private room.
  Future<PrivateRoomDto?> getActiveRoom() async {
    try {
      final data = await _call(() => _client.get(_P.active));
      if (data == null) return null;
      final body = data as Map<String, dynamic>;
      if (body['data'] == null) return null;
      return PrivateRoomDto.fromApiResponse(body);
    } on RoomNotFound {
      return null;
    }
  }

  // ---- TOGGLE READY -------------------------------------------------------

  /// POST /api/v1/private-rooms/{id}/ready  { is_ready: true|false }
  Future<PrivateRoomDto> toggleReady(int roomId, {required bool isReady}) async {
    final data = await _call(
      () => _client.post(_P.ready(roomId), data: {'is_ready': isReady}),
    );
    return PrivateRoomDto.fromApiResponse(data as Map<String, dynamic>);
  }

  // ---- START --------------------------------------------------------------

  /// POST /api/v1/private-rooms/{id}/start  (host only)
  /// Returns the updated room snapshot (status=playing, game_id set).
  Future<PrivateRoomDto> start(int roomId) async {
    final data = await _call(() => _client.post(_P.start(roomId)));
    return PrivateRoomDto.fromApiResponse(data as Map<String, dynamic>);
  }

  // ---- LEAVE --------------------------------------------------------------

  /// POST /api/v1/private-rooms/{id}/leave
  /// Host leaving cancels the room; guest leaving frees their seat.
  Future<void> leave(int roomId) async {
    await _call(() => _client.post(_P.leave(roomId)));
  }

  // ---- INTERNAL HELPERS ---------------------------------------------------

  /// Executes [fn] and maps DioException / ApiException into RoomFailure subtypes.
  Future<dynamic> _call(Future<dynamic> Function() fn) async {
    try {
      return await fn();
    } on DioException catch (e) {
      throw _mapDio(e);
    } on ApiException catch (e) {
      throw _mapApiException(e);
    } catch (e) {
      if (kDebugMode) print('❌ [ApiRoomRepository] Unknown error: $e');
      throw RoomUnknown(e.toString());
    }
  }

  RoomFailure _mapDio(DioException e) {
    final status = e.response?.statusCode;
    final body = e.response?.data;
    final errorCode = _errorCode(body);
    final message = _message(body, fallback: e.message ?? 'Network error');

    if (kDebugMode) {
      print('❌ [ApiRoomRepository] DioException status=$status code=$errorCode msg=$message');
    }

    return switch (status) {
      401 => RoomUnauthenticated(message),
      402 => RoomInsufficientBalance(message),
      403 => RoomForbidden(message),
      404 => RoomNotFound(message),
      409 => _resolveConflict(errorCode, message, body),
      422 => RoomValidation(message),
      _ when e.type == DioExceptionType.connectionTimeout ||
             e.type == DioExceptionType.receiveTimeout ||
             e.type == DioExceptionType.connectionError =>
          RoomNetworkFailure(),
      _ => RoomUnknown(message),
    };
  }

  RoomFailure _mapApiException(ApiException e) {
    return switch (e.statusCode) {
      401 => RoomUnauthenticated(e.message),
      402 => RoomInsufficientBalance(e.message),
      403 => RoomForbidden(e.message),
      404 => RoomNotFound(e.message),
      409 => RoomConflict(e.message),
      422 => RoomValidation(e.message),
      _ => RoomUnknown(e.message),
    };
  }

  RoomFailure _resolveConflict(
      String? errorCode, String message, dynamic body) {
    switch (errorCode) {
      case 'ALREADY_IN_ROOM':
        final existing = _nestedInt(body, 'data', 'room_id');
        return RoomAlreadyActive(existingRoomId: existing, message: message);
      case 'ROOM_FULL':
        return RoomFull(message);
      case 'ALREADY_STARTED':
        return RoomAlreadyStarted(message);
      default:
        return RoomConflict(message);
    }
  }

  String? _errorCode(dynamic body) {
    if (body is Map) return body['error_code'] as String?;
    return null;
  }

  String _message(dynamic body, {required String fallback}) {
    if (body is Map) {
      return (body['message'] as String?) ?? fallback;
    }
    return fallback;
  }

  int? _nestedInt(dynamic body, String key1, String key2) {
    if (body is Map && body[key1] is Map) {
      final v = (body[key1] as Map)[key2];
      if (v is int) return v;
      if (v != null) return int.tryParse(v.toString());
    }
    return null;
  }
}
