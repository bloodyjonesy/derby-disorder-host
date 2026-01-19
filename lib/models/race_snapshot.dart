/// Represents a snapshot of the race at a point in time
class RaceSnapshot {
  final int tick;
  final Map<String, double> positions; // participantId -> position (0-100)
  final String leader; // participantId of the current leader

  const RaceSnapshot({
    required this.tick,
    required this.positions,
    required this.leader,
  });

  factory RaceSnapshot.fromJson(Map<String, dynamic> json) {
    final positionsMap = <String, double>{};
    final positionsJson = json['positions'] as Map<String, dynamic>?;
    if (positionsJson != null) {
      for (final entry in positionsJson.entries) {
        positionsMap[entry.key] = (entry.value as num).toDouble();
      }
    }

    return RaceSnapshot(
      tick: json['tick'] as int,
      positions: positionsMap,
      leader: json['leader'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tick': tick,
      'positions': positions,
      'leader': leader,
    };
  }

  /// Get position for a participant, defaulting to 0
  double getPosition(String participantId) {
    return positions[participantId] ?? 0.0;
  }
}
