/// Bet type classification
enum BetType {
  win('WIN'),
  place('PLACE'),
  longshot('LONGSHOT');

  final String value;
  const BetType(this.value);

  static BetType fromString(String value) {
    return BetType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => BetType.win,
    );
  }
}

/// Represents a bet placed by a player
class Bet {
  final String playerId;
  final String participantId;
  final BetType betType;
  final int amount;

  const Bet({
    required this.playerId,
    required this.participantId,
    required this.betType,
    required this.amount,
  });

  factory Bet.fromJson(Map<String, dynamic> json) {
    // Handle amount being int, double, or string
    int amount = 0;
    final amountValue = json['amount'];
    if (amountValue is int) {
      amount = amountValue;
    } else if (amountValue is double) {
      amount = amountValue.toInt();
    } else if (amountValue is String) {
      amount = int.tryParse(amountValue) ?? 0;
    }
    
    return Bet(
      playerId: json['playerId'] as String? ?? '',
      participantId: json['participantId'] as String? ?? '',
      betType: BetType.fromString(json['betType'] as String? ?? 'WIN'),
      amount: amount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'participantId': participantId,
      'betType': betType.value,
      'amount': amount,
    };
  }
}
