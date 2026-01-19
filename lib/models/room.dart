import 'game_state.dart';
import 'player.dart';
import 'participant.dart';
import 'bet.dart';
import 'race_snapshot.dart';
import 'race_result.dart';
import 'item.dart';

/// Represents a game room
class Room {
  final String roomCode;
  final List<Player> players;
  final GameState gameState;
  final Map<String, Bet> bets; // playerId -> Bet
  final List<Participant> participants;
  final List<RaceSnapshot>? raceData;
  final RaceResult? raceResult;
  final List<Item> items;
  final int chaosMeter; // 0-100
  final int? timer; // seconds remaining in current phase
  final int raceNumber; // Current race number
  final Map<String, dynamic>? settings; // Game settings
  // Party mode fields from server
  final String? hotSeatPlayerId; // Player in the hot seat
  final String? favoriteParticipantId; // The race favorite

  const Room({
    required this.roomCode,
    required this.players,
    required this.gameState,
    required this.bets,
    required this.participants,
    this.raceData,
    this.raceResult,
    required this.items,
    required this.chaosMeter,
    this.timer,
    this.raceNumber = 0,
    this.settings,
    this.hotSeatPlayerId,
    this.favoriteParticipantId,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    // Parse bets
    final betsMap = <String, Bet>{};
    final betsJson = json['bets'];
    if (betsJson != null && betsJson is Map) {
      for (final entry in betsJson.entries) {
        betsMap[entry.key.toString()] = Bet.fromJson(
          Map<String, dynamic>.from(entry.value as Map),
        );
      }
    }

    // Parse race data
    List<RaceSnapshot>? raceData;
    final raceDataJson = json['raceData'] as List<dynamic>?;
    if (raceDataJson != null) {
      raceData = raceDataJson
          .map((e) => RaceSnapshot.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return Room(
      roomCode: json['roomCode'] as String,
      players: (json['players'] as List<dynamic>?)
              ?.map((e) => Player.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      gameState: GameState.fromString(json['gameState'] as String),
      bets: betsMap,
      participants: (json['participants'] as List<dynamic>?)
              ?.map((e) => Participant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      raceData: raceData,
      raceResult: json['raceResult'] != null
          ? RaceResult.fromJson(json['raceResult'] as Map<String, dynamic>)
          : null,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => Item.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      chaosMeter: json['chaosMeter'] as int? ?? 0,
      timer: json['timer'] as int?,
      raceNumber: json['raceNumber'] as int? ?? 0,
      settings: json['settings'] as Map<String, dynamic>?,
      hotSeatPlayerId: json['hotSeatPlayerId'] as String?,
      favoriteParticipantId: json['favoriteParticipantId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomCode': roomCode,
      'players': players.map((e) => e.toJson()).toList(),
      'gameState': gameState.value,
      'bets': bets.map((key, value) => MapEntry(key, value.toJson())),
      'participants': participants.map((e) => e.toJson()).toList(),
      'raceData': raceData?.map((e) => e.toJson()).toList(),
      'raceResult': raceResult?.toJson(),
      'items': items.map((e) => e.toJson()).toList(),
      'chaosMeter': chaosMeter,
      'timer': timer,
      'raceNumber': raceNumber,
      'settings': settings,
      'hotSeatPlayerId': hotSeatPlayerId,
      'favoriteParticipantId': favoriteParticipantId,
    };
  }

  Room copyWith({
    String? roomCode,
    List<Player>? players,
    GameState? gameState,
    Map<String, Bet>? bets,
    List<Participant>? participants,
    List<RaceSnapshot>? raceData,
    RaceResult? raceResult,
    List<Item>? items,
    int? chaosMeter,
    int? timer,
    int? raceNumber,
    Map<String, dynamic>? settings,
    String? hotSeatPlayerId,
    String? favoriteParticipantId,
  }) {
    return Room(
      roomCode: roomCode ?? this.roomCode,
      players: players ?? this.players,
      gameState: gameState ?? this.gameState,
      bets: bets ?? this.bets,
      participants: participants ?? this.participants,
      raceData: raceData ?? this.raceData,
      raceResult: raceResult ?? this.raceResult,
      items: items ?? this.items,
      chaosMeter: chaosMeter ?? this.chaosMeter,
      timer: timer ?? this.timer,
      raceNumber: raceNumber ?? this.raceNumber,
      settings: settings ?? this.settings,
      hotSeatPlayerId: hotSeatPlayerId ?? this.hotSeatPlayerId,
      favoriteParticipantId: favoriteParticipantId ?? this.favoriteParticipantId,
    );
  }

  /// Get a player's bet
  Bet? getBet(String playerId) => bets[playerId];

  /// Get a participant by ID
  Participant? getParticipant(String id) {
    try {
      return participants.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get participant name for a bet
  String? getParticipantNameForBet(String playerId) {
    final bet = getBet(playerId);
    if (bet == null) return null;
    return getParticipant(bet.participantId)?.name;
  }

  /// Get the favorite participant (highest combined zoomies + chonk)
  Participant? getFavorite() {
    if (participants.isEmpty) return null;
    
    Participant? favorite;
    int highestScore = -1;
    
    for (final p in participants) {
      // Score based on speed (zoomies) and stamina (chonk), with slight boost for low derp (consistency)
      final score = p.zoomies * 2 + p.chonk + (10 - p.derp);
      if (score > highestScore) {
        highestScore = score;
        favorite = p;
      }
    }
    
    return favorite;
  }

  /// Check if a participant is the favorite
  bool isFavorite(String participantId) {
    return getFavorite()?.id == participantId;
  }
}
