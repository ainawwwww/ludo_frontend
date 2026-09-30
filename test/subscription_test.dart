import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_vibe/features/shop/screens/subscription_screen.dart';
import 'package:ludo_vibe/features/subscription/models/subscription_models.dart';
import 'package:ludo_vibe/features/subscription/providers/subscription_provider.dart';
import 'package:ludo_vibe/features/subscription/repositories/api_subscription_repository.dart';
import 'package:ludo_vibe/features/subscription/widgets/vip_checkout_sheet.dart';

class FakeApiSubscriptionRepository implements ApiSubscriptionRepository {
  SubscriptionDto? currentToReturn;
  SubscriptionFailure? failureToThrow;
  bool shouldFailCheckout = false;

  @override
  Future<List<SubscriptionPlanDto>> fetchPlans() async {
    return [
      SubscriptionPlanDto(
        tier: 'knight',
        title: 'KNIGHT PASS',
        price: 4.99,
        currency: 'USD',
        dailyCoins: 200,
        dailyDiamonds: 5,
      ),
      SubscriptionPlanDto(
        tier: 'baron',
        title: 'BARON PASS',
        price: 14.99,
        currency: 'USD',
        dailyCoins: 500,
        dailyDiamonds: 15,
      ),
    ];
  }

  @override
  Future<SubscriptionDto?> fetchCurrentSubscription() async {
    if (failureToThrow != null) throw failureToThrow!;
    return currentToReturn;
  }

  @override
  Future<SubscriptionDto> checkout({
    required String tier,
    bool forceFailure = false,
  }) async {
    if (forceFailure || shouldFailCheckout) {
      throw const PaymentFailedFailure('Forced dummy payment failure');
    }
    final sub = SubscriptionDto(
      tier: tier,
      status: 'active',
      startedAt: DateTime.now(),
      currentPeriodEnd: DateTime.now().add(const Duration(days: 30)),
      autoRenew: true,
      canClaimDailyReward: true,
    );
    currentToReturn = sub;
    return sub;
  }

  @override
  Future<SubscriptionDto> cancel() async {
    if (failureToThrow != null) throw failureToThrow!;
    final current = currentToReturn;
    final cancelled = SubscriptionDto(
      tier: current?.tier ?? 'knight',
      status: 'cancelled',
      startedAt: current?.startedAt ?? DateTime.now(),
      currentPeriodEnd: current?.currentPeriodEnd ?? DateTime.now().add(const Duration(days: 30)),
      autoRenew: false,
      canClaimDailyReward: current?.canClaimDailyReward ?? true,
    );
    currentToReturn = cancelled;
    return cancelled;
  }

  Duration? claimDelay;

  @override
  Future<Map<String, int>> claimDailyReward() async {
    if (claimDelay != null) {
      await Future.delayed(claimDelay!);
    }
    if (failureToThrow != null) throw failureToThrow!;
    final current = currentToReturn;
    if (current != null) {
      currentToReturn = SubscriptionDto(
        tier: current.tier,
        status: current.status,
        startedAt: current.startedAt,
        currentPeriodEnd: current.currentPeriodEnd,
        autoRenew: current.autoRenew,
        canClaimDailyReward: false,
      );
    }
    return {'coins_claimed': 200, 'diamonds_claimed': 5};
  }
}

