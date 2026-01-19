/// Represents betting odds for a participant
class Odds {
  final int win; // e.g., 500 means 500/1
  final int place; // Top 3 odds
  final int longshot; // Last place odds

  const Odds({
    required this.win,
    required this.place,
    required this.longshot,
  });

  factory Odds.fromJson(Map<String, dynamic> json) {
    return Odds(
      win: json['win'] as int,
      place: json['place'] as int,
      longshot: json['longshot'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'win': win,
      'place': place,
      'longshot': longshot,
    };
  }

  /// Format odds for display
  String formatWin() => '$win/1';
  String formatPlace() => '$place/1';
  String formatLongshot() => '$longshot/1';
}
