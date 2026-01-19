/// Item type classification
enum ItemType {
  bananaPeel('BANANA_PEEL'),
  sugarCube('SUGAR_CUBE'),
  oilSlick('OIL_SLICK'),
  rocketBoost('ROCKET_BOOST');

  final String value;
  const ItemType(this.value);

  static ItemType fromString(String value) {
    return ItemType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ItemType.bananaPeel,
    );
  }

  String get displayName {
    switch (this) {
      case ItemType.bananaPeel:
        return 'Banana Peel';
      case ItemType.sugarCube:
        return 'Sugar Cube';
      case ItemType.oilSlick:
        return 'Oil Slick';
      case ItemType.rocketBoost:
        return 'Rocket Boost';
    }
  }

  String get emoji {
    switch (this) {
      case ItemType.bananaPeel:
        return '🍌';
      case ItemType.sugarCube:
        return '🧊';
      case ItemType.oilSlick:
        return '🛢️';
      case ItemType.rocketBoost:
        return '🚀';
    }
  }
}

/// Represents an item used in the game
class Item {
  final ItemType type;
  final String targetParticipantId;
  final String usedBy; // playerId

  const Item({
    required this.type,
    required this.targetParticipantId,
    required this.usedBy,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      type: ItemType.fromString(json['type'] as String),
      targetParticipantId: json['targetParticipantId'] as String,
      usedBy: json['usedBy'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
      'targetParticipantId': targetParticipantId,
      'usedBy': usedBy,
    };
  }
}