void main() {
  group('Subscription DTO & Failure Tests', () {
    test('SubscriptionDto.fromJson parses active subscription accurately', () {
      final json = {
        'tier': 'baron',
        'status': 'active',
        'started_at': '2026-09-29T12:00:00.000Z',
        'current_period_end': '2026-10-29T12:00:00.000Z',
        'auto_renew': true,
        'can_claim_daily_reward': true,
      };

      final dto = SubscriptionDto.fromJson(json);

      expect(dto.tier, 'baron');
      expect(dto.status, 'active');
      expect(dto.isActive, true);
      expect(dto.autoRenew, true);
      expect(dto.canClaimDailyReward, true);
      expect(dto.tierEnum, SubscriptionTier.baron);
    });

    test('SubscriptionPlanDto.fromJson parses plan details accurately', () {
      final json = {
        'tier': 'knight',
        'title': 'KNIGHT PASS',
        'price': 4.99,
        'currency': 'USD',
        'daily_rewards': {'coins': 200, 'diamonds': 5},
      };

      final plan = SubscriptionPlanDto.fromJson(json);

      expect(plan.tier, 'knight');
      expect(plan.price, 4.99);
      expect(plan.dailyCoins, 200);
      expect(plan.dailyDiamonds, 5);
    });

    test('SubscriptionFailure sealed class subtypes carry messages', () {
      const f1 = AlreadySubscribedFailure('Already active');
      const f2 = PaymentFailedFailure('Declined');
      const f3 = RewardAlreadyClaimedFailure('Already claimed');

      expect(f1.message, 'Already active');
      expect(f2.message, 'Declined');
      expect(f3.message, 'Already claimed');
    });
  });

  group('SubscriptionNotifier Provider State Transitions', () {
    late FakeApiSubscriptionRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeApiSubscriptionRepository();
    });

    test('Initial fetch sets current subscription and plans', () async {
      fakeRepo.currentToReturn = null;

      final container = ProviderContainer(
        overrides: [
          apiSubscriptionRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(subscriptionProvider.notifier).fetchCurrentSubscription();

      final state = container.read(subscriptionProvider);
      expect(state.currentSubscription, isNull);
      expect(state.plans.length, 2);
      expect(state.status, SubscriptionStateStatus.success);
    });

    test('Checkout success updates currentSubscription and success message', () async {
      fakeRepo.currentToReturn = null;

      final container = ProviderContainer(
        overrides: [
          apiSubscriptionRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      final success = await container
          .read(subscriptionProvider.notifier)
          .checkout(tier: 'knight');

      expect(success, true);
      final state = container.read(subscriptionProvider);
      expect(state.currentSubscription?.tier, 'knight');
      expect(state.currentSubscription?.isActive, true);
      expect(state.actionSuccessMessage, contains('activated'));
    });

    test('Checkout failure sets failure state', () async {
      fakeRepo.currentToReturn = null;
      fakeRepo.shouldFailCheckout = true;

      final container = ProviderContainer(
        overrides: [
          apiSubscriptionRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      final success = await container
          .read(subscriptionProvider.notifier)
          .checkout(tier: 'knight', forceFailure: true);

      expect(success, false);
      final state = container.read(subscriptionProvider);
      expect(state.failure, isA<PaymentFailedFailure>());
      expect(state.failure?.message, contains('Forced dummy payment failure'));
    });

    test('Claim daily reward sets canClaimDailyReward to false', () async {
      fakeRepo.currentToReturn = SubscriptionDto(
        tier: 'knight',
        status: 'active',
        startedAt: DateTime.now(),
        currentPeriodEnd: DateTime.now().add(const Duration(days: 30)),
        autoRenew: true,
        canClaimDailyReward: true,
      );

      final container = ProviderContainer(
        overrides: [
          apiSubscriptionRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(subscriptionProvider.notifier).fetchCurrentSubscription();
      final success = await container.read(subscriptionProvider.notifier).claimDailyReward();

      expect(success, true);
      final state = container.read(subscriptionProvider);
      expect(state.currentSubscription?.canClaimDailyReward, false);
    });

    test('Cancel subscription sets autoRenew to false and status to cancelled', () async {
      fakeRepo.currentToReturn = SubscriptionDto(
        tier: 'knight',
        status: 'active',
        startedAt: DateTime.now(),
        currentPeriodEnd: DateTime.now().add(const Duration(days: 30)),
        autoRenew: true,
        canClaimDailyReward: true,
      );

      final container = ProviderContainer(
        overrides: [
          apiSubscriptionRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(subscriptionProvider.notifier).fetchCurrentSubscription();
      final success = await container.read(subscriptionProvider.notifier).cancel();

      expect(success, true);
      final state = container.read(subscriptionProvider);
      expect(state.currentSubscription?.autoRenew, false);
      expect(state.currentSubscription?.status, 'cancelled');
    });
  });

  group('Widget Tests: SubscriptionScreen & VipCheckoutSheet', () {
    late FakeApiSubscriptionRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeApiSubscriptionRepository();
    });

    testWidgets('SubscriptionScreen renders non-subscriber view with CONTINUE TO CHECKOUT button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      fakeRepo.currentToReturn = null;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiSubscriptionRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: SubscriptionScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('CHOOSE YOUR ROYAL RANK'), findsOneWidget);
      expect(find.text('KNIGHT PASS'), findsOneWidget);
      expect(find.text('BARON PASS'), findsOneWidget);
      expect(find.byKey(const Key('continue_to_checkout_button')), findsOneWidget);
    });

    testWidgets('SubscriptionScreen renders active subscriber view with CLAIM and CANCEL buttons',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      fakeRepo.currentToReturn = SubscriptionDto(
        tier: 'knight',
        status: 'active',
        startedAt: DateTime.now(),
        currentPeriodEnd: DateTime.now().add(const Duration(days: 30)),
        autoRenew: true,
        canClaimDailyReward: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiSubscriptionRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: SubscriptionScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('YOUR VIP MEMBERSHIP'), findsOneWidget);
      expect(find.byKey(const Key('claim_daily_reward_button')), findsOneWidget);
      expect(find.byKey(const Key('cancel_subscription_button')), findsOneWidget);
    });

    testWidgets('VipCheckoutSheet debug decline toggle triggers inline error',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      fakeRepo.currentToReturn = null;
      fakeRepo.shouldFailCheckout = true;

      final plan = SubscriptionPlanDto(
        tier: 'knight',
        title: 'KNIGHT PASS',
        price: 4.99,
        currency: 'USD',
        dailyCoins: 200,
        dailyDiamonds: 5,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiSubscriptionRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => VipCheckoutSheet.show(context, plan),
                  child: const Text('Open Checkout'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Checkout'));
      await tester.pumpAndSettle();

      expect(find.text('CHECKOUT - KNIGHT PASS'), findsOneWidget);

      // Toggle simulate decline switch
      if (kDebugMode) {
        expect(find.byKey(const Key('simulate_decline_switch')), findsOneWidget);
        await tester.tap(find.byKey(const Key('simulate_decline_switch')));
        await tester.pumpAndSettle();
      }

      // Tap Pay button
      await tester.tap(find.text('PAY \$4.99 & ACTIVATE VIP'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 600)); // processing spinner
      await tester.pump(const Duration(milliseconds: 800)); // finishes delay
      await tester.pumpAndSettle();

      expect(find.text('Forced dummy payment failure'), findsOneWidget);
    });

    testWidgets('In-flight state replaces buttons with CircularProgressIndicator preventing double-tap',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      fakeRepo.currentToReturn = SubscriptionDto(
        tier: 'knight',
        status: 'active',
        startedAt: DateTime.now(),
        currentPeriodEnd: DateTime.now().add(const Duration(days: 30)),
        autoRenew: true,
        canClaimDailyReward: true,
      );

      fakeRepo.claimDelay = const Duration(milliseconds: 500);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiSubscriptionRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: SubscriptionScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap claim reward
      await tester.tap(find.byKey(const Key('claim_daily_reward_button')));
      await tester.pump(); // Start async request, sets isClaimLoading = true

      // Button is replaced by CircularProgressIndicator while in-flight
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byKey(const Key('claim_daily_reward_button')), findsNothing);

      await tester.pump(const Duration(milliseconds: 600)); // Delay finishes
      await tester.pumpAndSettle(); // Request completes
      expect(find.text('REWARD CLAIMED TODAY'), findsOneWidget);
    });
  });
}

