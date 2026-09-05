import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_vibe/features/shop/screens/purchase_screen.dart';
import 'package:ludo_vibe/features/shop/widgets/purchase/first_recharge_banner.dart';
import 'package:ludo_vibe/features/shop/widgets/purchase/package_card.dart';
import 'package:ludo_vibe/features/shop/widgets/purchase/privilege_item_widget.dart';
import 'package:ludo_vibe/features/shop/widgets/purchase/purchase_header.dart';
import 'package:ludo_vibe/features/shop/widgets/purchase/subscribe_footer_bar.dart';
import 'package:ludo_vibe/features/shop/widgets/purchase/tier_toggle_button.dart';

void main() {
  testWidgets('PurchaseScreen renders correctly matching Figma layout for Gold, Diamond, and Subscription tabs',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 850));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: PurchaseScreen(initialTabIndex: 0),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Header exists with avatar PRO badge and balances
    expect(find.byType(PurchaseHeader), findsOneWidget);
    expect(find.text('PRO'), findsOneWidget);

    // Verify Tab labels
    expect(find.text('Gold'), findsOneWidget);
    expect(find.text('Diamond'), findsOneWidget);
    expect(find.text('Subscription'), findsOneWidget);

    // Verify Gold tab contents (First recharge banner + 6 gold cards in 3x2 grid)
    expect(find.byType(FirstRechargeBanner), findsOneWidget);
    expect(find.text('First Reward Recharge'), findsOneWidget);
    expect(find.text('Gold Details'), findsOneWidget);
    expect(find.byType(PackageCard), findsWidgets);

    // Switch to Diamond tab
    await tester.tap(find.text('Diamond'));
    await tester.pumpAndSettle();
    expect(find.byType(PackageCard), findsWidgets);

    // Switch to Subscription tab
    await tester.tap(find.text('Subscription'));
    await tester.pumpAndSettle();

    // Verify Subscription tab widgets
    expect(find.byType(TierToggleButton), findsOneWidget);
    expect(find.text('KNIGHT'), findsOneWidget);
    expect(find.text('BARON'), findsOneWidget);
    expect(find.text('Exclusive Privileges'), findsOneWidget);
    expect(find.byType(PrivilegeItemWidget), findsWidgets);
    expect(find.byType(SubscribeFooterBar), findsOneWidget);
    expect(find.textContaining('Subscribe for a month'), findsOneWidget);
    expect(find.text('Manage Subscriptions'), findsOneWidget);

    // Toggle to Baron
    await tester.tap(find.text('BARON'));
    await tester.pumpAndSettle();
    expect(find.textContaining('\$39.99'), findsOneWidget);
  });
}
