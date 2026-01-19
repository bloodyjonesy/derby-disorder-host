import 'package:flutter/foundation.dart';
import '../models/models.dart';

/// Provider for managing party features state
class PartyProvider extends ChangeNotifier {
  final PartyState _state = PartyState();
  
  // Overlay states
  bool _showPunishmentWheel = false;
  bool _showDrinkingCard = false;
  bool _showRivalryResult = false;
  bool _showHotSeatAnnouncement = false;
  String? _wheelPlayerName;
  String? _wheelPlayerId;

  // Getters
  PartyState get state => _state;
  Rivalry? get currentRivalry => _state.currentRivalry;
  DrinkingCard? get currentCard => _state.currentCard;
  DrinkTracker get drinkTracker => _state.drinkTracker;
  HotSeat get hotSeat => _state.hotSeat;
  List<SideBet> get sideBets => _state.sideBets;
  int get currentRace => _state.currentRace;

  // Overlay visibility
  bool get showPunishmentWheel => _showPunishmentWheel;
  bool get showDrinkingCard => _showDrinkingCard;
  bool get showRivalryResult => _showRivalryResult;
  bool get showHotSeatAnnouncement => _showHotSeatAnnouncement;
  String? get wheelPlayerName => _wheelPlayerName;
  String? get wheelPlayerId => _wheelPlayerId;

  /// Start a new race with party features
  void startNewRace(List<String> playerIds, GameSettings settings) {
    // Only activate features that are enabled
    if (settings.enableDrinkingCards) {
      _state.currentCard = DrinkingCard.getRandomCard();
      _showDrinkingCard = true;
    }

    if (settings.enableRivalries && playerIds.length >= 2) {
      final shuffled = List<String>.from(playerIds)..shuffle();
      _state.currentRivalry = Rivalry(
        player1Id: shuffled[0],
        player2Id: shuffled[1],
        raceNumber: _state.currentRace + 1,
      );
      _state.rivalries.add(_state.currentRivalry!);
    }

    if (settings.enableHotSeat && playerIds.isNotEmpty) {
      _state.hotSeat.rotate(playerIds);
      _showHotSeatAnnouncement = true;
    }

    _state.currentRace++;
    notifyListeners();
  }

  /// Sync hot seat with server's value
  void syncHotSeat(String? serverHotSeatPlayerId) {
    if (serverHotSeatPlayerId != null && 
        _state.hotSeat.currentPlayerId != serverHotSeatPlayerId) {
      _state.hotSeat.currentPlayerId = serverHotSeatPlayerId;
      notifyListeners();
    }
  }

  /// Dismiss drinking card overlay
  void dismissDrinkingCard() {
    _showDrinkingCard = false;
    notifyListeners();
  }

  /// Dismiss hot seat announcement
  void dismissHotSeatAnnouncement() {
    _showHotSeatAnnouncement = false;
    notifyListeners();
  }

  /// Resolve rivalry after race
  void resolveRivalry(Map<String, int> playerProfits, GameSettings settings) {
    if (!settings.enableRivalries || _state.currentRivalry == null) return;

    final rivalry = _state.currentRivalry!;
    final p1Profit = playerProfits[rivalry.player1Id] ?? 0;
    final p2Profit = playerProfits[rivalry.player2Id] ?? 0;

    rivalry.player1Profit = p1Profit;
    rivalry.player2Profit = p2Profit;

    if (p1Profit > p2Profit) {
      rivalry.winnerId = rivalry.player1Id;
      rivalry.loserId = rivalry.player2Id;
      // Loser drinks
      if (settings.enableDrinkTracker) {
        _state.drinkTracker.addDrink(rivalry.player2Id);
      }
    } else if (p2Profit > p1Profit) {
      rivalry.winnerId = rivalry.player2Id;
      rivalry.loserId = rivalry.player1Id;
      if (settings.enableDrinkTracker) {
        _state.drinkTracker.addDrink(rivalry.player1Id);
      }
    }
    // Tie = no drinks

    _showRivalryResult = true;
    notifyListeners();
  }

  /// Dismiss rivalry result
  void dismissRivalryResult() {
    _showRivalryResult = false;
    notifyListeners();
  }

  /// Add a side bet
  void addSideBet(SideBet bet) {
    _state.sideBets.add(bet);
    notifyListeners();
  }

  /// Resolve side bets after race
  void resolveSideBets(String winnerId, GameSettings settings) {
    for (final bet in _state.sideBets.where((b) => b.raceNumber == _state.currentRace)) {
      bet.challengerWon = bet.challengerPickId == winnerId;
      
      // Add drinks
      if (settings.enableDrinkTracker) {
        final loserId = bet.challengerWon! ? bet.targetId : bet.challengerId;
        _state.drinkTracker.addDrink(loserId);
      }
    }
    notifyListeners();
  }

  /// Show punishment wheel for a player
  void showWheelForPlayer(String playerId, String playerName) {
    _wheelPlayerId = playerId;
    _wheelPlayerName = playerName;
    _showPunishmentWheel = true;
    notifyListeners();
  }

  /// Dismiss punishment wheel
  void dismissPunishmentWheel(GameSettings settings) {
    // Add a drink when wheel completes
    if (settings.enableDrinkTracker && _wheelPlayerId != null) {
      _state.drinkTracker.addDrink(_wheelPlayerId!);
    }
    _showPunishmentWheel = false;
    _wheelPlayerId = null;
    _wheelPlayerName = null;
    notifyListeners();
  }

  /// Add drink for a player
  void addDrink(String playerId, {int count = 1}) {
    _state.drinkTracker.addDrink(playerId, count: count);
    notifyListeners();
  }

  /// Check if player is in hot seat
  bool isInHotSeat(String playerId) {
    return _state.hotSeat.currentPlayerId == playerId;
  }

  /// Get current side bets for this race
  List<SideBet> getCurrentRaceSideBets() {
    return _state.sideBets.where((b) => b.raceNumber == _state.currentRace).toList();
  }

  /// Reset for new game
  void reset() {
    _state.reset();
    _showPunishmentWheel = false;
    _showDrinkingCard = false;
    _showRivalryResult = false;
    _showHotSeatAnnouncement = false;
    _wheelPlayerName = null;
    _wheelPlayerId = null;
    notifyListeners();
  }
}
