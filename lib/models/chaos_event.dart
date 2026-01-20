/// Chaos event data for dramatic in-race moments

class ChaosEvent {
  final String type;
  final String message;
  final double intensity; // 0.0 - 1.0
  final int? duration; // seconds
  final List<String>? affectedParticipantIds;

  const ChaosEvent({
    required this.type,
    required this.message,
    required this.intensity,
    this.duration,
    this.affectedParticipantIds,
  });

  factory ChaosEvent.fromJson(Map<String, dynamic> json) {
    return ChaosEvent(
      type: json['type'] as String? ?? 'unknown',
      message: json['message'] as String? ?? '',
      intensity: (json['intensity'] as num?)?.toDouble() ?? 0.5,
      duration: json['duration'] as int?,
      affectedParticipantIds: (json['affectedParticipantIds'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'message': message,
    'intensity': intensity,
    'duration': duration,
    'affectedParticipantIds': affectedParticipantIds,
  };

  /// Is this a high-intensity chaos event?
  bool get isHighIntensity => intensity >= 0.75;

  /// Is this the maximum chaos event?
  bool get isMaxChaos => intensity >= 1.0;
}
