import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/features/subscription/models/subscription_models.dart';

final apiSubscriptionRepositoryProvider = Provider<ApiSubscriptionRepository>((ref) {
  return ApiSubscriptionRepository(ref.watch(apiClientProvider));
});

class ApiSubscriptionRepository {
  ApiSubscriptionRepository(this._client);

  final ApiClient _client;

  static const String _plansPath = '/subscription/plans';
  static const String _currentPath = '/subscription/current';
  static const String _checkoutPath = '/subscription/checkout';
  static const String _cancelPath = '/subscription/cancel';
  static const String _claimPath = '/subscription/claim-daily-reward';

  /// GET /api/v1/subscription/plans
  Future<List<SubscriptionPlanDto>> fetchPlans() async {
    final data = await _call(() => _client.get(_plansPath));
    if (data is Map<String, dynamic> && data['data'] is List) {
      final list = data['data'] as List;
      return list.map((e) => SubscriptionPlanDto.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  /// GET /api/v1/subscription/current
  Future<SubscriptionDto?> fetchCurrentSubscription() async {
    final data = await _call(() => _client.get(_currentPath));
    if (data is Map<String, dynamic> && data['data'] != null) {
      return SubscriptionDto.fromJson(data['data'] as Map<String, dynamic>);
    }
    return null;
  }

  /// POST /api/v1/subscription/checkout
  Future<SubscriptionDto> checkout({
    required String tier,
    bool forceFailure = false,
  }) async {
    final options = forceFailure
        ? Options(headers: {'X-Dummy-Payment-Force-Failure': '1'})
        : null;

    final data = await _call(() => _client.post(
          _checkoutPath,
          data: {'tier': tier},
          options: options,
        ));

    if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
      return SubscriptionDto.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw const UnknownSubscriptionFailure('Invalid response from checkout server.');
  }

  /// POST /api/v1/subscription/cancel
  Future<SubscriptionDto> cancel() async {
    final data = await _call(() => _client.post(_cancelPath));
    if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
      return SubscriptionDto.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw const UnknownSubscriptionFailure('Invalid response from cancel server.');
  }

  /// POST /api/v1/subscription/claim-daily-reward
  Future<Map<String, int>> claimDailyReward() async {
    final data = await _call(() => _client.post(_claimPath));
    if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
      final inner = data['data'] as Map<String, dynamic>;
      return {
        'coins_claimed': (inner['coins_claimed'] as num?)?.toInt() ?? 0,
        'diamonds_claimed': (inner['diamonds_claimed'] as num?)?.toInt() ?? 0,
      };
    }
    return {'coins_claimed': 0, 'diamonds_claimed': 0};
  }

  Future<dynamic> _call(Future<dynamic> Function() fn) async {
    try {
      return await fn();
    } on DioException catch (e) {
      throw _mapDio(e);
    } on ApiException catch (e) {
      throw _mapApiException(e);
    } on SubscriptionFailure {
      rethrow;
    } catch (e) {
      if (kDebugMode) print('❌ [ApiSubscriptionRepository] Unknown error: $e');
      throw UnknownSubscriptionFailure(e.toString());
    }
  }

  SubscriptionFailure _mapDio(DioException e) {
    final status = e.response?.statusCode;
    final body = e.response?.data;
    final errorCode = _errorCode(body);
    final message = _message(body, fallback: e.message ?? 'Network error');

    if (kDebugMode) {
      print('❌ [ApiSubscriptionRepository] DioException status=$status code=$errorCode msg=$message');
    }

    return switch (errorCode) {
      'ALREADY_SUBSCRIBED' => AlreadySubscribedFailure(message),
      'PAYMENT_FAILED' => PaymentFailedFailure(message),
      'NO_ACTIVE_SUBSCRIPTION' => NoActiveSubscriptionFailure(message),
      'REWARD_ALREADY_CLAIMED' => RewardAlreadyClaimedFailure(message),
      _ => switch (status) {
          402 => PaymentFailedFailure(message),
          404 => NoActiveSubscriptionFailure(message),
          409 => AlreadySubscribedFailure(message),
          _ when e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout ||
                 e.type == DioExceptionType.connectionError =>
            NetworkSubscriptionFailure(),
          _ => UnknownSubscriptionFailure(message),
        },
    };
  }

  SubscriptionFailure _mapApiException(ApiException e) {
    return switch (e.statusCode) {
      402 => PaymentFailedFailure(e.message),
      404 => NoActiveSubscriptionFailure(e.message),
      409 => AlreadySubscribedFailure(e.message),
      _ => UnknownSubscriptionFailure(e.message),
    };
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
