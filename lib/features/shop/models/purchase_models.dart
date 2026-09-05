import 'package:flutter/foundation.dart';

enum PackageBadgeType {
  none,
  hot,
  popular,
  best,
}

class PurchasePackage {
  final String id;
  final String amount;
  final int value;
  final String priceUsd;
  final String iconAsset;
  final PackageBadgeType badgeType;
  final String? bonusTag;

  const PurchasePackage({
    required this.id,
    required this.amount,
    required this.value,
    required this.priceUsd,
    required this.iconAsset,
    this.badgeType = PackageBadgeType.none,
    this.bonusTag,
  });
}

class PrivilegeItem {
  final String id;
  final String title;
  final String iconAsset;

  const PrivilegeItem({
    required this.id,
    required this.title,
    required this.iconAsset,
  });
}

class SubscriptionTierData {
  final String id;
  final String name;
  final String shieldIconAsset;
  final String emblemAsset;
  final String monthlyPrice;
  final String dailyCoins;
  final String dailyDiamonds;
  final int dailyChests;
  final List<PrivilegeItem> privileges;

  const SubscriptionTierData({
    required this.id,
    required this.name,
    required this.shieldIconAsset,
    required this.emblemAsset,
    required this.monthlyPrice,
    required this.dailyCoins,
    required this.dailyDiamonds,
    required this.dailyChests,
    required this.privileges,
  });
}

class PurchaseScreenData {
  static const List<PurchasePackage> goldPackages = [
    PurchasePackage(
      id: 'gold_tier_1',
      amount: '33k',
      value: 33000,
      priceUsd: 'USD 0.99',
      iconAsset:
          'assets/graphics/purchase_screen/gold_tab/tier1_icon_33k_coins.png',
      badgeType: PackageBadgeType.none,
    ),
    PurchasePackage(
      id: 'gold_tier_2',
      amount: '130.0k',
      value: 130000,
      priceUsd: 'USD 3.99',
      iconAsset:
          'assets/graphics/purchase_screen/gold_tab/tier2_icon_130k_coinbag.png',
      badgeType: PackageBadgeType.hot,
    ),
    PurchasePackage(
      id: 'gold_tier_3',
      amount: '670.0k',
      value: 670000,
      priceUsd: 'USD 9.99',
      iconAsset:
          'assets/graphics/purchase_screen/gold_tab/tier3_icon_670k_coinbag.png',
      badgeType: PackageBadgeType.hot,
    ),
    PurchasePackage(
      id: 'gold_tier_4',
      amount: '2.7M',
      value: 2700000,
      priceUsd: 'USD 29.99',
      iconAsset:
          'assets/graphics/purchase_screen/gold_tab/tier4_icon_2_7m_chest_small.png',
      badgeType: PackageBadgeType.popular,
    ),
    PurchasePackage(
      id: 'gold_tier_5',
      amount: '7.7M',
      value: 7700000,
      priceUsd: 'USD 79.99',
      iconAsset:
          'assets/graphics/purchase_screen/gold_tab/tier5_6_icon_7_7m_17m_chest_big.png',
      badgeType: PackageBadgeType.popular,
    ),
    PurchasePackage(
      id: 'gold_tier_6',
      amount: '17.0M',
      value: 17000000,
      priceUsd: 'USD 199.99',
      iconAsset:
          'assets/graphics/purchase_screen/gold_tab/tier5_6_icon_7_7m_17m_chest_big.png',
      badgeType: PackageBadgeType.best,
    ),
  ];

  static const List<PurchasePackage> diamondPackages = [
    PurchasePackage(
      id: 'diamond_tier_1',
      amount: '300',
      value: 300,
      priceUsd: 'USD 0.99',
      iconAsset:
          'assets/graphics/purchase_screen/diamond_tab/tier1_icon_300_diamonds_small.png',
      badgeType: PackageBadgeType.none,
    ),
    PurchasePackage(
      id: 'diamond_tier_2',
      amount: '1800',
      value: 1800,
      priceUsd: 'USD 3.99',
      iconAsset:
          'assets/graphics/purchase_screen/diamond_tab/tier2_icon_1800_diamond_single.png',
      badgeType: PackageBadgeType.hot,
    ),
    PurchasePackage(
      id: 'diamond_tier_3',
      amount: '5000',
      value: 5000,
      priceUsd: 'USD 9.99',
      iconAsset:
          'assets/graphics/purchase_screen/diamond_tab/tier3_icon_5000_diamond_detailed.png',
      badgeType: PackageBadgeType.hot,
    ),
    PurchasePackage(
      id: 'diamond_tier_4',
      amount: '16.0K',
      value: 16000,
      priceUsd: 'USD 29.99',
      iconAsset:
          'assets/graphics/purchase_screen/diamond_tab/tier4_icon_16k_diamond_bag_small.png',
      badgeType: PackageBadgeType.popular,
    ),
    PurchasePackage(
      id: 'diamond_tier_5',
      amount: '53.7K',
      value: 53700,
      priceUsd: 'USD 79.99',
      iconAsset:
          'assets/graphics/purchase_screen/diamond_tab/tier5_icon_53_7k_diamond_bag_popular.png',
      badgeType: PackageBadgeType.popular,
    ),
    PurchasePackage(
      id: 'diamond_tier_6',
      amount: '161.7K',
      value: 161700,
      priceUsd: 'USD 199.99',
      iconAsset:
          'assets/graphics/purchase_screen/diamond_tab/tier6_icon_161_7k_chest_bag_best.png',
      badgeType: PackageBadgeType.best,
    ),
  ];

