/// Participant type classification
enum ParticipantType {
  pro('pro'),
  object('object'),
  creature('creature');

  final String value;
  const ParticipantType(this.value);

  static ParticipantType fromString(String value) {
    return ParticipantType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ParticipantType.creature,
    );
  }
}

/// Represents a race participant (racer)
class Participant {
  final String id;
  final String name;
  final ParticipantType type;
  final int zoomies; // Top Speed (1-10)
  final int chonk; // Stamina (1-10)
  final int derp; // Randomness/Luck (1-10)
  final String color; // Hex color
  final List<int> history; // Last 3 finishes
  final String icon; // Emoji icon for display

  const Participant({
    required this.id,
    required this.name,
    required this.type,
    required this.zoomies,
    required this.chonk,
    required this.derp,
    required this.color,
    required this.history,
    required this.icon,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'] as String,
      name: json['name'] as String,
      type: ParticipantType.fromString(json['type'] as String),
      zoomies: json['zoomies'] as int,
      chonk: json['chonk'] as int,
      derp: json['derp'] as int,
      color: json['color'] as String,
      history: (json['history'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      icon: json['icon'] as String? ?? '🏃',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.value,
      'zoomies': zoomies,
      'chonk': chonk,
      'derp': derp,
      'color': color,
      'history': history,
      'icon': icon,
    };
  }
}
