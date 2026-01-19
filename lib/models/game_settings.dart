/// Game mode types
enum GameMode {
  regular,  // Standard racing, no drinking
  party,    // Full party mode with all features
  custom,   // Pick and choose features
}

/// Game settings model
class GameSettings {
  // Core settings
  final GameMode gameMode;
  final int maxRaces;           // 0 = endless
  final int startingBalance;
  final int hypePointsPerRound;
  
  // Timer settings (in seconds)
  final int paddockDuration;
  final int wagerDuration;
  final int sabotageDuration;
  
  // Race settings
  final int participantsPerRace;
  final int minBet;
  final int maxBet;
  
  // Party features (only apply in party/custom mode)
  final bool enableRivalries;       // Featured battle between 2 players
  final bool enableSideBets;        // Side bets between players
  final bool enableDrinkingCards;   // Random drinking rule cards
  final bool enablePunishmentWheel; // Wheel for broke players
  final bool enableHotSeat;         // Hot seat mode
  final bool enableDrinkTracker;    // Track drinks per player
  
  // Punishment wheel options
  final List<String> punishmentOptions;

  const GameSettings({
    this.gameMode = GameMode.regular,
    this.maxRaces = 5,
    this.startingBalance = 100,
    this.hypePointsPerRound = 5,
    this.paddockDuration = 30,
    this.wagerDuration = 45,
    this.sabotageDuration = 30,
    this.participantsPerRace = 6,
    this.minBet = 10,
    this.maxBet = 100,
    this.enableRivalries = true,
    this.enableSideBets = true,
    this.enableDrinkingCards = true,
    this.enablePunishmentWheel = true,
    this.enableHotSeat = true,
    this.enableDrinkTracker = true,
    this.punishmentOptions = const [
      'Take a shot! 🥃',
      'Finish your drink! 🍺',
      'Nominate someone else! 👉',
      'Drink with a friend! 🍻',
    ],
  });

  /// Create party mode settings (all features enabled)
  factory GameSettings.partyMode() {
    return const GameSettings(
      gameMode: GameMode.party,
      maxRaces: 5,
      enableRivalries: true,
      enableSideBets: true,
      enableDrinkingCards: true,
      enablePunishmentWheel: true,
      enableHotSeat: true,
      enableDrinkTracker: true,
    );
  }

  /// Create regular mode settings (no drinking features)
  factory GameSettings.regularMode() {
    return const GameSettings(
      gameMode: GameMode.regular,
      maxRaces: 5,
      enableRivalries: false,
      enableSideBets: false,
      enableDrinkingCards: false,
      enablePunishmentWheel: false,
      enableHotSeat: false,
      enableDrinkTracker: false,
    );
  }

  /// Create endless mode
  factory GameSettings.endless({bool partyMode = false}) {
    return GameSettings(
      gameMode: partyMode ? GameMode.party : GameMode.regular,
      maxRaces: 0, // 0 = endless
      enableRivalries: partyMode,
      enableSideBets: partyMode,
      enableDrinkingCards: partyMode,
      enablePunishmentWheel: partyMode,
      enableHotSeat: partyMode,
      enableDrinkTracker: partyMode,
    );
  }

  bool get isEndless => maxRaces == 0;
  bool get isPartyMode => gameMode == GameMode.party;
  bool get isCustomMode => gameMode == GameMode.custom;

  GameSettings copyWith({
    GameMode? gameMode,
    int? maxRaces,
    int? startingBalance,
    int? hypePointsPerRound,
    int? paddockDuration,
    int? wagerDuration,
    int? sabotageDuration,
    int? participantsPerRace,
    int? minBet,
    int? maxBet,
    bool? enableRivalries,
    bool? enableSideBets,
    bool? enableDrinkingCards,
    bool? enablePunishmentWheel,
    bool? enableHotSeat,
    bool? enableDrinkTracker,
    List<String>? punishmentOptions,
  }) {
    return GameSettings(
      gameMode: gameMode ?? this.gameMode,
      maxRaces: maxRaces ?? this.maxRaces,
      startingBalance: startingBalance ?? this.startingBalance,
      hypePointsPerRound: hypePointsPerRound ?? this.hypePointsPerRound,
      paddockDuration: paddockDuration ?? this.paddockDuration,
      wagerDuration: wagerDuration ?? this.wagerDuration,
      sabotageDuration: sabotageDuration ?? this.sabotageDuration,
      participantsPerRace: participantsPerRace ?? this.participantsPerRace,
      minBet: minBet ?? this.minBet,
      maxBet: maxBet ?? this.maxBet,
      enableRivalries: enableRivalries ?? this.enableRivalries,
      enableSideBets: enableSideBets ?? this.enableSideBets,
      enableDrinkingCards: enableDrinkingCards ?? this.enableDrinkingCards,
      enablePunishmentWheel: enablePunishmentWheel ?? this.enablePunishmentWheel,
      enableHotSeat: enableHotSeat ?? this.enableHotSeat,
      enableDrinkTracker: enableDrinkTracker ?? this.enableDrinkTracker,
      punishmentOptions: punishmentOptions ?? this.punishmentOptions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gameMode': gameMode.name,
      'maxRaces': maxRaces,
      'startingBalance': startingBalance,
      'hypePointsPerRound': hypePointsPerRound,
      'paddockDuration': paddockDuration,
      'wagerDuration': wagerDuration,
      'sabotageDuration': sabotageDuration,
      'participantsPerRace': participantsPerRace,
      'minBet': minBet,
      'maxBet': maxBet,
      'enableRivalries': enableRivalries,
      'enableSideBets': enableSideBets,
      'enableDrinkingCards': enableDrinkingCards,
      'enablePunishmentWheel': enablePunishmentWheel,
      'enableHotSeat': enableHotSeat,
      'enableDrinkTracker': enableDrinkTracker,
      'punishmentOptions': punishmentOptions,
    };
  }

  factory GameSettings.fromJson(Map<String, dynamic> json) {
    return GameSettings(
      gameMode: GameMode.values.firstWhere(
        (e) => e.name == json['gameMode'],
        orElse: () => GameMode.regular,
      ),
      maxRaces: json['maxRaces'] as int? ?? 5,
      startingBalance: json['startingBalance'] as int? ?? 100,
      hypePointsPerRound: json['hypePointsPerRound'] as int? ?? 5,
      paddockDuration: json['paddockDuration'] as int? ?? 30,
      wagerDuration: json['wagerDuration'] as int? ?? 45,
      sabotageDuration: json['sabotageDuration'] as int? ?? 30,
      participantsPerRace: json['participantsPerRace'] as int? ?? 6,
      minBet: json['minBet'] as int? ?? 10,
      maxBet: json['maxBet'] as int? ?? 100,
      enableRivalries: json['enableRivalries'] as bool? ?? true,
      enableSideBets: json['enableSideBets'] as bool? ?? true,
      enableDrinkingCards: json['enableDrinkingCards'] as bool? ?? true,
      enablePunishmentWheel: json['enablePunishmentWheel'] as bool? ?? true,
      enableHotSeat: json['enableHotSeat'] as bool? ?? true,
      enableDrinkTracker: json['enableDrinkTracker'] as bool? ?? true,
      punishmentOptions: (json['punishmentOptions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? const [
        'Take a shot! 🥃',
        'Finish your drink! 🍺',
        'Nominate someone else! 👉',
        'Drink with a friend! 🍻',
      ],
    );
  }
}
