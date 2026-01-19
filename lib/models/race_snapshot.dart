import 'race_event.dart';

/// Represents a snapshot of the race at a point in time
class RaceSnapshot {
  final int tick;
  final Map<String, double> positions; // participantId -> position (0-100)
  final String leader; // participantId of the current leader
  final List<RaceEvent> events; // Events that occurred this tick

  const RaceSnapshot({
    required this.tick,
    required this.positions,
    required this.leader,
    this.events = const [],
  });

  factory RaceSnapshot.fromJson(Map<String, dynamic> json) {
    final positionsMap = <String, double>{};
    final positionsJson = json['positions'] as Map<String, dynamic>?;
    if (positionsJson != null) {
      for (final entry in positionsJson.entries) {
        positionsMap[entry.key] = (entry.value as num).toDouble();
      }
    }

    final eventsList = <RaceEvent>[];
    final eventsJson = json['events'] as List<dynamic>?;
    if (eventsJson != null) {
      for (final eventJson in eventsJson) {
        eventsList.add(RaceEvent.fromJson(eventJson as Map<String, dynamic>));
      }
    }

    return RaceSnapshot(
      tick: json['tick'] as int,
      positions: positionsMap,
      leader: json['leader'] as String? ?? '',
      events: eventsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tick': tick,
      'positions': positions,
      'leader': leader,
      'events': events.map((e) => e.toJson()).toList(),
    };
  }

  /// Get position for a participant, defaulting to 0
  double getPosition(String participantId) {
    return positions[participantId] ?? 0.0;
  }

  /// Check if there are any events this tick
  bool get hasEvents => events.isNotEmpty;

  /// Get events for a specific participant
  List<RaceEvent> getEventsForParticipant(String participantId) {
    return events.where((e) => e.involvesParticipant(participantId)).toList();
  }

  /// Get high-intensity events
  List<RaceEvent> get highIntensityEvents =>
      events.where((e) => e.isHighIntensity).toList();
}
