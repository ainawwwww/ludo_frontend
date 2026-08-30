class StoreItemModel {
  final int id;
  final String name;
  final String type; // avatar, dice_skin, board_theme
  final int price;
  final String currencyType; // coins, diamonds
  final String? imageUrl;
  final bool isEquipped;

  StoreItemModel({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.currencyType,
    this.imageUrl,
    this.isEquipped = false,
  });

  factory StoreItemModel.fromJson(Map<String, dynamic> json) {
    return StoreItemModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? 'Item',
      type: json['type']?.toString() ?? 'dice_skin',
      price: json['price'] is int
          ? json['price']
          : int.tryParse(json['price'].toString()) ?? 0,
      currencyType: json['currency_type']?.toString() ?? 'coins',
      imageUrl: json['image_url']?.toString(),
      isEquipped: json['is_equipped'] == true || json['is_equipped'] == 1,
    );
  }
}
