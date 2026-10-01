// lib/features/rooms/repositories/api_team_room_repository.dart
//
// Real implementation of the Team Room & Matchmaking API contract.
//
// Endpoints used (all under /api/v1/team-rooms):
//   POST   /                    -> create 2-seat party lobby
//   POST   /join                -> join 2-seat party lobby by 6-digit code
//   POST   /join-solo           -> solo queue entry into 2v2 matchmaking
//   GET    /current             -> getActiveRoom
//   GET    /{code}              -> show team room by code
//   POST   /ready               -> toggle guest ready status in party lobby
//   POST   /ready-for-match     -> host enqueues ready 2-player team lobby into 2v2 matchmaking
//   POST   /leave               -> leave team party lobby
//
// All methods throw RoomFailure subtypes on error.

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/features/rooms/models/private_room_dto.dart';
import 'package:ludo_vibe/features/rooms/models/room_failure.dart';

/// Allowed entry fees for 2v2 Team mode, mirroring backend config('team_room.allowed_entry_fees').
const List<int> kTeamAllowedEntryFees = [0, 500, 1000, 2500, 5000, 10000];

final apiTeamRoomRepositoryProvider = Provider<ApiTeamRoomRepository>((ref) {
  return ApiTeamRoomRepository(ref.watch(apiClientProvider));
});

class ApiTeamRoomRepository {
  ApiTeamRoomRepository(this._client, {this.basePath = '/team-rooms'});

  final ApiClient _client;
  final String basePath;

  String get _base => basePath;
  String get _join => '$basePath/join';
  String get _joinSolo => '$basePath/join-solo';
  String get _current => '$basePath/current';
  String get _ready => '$basePath/ready';
  String get _readyForMatch => '$basePath/ready-for-match';
  String get _leave => '$basePath/leave';
  String _show(String code) => '$basePath/$code';

  /// CREATE a 2-seat team party lobby
  Future<PrivateRoomDto> create({
    required int entryFee,
    int? turnSeconds,
  }) async {
    final body = <String, dynamic>{
      'entry_fee': entryFee,
      if (turnSeconds != null) 'turn_seconds': turnSeconds,
    };
    final data = await _call(() => _client.post(_base, data: body));
    final bodyMap = data as Map<String, dynamic>;
    final roomData = bodyMap['data'] != null && bodyMap['data']['room'] != null
        ? bodyMap['data']['room'] as Map<String, dynamic>
        : bodyMap;
    return PrivateRoomDto.fromApiResponse({'data': roomData});
  }

  /// JOIN an existing team party lobby by 6-digit code
  Future<PrivateRoomDto> join(String roomCode) async {
    final data = await _call(
      () => _client.post(_join, data: {'code': roomCode.trim().toUpperCase()}),
    );
    final bodyMap = data as Map<String, dynamic>;
    final roomData = bodyMap['data'] != null && bodyMap['data']['room'] != null
        ? bodyMap['data']['room'] as Map<String, dynamic>
        : bodyMap;
    return PrivateRoomDto.fromApiResponse({'data': roomData});
  }

  /// JOIN 2v2 matchmaking as a Solo player
  Future<Map<String, dynamic>> joinSolo({required int entryFee}) async {
    final data = await _call(
      () => _client.post(_joinSolo, data: {'entry_fee': entryFee}),
    );
    return data as Map<String, dynamic>;
  }

  /// GET active team room for user
  Future<PrivateRoomDto?> getActiveRoom() async {
    try {
      final data = await _call(() => _client.get(_current));
      if (data == null) return null;
      final body = data as Map<String, dynamic>;
      if (body['data'] == null || body['data']['room'] == null) return null;
      return PrivateRoomDto.fromApiResponse({'data': body['data']['room']});
    } on RoomNotFound {
      return null;
    }
  }

  /// GET team room snapshot by code
  Future<PrivateRoomDto> show(String code) async {
    final data = await _call(() => _client.get(_show(code)));
    final bodyMap = data as Map<String, dynamic>;
    final roomData = bodyMap['data'] != null && bodyMap['data']['room'] != null
        ? bodyMap['data']['room'] as Map<String, dynamic>
        : bodyMap;
    return PrivateRoomDto.fromApiResponse({'data': roomData});
  }

  /// TOGGLE ready status of guest in party lobby
  Future<PrivateRoomDto> toggleReady({bool? isReady}) async {
    final data = await _call(
      () => _client.post(_ready, data: ifNotNull(isReady, {'is_ready': isReady})),
    );
    final bodyMap = data as Map<String, dynamic>;
    final roomData = bodyMap['data'] != null && bodyMap['data']['room'] != null
        ? bodyMap['data']['room'] as Map<String, dynamic>
        : bodyMap;
    return PrivateRoomDto.fromApiResponse({'data': roomData});
  }

  /// HOST ENQUEUES ready 2-player team lobby into 2v2 matchmaking
  Future<Map<String, dynamic>> readyForMatch() async {
    final data = await _call(() => _client.post(_readyForMatch));
    return data as Map<String, dynamic>;
  }

  /// LEAVE current team party lobby
  Future<void> leave() async {
    await _call(() => _client.post(_leave));
  }

  static Map<String, dynamic>? ifNotNull(bool? val, Map<String, dynamic> m) =>
      val != null ? m : null;

  Future<dynamic> _call(Future<dynamic> Function() fn) async {
    try {
      return await fn();
    } on DioException catch (e) {
      throw _mapDio(e);
    } on ApiException catch (e) {
      throw _mapApiException(e);
    } catch (e) {
      if (kDebugMode) print('❌ [ApiTeamRoomRepository] Unknown error: $e');
      throw RoomUnknown(e.toString());
    }
  }

  RoomFailure _mapDio(DioException e) {
    final status = e.response?.statusCode;
    final body = e.response?.data;
    final errorCode = _errorCode(body);
    final message = _message(body, fallback: e.message ?? 'Network error');

    if (kDebugMode) {
      print('❌ [ApiTeamRoomRepository] Status=$status code=$errorCode msg=$message');
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
        final existing = (body is Map && body['room_id'] != null)
            ? int.tryParse(body['room_id'].toString())
            : null;
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
}
