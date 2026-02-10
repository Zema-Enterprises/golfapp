import 'package:json_annotation/json_annotation.dart';

part 'avatar.g.dart';

/// Avatar item type
enum ItemType {
  @JsonValue('HAT')
  hat,
  @JsonValue('SHIRT')
  shirt,
  @JsonValue('SHOES')
  shoes,
  @JsonValue('ACCESSORY')
  accessory,
  @JsonValue('CLUB_SKIN')
  clubSkin,
}

/// Item rarity
enum Rarity {
  @JsonValue('COMMON')
  common,
  @JsonValue('UNCOMMON')
  uncommon,
  @JsonValue('RARE')
  rare,
  @JsonValue('LEGENDARY')
  legendary,
}

/// Avatar item from shop
/// Backend returns: id, name, type, imageUrl, unlockStars, isPremium, rarity
@JsonSerializable()
class AvatarItem {
  final String id;
  final ItemType type;
  final String name;
  final String? imageUrl;
  @JsonKey(defaultValue: 0)
  final int unlockStars;
  @JsonKey(defaultValue: Rarity.common)
  final Rarity rarity;
  @JsonKey(defaultValue: false)
  final bool isPremium;

  const AvatarItem({
    required this.id,
    required this.type,
    required this.name,
    this.imageUrl,
    required this.unlockStars,
    required this.rarity,
    required this.isPremium,
  });

  factory AvatarItem.fromJson(Map<String, dynamic> json) =>
      _$AvatarItemFromJson(json);
  Map<String, dynamic> toJson() => _$AvatarItemToJson(this);

  AvatarItem copyWith({
    String? id,
    ItemType? type,
    String? name,
    String? imageUrl,
    int? unlockStars,
    Rarity? rarity,
    bool? isPremium,
  }) {
    return AvatarItem(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      unlockStars: unlockStars ?? this.unlockStars,
      rarity: rarity ?? this.rarity,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  /// Display name for item type
  String get typeDisplayName {
    switch (type) {
      case ItemType.hat:
        return 'Hat';
      case ItemType.shirt:
        return 'Shirt';
      case ItemType.shoes:
        return 'Shoes';
      case ItemType.accessory:
        return 'Accessory';
      case ItemType.clubSkin:
        return 'Club Skin';
    }
  }

  /// Display name for rarity
  String get rarityDisplayName {
    switch (rarity) {
      case Rarity.common:
        return 'Common';
      case Rarity.uncommon:
        return 'Uncommon';
      case Rarity.rare:
        return 'Rare';
      case Rarity.legendary:
        return 'Legendary';
    }
  }

  /// Check if item is free
  bool get isFree => unlockStars == 0;
}

/// Child's avatar state with equipped items
/// Backend returns: childId, equippedItems (AvatarItem[]), ownedItems (AvatarItem[]), avatarState (map)
@JsonSerializable()
class AvatarState {
  final String childId;
  @JsonKey(defaultValue: [])
  final List<AvatarItem> equippedItems;
  @JsonKey(defaultValue: [])
  final List<AvatarItem> ownedItems;
  @JsonKey(defaultValue: {})
  final Map<String, dynamic> avatarState;

  const AvatarState({
    required this.childId,
    this.equippedItems = const [],
    this.ownedItems = const [],
    this.avatarState = const {},
  });

  factory AvatarState.fromJson(Map<String, dynamic> json) =>
      _$AvatarStateFromJson(json);
  Map<String, dynamic> toJson() => _$AvatarStateToJson(this);

  AvatarState copyWith({
    String? childId,
    List<AvatarItem>? equippedItems,
    List<AvatarItem>? ownedItems,
    Map<String, dynamic>? avatarState,
  }) {
    return AvatarState(
      childId: childId ?? this.childId,
      equippedItems: equippedItems ?? this.equippedItems,
      ownedItems: ownedItems ?? this.ownedItems,
      avatarState: avatarState ?? this.avatarState,
    );
  }

  /// Check if child owns an item
  bool ownsItem(String itemId) =>
      ownedItems.any((item) => item.id == itemId);

  /// Get equipped item ID for a type
  /// Backend uses uppercase keys (HAT, SHIRT, SHOES, ACCESSORY, CLUB_SKIN)
  String? getEquippedItemId(ItemType type) {
    const typeKeys = {
      ItemType.hat: 'HAT',
      ItemType.shirt: 'SHIRT',
      ItemType.shoes: 'SHOES',
      ItemType.accessory: 'ACCESSORY',
      ItemType.clubSkin: 'CLUB_SKIN',
    };
    return avatarState[typeKeys[type]] as String?;
  }
}

/// Shop data with all available items
@JsonSerializable()
class ShopData {
  final List<AvatarItem> items;
  final int totalItems;

  const ShopData({
    required this.items,
    required this.totalItems,
  });

  factory ShopData.fromJson(Map<String, dynamic> json) =>
      _$ShopDataFromJson(json);
  Map<String, dynamic> toJson() => _$ShopDataToJson(this);

  /// Get items by type
  List<AvatarItem> getItemsByType(ItemType type) =>
      items.where((item) => item.type == type).toList();

  /// Get items grouped by type
  Map<ItemType, List<AvatarItem>> get itemsByType {
    final grouped = <ItemType, List<AvatarItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.type, () => []).add(item);
    }
    return grouped;
  }
}

/// Purchase request
@JsonSerializable()
class PurchaseRequest {
  final String itemId;

  const PurchaseRequest({required this.itemId});

  factory PurchaseRequest.fromJson(Map<String, dynamic> json) =>
      _$PurchaseRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PurchaseRequestToJson(this);
}

/// Equip request
@JsonSerializable()
class EquipRequest {
  final String itemId;

  const EquipRequest({required this.itemId});

  factory EquipRequest.fromJson(Map<String, dynamic> json) =>
      _$EquipRequestFromJson(json);
  Map<String, dynamic> toJson() => _$EquipRequestToJson(this);
}
