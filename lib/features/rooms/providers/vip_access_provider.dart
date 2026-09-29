import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';

/// UI-only entitlement switch. Replace with the real subscription source later.
final isVipEligibleProvider = StateProvider<bool>((ref) => false);

Future<void> guardVipAction(
  BuildContext context,
  WidgetRef ref,
  FutureOr<void> Function() onAllowed,
) async {
  if (ref.read(isVipEligibleProvider)) {
    await onAllowed();
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('VIP access needs Knight or Baron')),
  );
  await context.push(AppConstants.subscriptionRoute);
}
