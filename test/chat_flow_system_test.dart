import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/features/battle/models/room_model.dart';
import 'package:ludo_vibe/features/social/models/gift_model.dart';
import 'package:ludo_vibe/features/social/providers/chat_flow_provider.dart';

void main() {
  group('ChatFlowProvider & Social System Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial State has discoverable rooms and default state', () {
      final state = container.read(chatFlowProvider);
      expect(state.allRooms.isNotEmpty, isTrue);
      expect(state.recentlyVisited.isNotEmpty, isTrue);
      expect(state.joinedRooms.isNotEmpty, isTrue);
      expect(state.friends.isNotEmpty, isTrue);
      expect(state.selectedCountry, isNull);
    });

    test('Country filtering updates filtered rooms correctly', () {
      final notifier = container.read(chatFlowProvider.notifier);

      // Select Pakistan (PK)
      notifier.selectCountry('PK');
      var state = container.read(chatFlowProvider);
      expect(state.selectedCountry, equals('PK'));

      var filtered = notifier.getFilteredExploreRooms();
      expect(filtered.every((r) => r.countryCode == 'PK'), isTrue);
      expect(filtered.any((r) => r.title.contains('Pakistan Lounge')), isTrue);

      // Select UAE (AE)
      notifier.selectCountry('AE');
      state = container.read(chatFlowProvider);
      expect(state.selectedCountry, equals('AE'));
      filtered = notifier.getFilteredExploreRooms();
      expect(filtered.every((r) => r.countryCode == 'AE'), isTrue);

      // Clear Country Filter
      notifier.selectCountry(null);
      state = container.read(chatFlowProvider);
      expect(state.selectedCountry, isNull);
      expect(notifier.getFilteredExploreRooms().length, equals(state.allRooms.length));
    });

    test('Category filtering updates filtered rooms correctly', () {
      final notifier = container.read(chatFlowProvider.notifier);

      notifier.setFilterCategory('music');
      var filtered = notifier.getFilteredExploreRooms();
      expect(filtered.every((r) => r.category == 'music'), isTrue);

      // Toggling category clears it
      notifier.setFilterCategory('music');
      expect(container.read(chatFlowProvider).activeCategory, isNull);
    });

    test('Room Visit tracks into Recently Visited without duplicates', () {
      final notifier = container.read(chatFlowProvider.notifier);
      final roomToVisit = RoomModel(
        roomId: 9999,
        title: 'Brand New Test Room',
        status: 'active',
        players: [],
      );

      notifier.visitRoom(roomToVisit);
      var recent = container.read(chatFlowProvider).recentlyVisited;
      expect(recent.first.roomId, equals(9999));

      // Visit again - should remain at index 0 and not duplicate
      notifier.visitRoom(roomToVisit);
      recent = container.read(chatFlowProvider).recentlyVisited;
      expect(recent.first.roomId, equals(9999));
      expect(recent.where((r) => r.roomId == 9999).length, equals(1));
    });

    test('Host Follow and Unfollow updates Following state and friends list', () {
      final notifier = container.read(chatFlowProvider.notifier);

      expect(notifier.isHostFollowed('DJ Zain'), isFalse);

      // Follow DJ Zain
      notifier.toggleFollowHost('DJ Zain');
      expect(notifier.isHostFollowed('DJ Zain'), isTrue);

      var followingRooms = notifier.getFollowingRooms();
      expect(followingRooms.any((r) => r.title.contains('Music Corner')), isTrue);

      // Unfollow
      notifier.toggleFollowHost('DJ Zain');
      expect(notifier.isHostFollowed('DJ Zain'), isFalse);
    });

    test('Room Creation automatically registers under Joined and Recently as Host', () {
      final notifier = container.read(chatFlowProvider.notifier);

      final newRoom = notifier.createRoom(
        title: 'My Custom Champions Lounge',
        category: 'social',
        maxPlayers: 4,
        entryFee: 1000,
        countryCode: 'PK',
      );

      expect(newRoom.title, equals('My Custom Champions Lounge'));
      expect(newRoom.isMine, isTrue);
      expect(newRoom.players.first.username, equals('You (Host)'));
      expect(newRoom.players.first.seatPosition, equals(1));

      // Verify it appears in Joined and Recently
      final state = container.read(chatFlowProvider);
      expect(state.joinedRooms.any((r) => r.roomId == newRoom.roomId), isTrue);
      expect(state.recentlyVisited.first.roomId, equals(newRoom.roomId));
    });

    test('Gifts System has all required tiers with non-empty assets and positive costs', () {
      final gifts = GiftModel.defaultGifts;
      expect(gifts.length, greaterThanOrEqualTo(8));

      for (final gift in gifts) {
        expect(gift.id.isNotEmpty, isTrue);
        expect(gift.name.isNotEmpty, isTrue);
        expect(gift.cost, greaterThan(0));
        expect(gift.assetPath.isNotEmpty, isTrue);
      }

      // Check specific requested gifts
      expect(gifts.any((g) => g.id == 'rose'), isTrue);
      expect(gifts.any((g) => g.id == 'heart'), isTrue);
      expect(gifts.any((g) => g.id == 'diamond'), isTrue);
      expect(gifts.any((g) => g.id == 'crown'), isTrue);
      expect(gifts.any((g) => g.id == 'car'), isTrue);
      expect(gifts.any((g) => g.id == 'jet'), isTrue);
      expect(gifts.any((g) => g.id == 'trophy'), isTrue);
    });

    test('Friends list contains online friends with active room links', () {
      final friends = container.read(chatFlowProvider).friends;
      expect(friends.isNotEmpty, isTrue);

      final onlineFriendsInRoom = friends.where((f) => f.isOnline && f.currentRoomId != null);
      expect(onlineFriendsInRoom.isNotEmpty, isTrue);
    });
  });
}
