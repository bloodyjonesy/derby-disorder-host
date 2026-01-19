/// Represents the final result of a race
class RaceResult {
  final List<String> finishOrder; // participantIds in finishing order
  final Map<String, int> finalPositions; // participantId -> finishing position (1st, 2nd, etc.)

  const RaceResult({
    required this.finishOrder,
    required this.finalPositions,
  });

  factory RaceResult.fromJson(Map<String, dynamic> json) {
    final positionsMap = <String, int>{};
    final positionsJson = json['finalPositions'] as Map<String, dynamic>?;
    if (positionsJson != null) {
      for (final entry in positionsJson.entries) {
        positionsMap[entry.key] = (entry.value as num).toInt();
      }
    }

    return RaceResult(
      finishOrder: (json['finishOrder'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      finalPositions: positionsMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'finishOrder': finishOrder,
      'finalPositions': finalPositions,
    };
  }

  /// Get the winner's participant ID
  String? get winnerId => finishOrder.isNotEmpty ? finishOrder.first : null;

  /// Get the finishing position for a participant
  int? getPosition(String participantId) => finalPositions[participantId];
}