  static const List<PrivilegeItem> standardPrivileges = [
    PrivilegeItem(
      id: 'priv_1',
      title: 'Exclusive logo and Display',
      iconAsset:
          'assets/graphics/purchase_screen/subscription_tab/privilege1_icon_exclusive_logo_display.png',
    ),
    PrivilegeItem(
      id: 'priv_2',
      title: 'The right to create or join a VIP room',
      iconAsset:
          'assets/graphics/purchase_screen/subscription_tab/privilege2_icon_vip_room.png',
    ),
    PrivilegeItem(
      id: 'priv_3',
      title: 'Subscribe to get daily benefits',
      iconAsset:
          'assets/graphics/purchase_screen/subscription_tab/privilege3_icon_daily_benefits.png',
    ),
    PrivilegeItem(
      id: 'priv_4',
      title: 'Priority display on the friend list',
      iconAsset:
          'assets/graphics/purchase_screen/subscription_tab/privilege4_icon_priority_friendlist.png',
    ),
    PrivilegeItem(
      id: 'priv_5',
      title: 'Front row on the online user list in room',
      iconAsset:
          'assets/graphics/purchase_screen/subscription_tab/privilege5_icon_front_row.png',
    ),
    PrivilegeItem(
      id: 'priv_6',
      title: 'Use exclusive profile frame to decorate your profile photo',
      iconAsset:
          'assets/graphics/purchase_screen/subscription_tab/privilege6_icon_profile_frame.png',
    ),
  ];

  static const List<PrivilegeItem> baronPrivileges = [
    PrivilegeItem(
      id: 'priv_1',
      title: 'Exclusive logo and Display',
      iconAsset:
          'assets/graphics/purchase_screen/subscription_tab/privilege1_icon_exclusive_logo_display.png',
    ),
    PrivilegeItem(
      id: 'priv_2',
      title: 'The right to create or join a VIP room',
      iconAsset:
          'assets/graphics/purchase_screen/subscription_tab/privilege2_icon_vip_room.png',
    ),
    PrivilegeItem(
      id: 'priv_3',
      title: 'Subscribe to get daily benefits',
      iconAsset:
          'assets/graphics/purchase_screen/subscription_tab/privilege3_icon_daily_benefits.png',
    ),
    PrivilegeItem(
      id: 'priv_4',
      title: 'Priority display on the friend list',
      iconAsset:
          'assets/graphics/purchase_screen/subscription_tab/privilege4_icon_priority_friendlist.png',
    ),
    PrivilegeItem(
      id: 'priv_5',
      title: 'Front row on the online user list in room',
      iconAsset:
          'assets/graphics/purchase_screen/subscription_tab/privilege5_icon_front_row.png',
    ),
    PrivilegeItem(
      id: 'priv_6',
      title: 'Use exclusive profile frame to decorate your profile photo',
      iconAsset:
          'assets/graphics/purchase_screen/subscription_tab/privilege6_icon_profile_frame.png',
    ),
    PrivilegeItem(
      id: 'priv_7',
      title: 'Exclusive chat bubble and room theme',
      iconAsset:
          'assets/graphics/purchase_screen/unused_or_verify/icon_picture_frame_alt.png',
    ),
    PrivilegeItem(
      id: 'priv_8',
      title: 'Exclusive Royal Pegasus vehicle',
      iconAsset:
          'assets/graphics/purchase_screen/unused_or_verify/icon_horse_mascot.png',
    ),
  ];

  static const SubscriptionTierData knightTier = SubscriptionTierData(
    id: 'knight',
    name: 'KNIGHT',
    shieldIconAsset:
        'assets/graphics/purchase_screen/subscription_tab/icon_knight_shield_small.png',
    emblemAsset:
        'assets/graphics/purchase_screen/subscription_tab/emblem_knight_large.png',
    monthlyPrice: '\$11.99',
    dailyCoins: '28,000',
    dailyDiamonds: '20',
    dailyChests: 1,
    privileges: standardPrivileges,
  );

  static const SubscriptionTierData baronTier = SubscriptionTierData(
    id: 'baron',
    name: 'BARON',
    shieldIconAsset:
        'assets/graphics/purchase_screen/subscription_tab/icon_baron_shield_small.png',
    emblemAsset:
        'assets/graphics/purchase_screen/subscription_tab/emblem_baron_large.png',
    monthlyPrice: '\$39.99',
    dailyCoins: '57,777',
    dailyDiamonds: '60',
    dailyChests: 1,
    privileges: baronPrivileges,
  );
}
