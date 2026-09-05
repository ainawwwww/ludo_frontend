import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/shared/widgets/ludo_loading_overlay.dart';

/// Extension on BuildContext providing animated navigation with the compact LudoLoadingOverlay.
extension NavLoaderExtension on BuildContext {
  /// Navigate to a route location immediately
  void goWithLoader(String location, {Object? extra}) {
    go(location, extra: extra);
  }

  /// Push a route location immediately
  Future<T?> pushWithLoader<T extends Object?>(String location,
      {Object? extra}) {
    return push<T>(location, extra: extra);
  }
}
