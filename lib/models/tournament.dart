/// Tournament-related models for v2

/// Represents a player's standing in the tournament
class TournamentStanding {
  final String playerId;
  final String playerName;
  final int totalPoints;
  final int raceWins;
  final int totalEarnings;
  final int currentBalance;

  const TournamentStanding({
    required this.playerId,
    required this.playerName,
    required this.totalPoints,
    required this.raceWins,
    required this.totalEarnings,
    required this.currentBalance,
  });

  factory TournamentStanding.fromJson(Map<String, dynamic> json) {
    return TournamentStanding(
      playerId: json['playerId'] as String,
      playerName: json['playerName'] as String,
      totalPoints: json['totalPoints'] as int? ?? 0,
      raceWins: json['raceWins'] as int? ?? 0,
      totalEarnings: json['totalEarnings'] as int? ?? 0,
      currentBalance: json['currentBalance'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'playerId': playerId,
    'playerName': playerName,
    'totalPoints': totalPoints,
    'raceWins': raceWins,
    'totalEarnings': totalEarnings,
    'currentBalance': currentBalance,
  };
}

/// Results from a single tournament race
class TournamentRaceResult {
  final int raceNumber;
  final String winnerId;
  final String winnerName;
  final List<TournamentPlayerResult> playerResults;

  const TournamentRaceResult({
    required this.raceNumber,
    required this.winnerId,
    required this.winnerName,
    required this.playerResults,
  });

  factory TournamentRaceResult.fromJson(Map<String, dynamic> json) {
    return TournamentRaceResult(
      raceNumber: json['raceNumber'] as int,
      winnerId: json['winnerId'] as String,
      winnerName: json['winnerName'] as String,
      playerResults: (json['playerResults'] as List<dynamic>?)
          ?.map((e) => TournamentPlayerResult.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

/// Individual player result in a tournament race
class TournamentPlayerResult {
  final String playerId;
  final bool betWon;
  final int earnings;
  final int pointsEarned;

  const TournamentPlayerResult({
    required this.playerId,
    required this.betWon,
    required this.earnings,
    required this.pointsEarned,
  });

  factory TournamentPlayerResult.fromJson(Map<String, dynamic> json) {
    return TournamentPlayerResult(
      playerId: json['playerId'] as String,
      betWon: json['betWon'] as bool? ?? false,
      earnings: json['earnings'] as int? ?? 0,
      pointsEarned: json['pointsEarned'] as int? ?? 0,
    );
  }
}

/// Full tournament state
class TournamentState {
  final bool isActive;
  final int currentRace;
  final int totalRaces;
  final List<TournamentStanding> standings;
  final String? championId;

  const TournamentState({
    required this.isActive,
    required this.currentRace,
    required this.totalRaces,
    required this.standings,
    this.championId,
  });

  factory TournamentState.fromJson(Map<String, dynamic> json) {
    return TournamentState(
      isActive: json['isActive'] as bool? ?? false,
      currentRace: json['currentRace'] as int? ?? 0,
      totalRaces: json['totalRaces'] as int? ?? 5,
      standings: (json['standings'] as List<dynamic>?)
          ?.map((e) => TournamentStanding.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      championId: json['championId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'isActive': isActive,
    'currentRace': currentRace,
    'totalRaces': totalRaces,
    'standings': standings.map((e) => e.toJson()).toList(),
    'championId': championId,
  };

  bool get isComplete => !isActive && championId != null;
  int get racesRemaining => totalRaces - currentRace;
}
