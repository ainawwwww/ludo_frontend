import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../subscription/providers/subscription_provider.dart';

/// Provider checking active VIP subscription status.
final isVipEligibleProvider = Provider<bool>((ref) {
  final subState = ref.watch(subscriptionProvider);
  return subState.currentSubscription?.isActive ?? false;
});

Future<void> guardVipAction(
  BuildContext context,
  WidgetRef ref,
  FutureOr<void> Function() onAllowed,
) async {
  final isEligible = ref.read(isVipEligibleProvider);
  if (isEligible) {
    await onAllowed();
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('VIP access requires an active Knight or Baron Pass.'),
    ),
  );
  await context.push(AppConstants.subscriptionRoute);
}

