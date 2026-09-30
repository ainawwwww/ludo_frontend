import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_vibe/features/auth/models/user_model.dart';
import 'package:ludo_vibe/features/auth/providers/auth_provider.dart';
import 'package:ludo_vibe/features/rooms/models/private_room_dto.dart';
import 'package:ludo_vibe/features/rooms/models/room_failure.dart';
import 'package:ludo_vibe/features/rooms/providers/vip_room_provider.dart';
import 'package:ludo_vibe/features/rooms/repositories/api_room_repository.dart';
import 'package:ludo_vibe/features/rooms/screens/vip_room_create_screen.dart';

class _FakeGatingVipApiRoomRepository implements ApiRoomRepository {
  @override
  String get basePath => '/vip-rooms';

  @override
  Future<PrivateRoomDto> create({
    required int maxPlayers,
    required int entryFee,
    int? turnSeconds,
    String? title,
  }) async {
    throw const RoomVipSubscriptionRequired(
      'Active VIP subscription required to create a VIP room',
    );
  }

  @override
  Future<PrivateRoomDto?> getActiveRoom() async => null;

  @override
  Future<PrivateRoomDto> join(String roomCode) async {
    throw UnimplementedError();
  }

  @override
  Future<void> leave(int roomId) async {}

  @override
  Future<PrivateRoomDto> show(int roomId) async {
    throw UnimplementedError();
  }

  @override
  Future<PrivateRoomDto> start(int roomId) async {
    throw UnimplementedError();
  }

  @override
  Future<PrivateRoomDto> toggleReady(int roomId, {required bool isReady}) async {
    throw UnimplementedError();
  }
}

class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier() : super(const FakeAuthRepo()) {
    state = AuthState(
      user: UserModel(
        id: 42,
        username: 'TestUser',
        coins: 50000,
        diamonds: 100,
        level: 1,
      ),
    );
  }
}

class FakeAuthRepo implements AuthRepository {
  const FakeAuthRepo();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('VipRoomCreateScreen displays GET VIP PASS button when VIP_SUBSCRIPTION_REQUIRED error occurs',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final fakeRepo = _FakeGatingVipApiRoomRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiVipRoomRepositoryProvider.overrideWithValue(fakeRepo),
          authProvider.overrideWith((ref) => FakeAuthNotifier()),
        ],
        child: const MaterialApp(
          home: VipRoomCreateScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('btn_create_vip_room')), findsOneWidget);

    // Tap Create VIP Room
    await tester.tap(find.byKey(const Key('btn_create_vip_room')));
    await tester.pumpAndSettle();

    // Verify error text and GET VIP PASS button are rendered
    expect(find.text('Active VIP subscription required to create a VIP room'), findsOneWidget);
    expect(find.byKey(const Key('btn_get_vip_pass')), findsOneWidget);
    expect(find.text('GET VIP PASS'), findsOneWidget);
  });
}
