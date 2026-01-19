import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/theme.dart';

/// Shows personality indicators for participants during the race
/// These are small pop-up effects that show each racer's quirks
class PersonalityIndicators extends StatefulWidget {
  final List<Participant> participants;
  final Map<String, double> positions;
  final Size trackSize;
  final Offset trackCenter;
  final double trackRadius;

  const PersonalityIndicators({
    super.key,
    required this.participants,
    required this.positions,
    required this.trackSize,
    required this.trackCenter,
    required this.trackRadius,
  });

  @override
  State<PersonalityIndicators> createState() => _PersonalityIndicatorsState();
}

class _PersonalityIndicatorsState extends State<PersonalityIndicators>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final math.Random _random = math.Random();
  
  // Active personality effects
  final List<_PersonalityEffect> _activeEffects = [];
  double _lastTriggerTime = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
    
    _controller.addListener(_checkForEffects);
  }

  @override
  void dispose() {
    _controller.removeListener(_checkForEffects);
    _controller.dispose();
    super.dispose();
  }

  void _checkForEffects() {
    // Only check periodically
    if (_controller.value - _lastTriggerTime < 0.02) return;
    _lastTriggerTime = _controller.value;
    
    // Remove expired effects
    _activeEffects.removeWhere((e) => e.isExpired);
    
    // Randomly trigger effects based on participant stats
    for (final participant in widget.participants) {
      final position = widget.positions[participant.id] ?? 0;
      if (position >= 100) continue; // Skip finished
      
      // Random chance to show a personality effect
      if (_random.nextDouble() < 0.05) { // 5% chance per check
        final effect = _getRandomEffect(participant);
        if (effect != null && _activeEffects.length < 5) {
          _activeEffects.add(effect);
        }
      }
    }
    
    setState(() {});
  }

  _PersonalityEffect? _getRandomEffect(Participant participant) {
    final effects = <_PersonalityEffect>[];
    final screenPos = _getScreenPosition(participant.id);
    
    // High derp = confusion/chaos moments
    if (participant.derp >= 8) {
      effects.add(_PersonalityEffect(
        participantId: participant.id,
        icon: ['🌀', '❓', '💫', '🤪'][_random.nextInt(4)],
        label: 'Confused!',
        color: AppTheme.neonPink,
        position: screenPos,
        expiresAt: DateTime.now().add(const Duration(milliseconds: 1500)),
      ));
    }
    
    // High zoomies = speed burst
    if (participant.zoomies >= 9) {
      effects.add(_PersonalityEffect(
        participantId: participant.id,
        icon: ['💨', '⚡', '🔥', '✨'][_random.nextInt(4)],
        label: 'Speed burst!',
        color: AppTheme.neonYellow,
        position: screenPos,
        expiresAt: DateTime.now().add(const Duration(milliseconds: 1200)),
      ));
    }
    
    // Low zoomies = slow/tired
    if (participant.zoomies <= 3) {
      effects.add(_PersonalityEffect(
        participantId: participant.id,
        icon: ['😴', '💤', '🐢'][_random.nextInt(3)],
        label: 'So tired...',
        color: Colors.grey,
        position: screenPos,
        expiresAt: DateTime.now().add(const Duration(milliseconds: 2000)),
      ));
    }
    
    // High chonk = stamina/determination
    if (participant.chonk >= 8) {
      effects.add(_PersonalityEffect(
        participantId: participant.id,
        icon: ['💪', '🏋️', '😤'][_random.nextInt(3)],
        label: 'Power!',
        color: AppTheme.neonGreen,
        position: screenPos,
        expiresAt: DateTime.now().add(const Duration(milliseconds: 1000)),
      ));
    }
    
    // Special per-character effects based on name
    if (participant.name.contains('Caffeine') || participant.name.contains('Caffeinated')) {
      effects.add(_PersonalityEffect(
        participantId: participant.id,
        icon: '☕',
        label: 'CAFFEINE RUSH!',
        color: AppTheme.neonOrange,
        position: screenPos,
        expiresAt: DateTime.now().add(const Duration(milliseconds: 1500)),
      ));
    }
    
    if (participant.name.contains('Snail')) {
      effects.add(_PersonalityEffect(
        participantId: participant.id,
        icon: '🧘',
        label: 'Inner peace...',
        color: Colors.lightGreen,
        position: screenPos,
        expiresAt: DateTime.now().add(const Duration(milliseconds: 2500)),
      ));
    }
    
    if (participant.name.contains('Chaos') || participant.name.contains('Gremlin')) {
      effects.add(_PersonalityEffect(
        participantId: participant.id,
        icon: ['😈', '👹', '🎭'][_random.nextInt(3)],
        label: 'CHAOS!',
        color: Colors.purple,
        position: screenPos,
        expiresAt: DateTime.now().add(const Duration(milliseconds: 1200)),
      ));
    }
    
    if (participant.name.contains('Dramatic') || participant.name.contains('Llama')) {
      effects.add(_PersonalityEffect(
        participantId: participant.id,
        icon: '🎭',
        label: 'SO DRAMATIC!',
        color: Colors.pink,
        position: screenPos,
        expiresAt: DateTime.now().add(const Duration(milliseconds: 1800)),
      ));
    }
    
    if (participant.name.contains('Angry') || participant.name.contains('Goose')) {
      effects.add(_PersonalityEffect(
        participantId: participant.id,
        icon: ['😠', '💢', '🔥'][_random.nextInt(3)],
        label: 'HONK!',
        color: Colors.red,
        position: screenPos,
        expiresAt: DateTime.now().add(const Duration(milliseconds: 1000)),
      ));
    }
    
    if (participant.name.contains('Panicked') || participant.name.contains('Chicken')) {
      effects.add(_PersonalityEffect(
        participantId: participant.id,
        icon: ['😱', '🙀', '❗'][_random.nextInt(3)],
        label: 'PANIC!',
        color: AppTheme.neonOrange,
        position: screenPos,
        expiresAt: DateTime.now().add(const Duration(milliseconds: 1200)),
      ));
    }
    
    if (participant.name.contains('Existential')) {
      effects.add(_PersonalityEffect(
        participantId: participant.id,
        icon: '💭',
        label: 'Why am I here?',
        color: Colors.blueGrey,
        position: screenPos,
        expiresAt: DateTime.now().add(const Duration(milliseconds: 2500)),
      ));
    }
    
    if (participant.name.contains('Jetpack')) {
      effects.add(_PersonalityEffect(
        participantId: participant.id,
        icon: '🚀',
        label: 'IGNITION!',
        color: AppTheme.neonCyan,
        position: screenPos,
        expiresAt: DateTime.now().add(const Duration(milliseconds: 1200)),
      ));
    }
    
    if (effects.isEmpty) return null;
    return effects[_random.nextInt(effects.length)];
  }

  Offset _getScreenPosition(String participantId) {
    final position = widget.positions[participantId] ?? 0;
    final progress = position / 100.0;
    final angle = -math.pi / 2 + (progress * 2 * math.pi);
    
    final participantIndex = widget.participants.indexWhere((p) => p.id == participantId);
    final laneOffset = (participantIndex - (widget.participants.length - 1) / 2) * 
        (widget.trackRadius * 0.06);
    final currentRadius = widget.trackRadius + laneOffset;
    
    return Offset(
      widget.trackCenter.dx + currentRadius * math.cos(angle),
      widget.trackCenter.dy + currentRadius * math.sin(angle),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _activeEffects.map((effect) {
        final age = DateTime.now().difference(
          effect.expiresAt.subtract(const Duration(milliseconds: 1500)),
        ).inMilliseconds / 1500.0;
        
        final opacity = age < 0.2 
            ? (age / 0.2) 
            : (age > 0.8 ? (1 - age) / 0.2 : 1.0);
        final scale = age < 0.2 ? 0.5 + (age / 0.2) * 0.5 : 1.0;
        final yOffset = -20 - (age * 30);
        
        return Positioned(
          left: effect.position.dx - 40,
          top: effect.position.dy + yOffset - 60,
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: scale,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: effect.color.withOpacity(0.7),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: effect.color.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      effect.icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                    Text(
                      effect.label,
                      style: TextStyle(
                        color: effect.color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PersonalityEffect {
  final String participantId;
  final String icon;
  final String label;
  final Color color;
  final Offset position;
  final DateTime expiresAt;

  _PersonalityEffect({
    required this.participantId,
    required this.icon,
    required this.label,
    required this.color,
    required this.position,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
