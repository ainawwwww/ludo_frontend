class GiftModel {
  final String id;
  final String name;
  final int cost;
  final String assetPath;
  final String category; // 'popular', 'luxury', 'special'
  final String description;

  const GiftModel({
    required this.id,
    required this.name,
    required this.cost,
    required this.assetPath,
    required this.category,
    required this.description,
  });

  static const List<GiftModel> defaultGifts = [
    GiftModel(
      id: 'rose',
      name: 'Crystal Rose',
      cost: 10,
      assetPath: 'assets/graphics/gifts/gift_rose.png',
      category: 'popular',
      description: 'A radiant crystal flower for good vibes',
    ),
    GiftModel(
      id: 'heart',
      name: 'Winged Ruby',
      cost: 50,
      assetPath: 'assets/graphics/gifts/gift_heart.png',
      category: 'popular',
      description: 'Show love and appreciation to the host',
    ),
    GiftModel(
      id: 'diamond',
      name: 'Royal Diamond',
      cost: 200,
      assetPath: 'assets/graphics/gifts/gift_diamond.png',
      category: 'luxury',
      description: 'Sparkling diamond fit for royalty',
    ),
    GiftModel(
      id: 'box',
      name: 'Cyber Chest',
      cost: 500,
      assetPath: 'assets/graphics/gifts/gift_box.png',
      category: 'special',
      description: 'Mystery treasure packed with surprises',
    ),
    GiftModel(
      id: 'crown',
      name: 'Celestial Crown',
      cost: 1000,
      assetPath: 'assets/graphics/gifts/gift_crown.png',
      category: 'luxury',
      description: 'Crown the king or queen of the room',
    ),
    GiftModel(
      id: 'car',
      name: 'Royal Supercar',
      cost: 2500,
      assetPath: 'assets/graphics/gifts/gift_car.png',
      category: 'luxury',
      description: 'A golden speedster making a grand entrance',
    ),
    GiftModel(
      id: 'jet',
      name: 'Private Jet',
      cost: 5000,
      assetPath: 'assets/graphics/gifts/gift_jet.png',
      category: 'luxury',
      description: 'Fly above the clouds in ultimate luxury',
    ),
    GiftModel(
      id: 'yacht',
      name: 'Royal Yacht',
      cost: 7500,
      assetPath: 'assets/graphics/gifts/gift_yacht.png',
      category: 'luxury',
      description: 'Luxury ocean cruiser for elite players',
    ),
    GiftModel(
      id: 'trophy',
      name: 'Golden Champion',
      cost: 10000,
      assetPath: 'assets/graphics/gifts/gift_trophy.png',
      category: 'special',
      description: 'Ultimate symbol of victory and prestige',
    ),
  ];
}

class SentGiftEvent {
  final String id;
  final GiftModel gift;
  final String senderName;
  final String recipientName;
  final DateTime timestamp;

  SentGiftEvent({
    required this.id,
    required this.gift,
    required this.senderName,
    required this.recipientName,
    required this.timestamp,
  });
}
