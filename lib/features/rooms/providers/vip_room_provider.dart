// lib/features/rooms/providers/vip_room_provider.dart
//
// State provider for VIP room lifecycle. Reuses [PrivateRoomController]
// configured with [apiVipRoomRepositoryProvider].

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/network/websocket_service.dart';
import 'package:ludo_vibe/features/rooms/providers/private_room_provider.dart';
import 'package:ludo_vibe/features/rooms/repositories/api_room_repository.dart';

final vipRoomProvider =
    StateNotifierProvider<PrivateRoomController, PrivateRoomState>((ref) {
  return PrivateRoomController(
    repository: ref.watch(apiVipRoomRepositoryProvider),
    wsService: ref.watch(webSocketServiceProvider),
  );
});
