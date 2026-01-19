import 'dart:math';

/// Represents a rivalry/battle between two players
class Rivalry {
  final String player1Id;
  final String player2Id;
  final int raceNumber;
  
  String? winnerId;  // Set after race
  String? loserId;   // Set after race
  int player1Profit = 0;
  int player2Profit = 0;

  Rivalry({
    required this.player1Id,
    required this.player2Id,
    required this.raceNumber,
  });

  bool involves(String playerId) => player1Id == playerId || player2Id == playerId;
  
  String getOpponent(String playerId) {
    if (player1Id == playerId) return player2Id;
    if (player2Id == playerId) return player1Id;
    return '';
  }
}

/// Side bet between two players
class SideBet {
  final String challengerId;
  final String targetId;
  final String challengerPickId;  // Participant ID challenger thinks will win
  final String targetPickId;      // Participant ID target bet on
  final String stakes;            // e.g., "a shot", "finish your drink"
  final int raceNumber;
  
  bool? challengerWon;  // Set after race

  SideBet({
    required this.challengerId,
    required this.targetId,
    required this.challengerPickId,
    required this.targetPickId,
    required this.stakes,
    required this.raceNumber,
  });
}

/// Drinking rule card
class DrinkingCard {
  final String id;
  final String title;
  final String description;
  final DrinkingCardType type;
  final String emoji;

  const DrinkingCard({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.emoji,
  });

  static final List<DrinkingCard> allCards = [
    const DrinkingCard(
      id: 'underdog',
      title: 'UNDERDOG RULE',
      description: 'If a longshot wins, everyone who didn\'t bet on them drinks!',
      type: DrinkingCardType.raceEnd,
      emoji: '🐴',
    ),
    const DrinkingCard(
      id: 'photo_finish',
      title: 'PHOTO FINISH',
      description: 'If top 2 are within 1% at the end, everyone takes a sip!',
      type: DrinkingCardType.raceEnd,
      emoji: '📸',
    ),
    const DrinkingCard(
      id: 'chaos_round',
      title: 'CHAOS ROUND',
      description: 'Biggest loser picks someone to drink with them!',
      type: DrinkingCardType.raceEnd,
      emoji: '🎪',
    ),
    const DrinkingCard(
      id: 'double_down',
      title: 'DOUBLE DOWN',
      description: 'Win = opponent drinks double. Lose = you drink double!',
      type: DrinkingCardType.betting,
      emoji: '⬆️',
    ),
    const DrinkingCard(
      id: 'favorite_falls',
      title: 'FAVORITE FALLS',
      description: 'If the crowd favorite loses, all who bet on them drink!',
      type: DrinkingCardType.raceEnd,
      emoji: '📉',
    ),
    const DrinkingCard(
      id: 'comeback_king',
      title: 'COMEBACK KING',
      description: 'If someone comes from last at halfway to top 3, celebrate!',
      type: DrinkingCardType.raceEnd,
      emoji: '👑',
    ),
    const DrinkingCard(
      id: 'all_in',
      title: 'ALL IN ROUND',
      description: 'Anyone who bets their entire balance drinks win or lose!',
      type: DrinkingCardType.betting,
      emoji: '💰',
    ),
    const DrinkingCard(
      id: 'waterfall',
      title: 'WATERFALL',
      description: 'If any racer laps another, waterfall starting with the leader!',
      type: DrinkingCardType.duringRace,
      emoji: '🌊',
    ),
  ];

  static DrinkingCard getRandomCard() {
    return allCards[Random().nextInt(allCards.length)];
  }
}

enum DrinkingCardType {
  betting,      // Affects betting phase
  duringRace,   // Affects during race
  raceEnd,      // Affects race results
}

/// Player drink tracking
class DrinkTracker {
  final Map<String, int> _drinks = {};
  
  int getDrinks(String playerId) => _drinks[playerId] ?? 0;
  
  void addDrink(String playerId, {int count = 1}) {
    _drinks[playerId] = (_drinks[playerId] ?? 0) + count;
  }
  
  void reset() => _drinks.clear();
  
  List<MapEntry<String, int>> getSortedByDrinks() {
    final entries = _drinks.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }
  
  String? getMostSober() {
    if (_drinks.isEmpty) return null;
    return _drinks.entries.reduce((a, b) => a.value < b.value ? a : b).key;
  }
  
  String? getPartyChampion() {
    if (_drinks.isEmpty) return null;
    return _drinks.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}

/// Hot seat state
class HotSeat {
  String? currentPlayerId;
  int rotationIndex = 0;
  
  void rotate(List<String> playerIds) {
    if (playerIds.isEmpty) {
      currentPlayerId = null;
      return;
    }
    rotationIndex = (rotationIndex + 1) % playerIds.length;
    currentPlayerId = playerIds[rotationIndex];
  }
  
  void reset() {
    currentPlayerId = null;
    rotationIndex = 0;
  }
}

/// Complete party state
class PartyState {
  final List<Rivalry> rivalries = [];
  final List<SideBet> sideBets = [];
  final DrinkTracker drinkTracker = DrinkTracker();
  final HotSeat hotSeat = HotSeat();
  
  DrinkingCard? currentCard;
  int currentRace = 0;
  Rivalry? currentRivalry;
  
  /// Start a new race with party features
  void startNewRace(List<String> playerIds) {
    currentRace++;
    
    // Draw a new drinking card
    currentCard = DrinkingCard.getRandomCard();
    
    // Create rivalry if we have at least 2 players
    if (playerIds.length >= 2) {
      final shuffled = List<String>.from(playerIds)..shuffle();
      currentRivalry = Rivalry(
        player1Id: shuffled[0],
        player2Id: shuffled[1],
        raceNumber: currentRace,
      );
      rivalries.add(currentRivalry!);
    }
    
    // Rotate hot seat
    hotSeat.rotate(playerIds);
  }
  
  /// Resolve rivalry after race
  void resolveRivalry(Map<String, int> profits) {
    if (currentRivalry == null) return;
    
    final p1Profit = profits[currentRivalry!.player1Id] ?? 0;
    final p2Profit = profits[currentRivalry!.player2Id] ?? 0;
    
    currentRivalry!.player1Profit = p1Profit;
    currentRivalry!.player2Profit = p2Profit;
    
    if (p1Profit > p2Profit) {
      currentRivalry!.winnerId = currentRivalry!.player1Id;
      currentRivalry!.loserId = currentRivalry!.player2Id;
    } else if (p2Profit > p1Profit) {
      currentRivalry!.winnerId = currentRivalry!.player2Id;
      currentRivalry!.loserId = currentRivalry!.player1Id;
    }
    // If tie, no loser
  }
  
  /// Reset for new game
  void reset() {
    rivalries.clear();
    sideBets.clear();
    drinkTracker.reset();
    hotSeat.reset();
    currentCard = null;
    currentRace = 0;
    currentRivalry = null;
  }
}
