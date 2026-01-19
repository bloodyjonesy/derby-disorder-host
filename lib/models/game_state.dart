/// Game state phases
enum GameState {
  lobby('LOBBY'),
  paddock('PADDOCK'),
  wager('WAGER'),
  sabotage('SABOTAGE'),
  racing('RACING'),
  results('RESULTS');

  final String value;
  const GameState(this.value);

  static GameState fromString(String value) {
    return GameState.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GameState.lobby,
    );
  }

  String toJson() => value;
}
