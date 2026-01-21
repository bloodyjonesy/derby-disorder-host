/// Represents a player in the game
class Player {
  final String id;
  final String name;
  final int balance;
  final int hype;
  final String socketId;
  final bool isBroke; // true when balance reaches 0, player stays in game but can't bet
  final bool isViewer; // true if joined after tournament started - can watch but not bet

  const Player({
    required this.id,
    required this.name,
    required this.balance,
    required this.hype,
    required this.socketId,
    required this.isBroke,
    this.isViewer = false,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      balance: json['balance'] as int? ?? 0,
      hype: json['hype'] as int? ?? 0,
      socketId: json['socketId'] as String,
      isBroke: json['isBroke'] as bool? ?? false,
      isViewer: json['isViewer'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'hype': hype,
      'socketId': socketId,
      'isBroke': isBroke,
      'isViewer': isViewer,
    };
  }

  Player copyWith({
    String? id,
    String? name,
    int? balance,
    int? hype,
    String? socketId,
    bool? isBroke,
    bool? isViewer,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      hype: hype ?? this.hype,
      socketId: socketId ?? this.socketId,
      isBroke: isBroke ?? this.isBroke,
      isViewer: isViewer ?? this.isViewer,
    );
  }
}
