import 'package:flutter/material.dart';
import 'package:ludo_vibe/features/shop/screens/purchase_screen.dart';

export 'package:ludo_vibe/features/shop/screens/purchase_screen.dart';

class PurchaseModal extends StatelessWidget {
  const PurchaseModal({
    super.key,
    this.initialTabIndex = 0,
  });

  final int initialTabIndex;

  static Future<void> show(BuildContext context, {int initialTabIndex = 0}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PurchaseScreen(initialTabIndex: initialTabIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PurchaseScreen(initialTabIndex: initialTabIndex);
  }
}
