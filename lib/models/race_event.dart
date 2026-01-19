/// Race event types
enum RaceEventType {
  overtake,
  closeBattle,
  boost,
  stumble,
  leaderChange,
  sprintBurst,
  fatigue,
  finish,
  photoFinish,
}

/// Represents an event that occurred during a race tick
class RaceEvent {
  final RaceEventType type;
  final int tick;
  final List<String> participantIds;
  final String? message;
  final double intensity; // 0-1

  const RaceEvent({
    required this.type,
    required this.tick,
    required this.participantIds,
    this.message,
    this.intensity = 0.5,
  });

  factory RaceEvent.fromJson(Map<String, dynamic> json) {
    return RaceEvent(
      type: _parseType(json['type'] as String? ?? 'OVERTAKE'),
      tick: json['tick'] as int? ?? 0,
      participantIds: (json['participantIds'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      message: json['message'] as String?,
      intensity: (json['intensity'] as num?)?.toDouble() ?? 0.5,
    );
  }

  static RaceEventType _parseType(String type) {
    switch (type.toUpperCase()) {
      case 'OVERTAKE':
        return RaceEventType.overtake;
      case 'CLOSE_BATTLE':
        return RaceEventType.closeBattle;
      case 'BOOST':
        return RaceEventType.boost;
      case 'STUMBLE':
        return RaceEventType.stumble;
      case 'LEADER_CHANGE':
        return RaceEventType.leaderChange;
      case 'SPRINT_BURST':
        return RaceEventType.sprintBurst;
      case 'FATIGUE':
        return RaceEventType.fatigue;
      case 'FINISH':
        return RaceEventType.finish;
      case 'PHOTO_FINISH':
        return RaceEventType.photoFinish;
      default:
        return RaceEventType.overtake;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name.toUpperCase(),
      'tick': tick,
      'participantIds': participantIds,
      'message': message,
      'intensity': intensity,
    };
  }

  /// Check if this event involves a specific participant
  bool involvesParticipant(String participantId) {
    return participantIds.contains(participantId);
  }

  /// Check if this is a high-intensity event (> 0.7)
  bool get isHighIntensity => intensity > 0.7;
}
