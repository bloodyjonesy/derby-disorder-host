import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../animations/animations.dart';
import '../widgets/personality_indicators.dart';
import 'race_track_painter.dart';

/// Race view widget that displays the animated race track with effects
class RaceView extends StatefulWidget {
  final List<Participant> participants;
  final Map<String, double> positions;
  final String? leaderId;
  final VoidCallback? onRaceComplete;

  const RaceView({
    super.key,
    required this.participants,
    required this.positions,
    this.leaderId,
    this.onRaceComplete,
  });

  @override
  State<RaceView> createState() => _RaceViewState();
}

class _RaceViewState extends State<RaceView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final RaceAnimationManager _animationManager = RaceAnimationManager();
  
  // Track previous state for detecting events
  Map<String, double> _previousPositions = {};
  String? _previousLeader;
  final Set<String> _finishedParticipants = {};
  bool _celebrationTriggered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _animationController.addListener(_updateAnimations);
  }

  void _updateAnimations() {
    _animationManager.update(0.016); // ~60fps
  }

  Size _lastKnownSize = const Size(800, 600);

  @override
  void didUpdateWidget(RaceView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Defer event detection to after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _detectRaceEvents();
      }
    });
    _previousPositions = Map.from(widget.positions);
    _previousLeader = widget.leaderId;
  }

  void _detectRaceEvents() {
    if (widget.participants.isEmpty) return;

    final size = _lastKnownSize;
    final center = Offset(size.width / 2, size.height / 2);
    final trackRadius = math.min(size.width, size.height) * 0.35;

    // Detect leader change
    if (_previousLeader != null && 
        widget.leaderId != null && 
        _previousLeader != widget.leaderId) {
      final newLeader = widget.participants.firstWhere(
        (p) => p.id == widget.leaderId,
        orElse: () => widget.participants.first,
      );
      final leaderPos = _getParticipantScreenPosition(
        widget.leaderId!,
        center,
        trackRadius,
      );
      _animationManager.triggerAnimation(
        RaceAnimationType.leaderChange,
        leaderPos,
        participantIds: [widget.leaderId!],
        message: '${newLeader.name} takes the lead!',
      );
    }

    // Detect overtakes
    _detectOvertakes(center, trackRadius);

    // Detect finishes
    _detectFinishes(center, trackRadius);

    // Detect close battles
    _detectCloseBattles(center, trackRadius);
  }

  void _detectOvertakes(Offset center, double trackRadius) {
    for (var i = 0; i < widget.participants.length; i++) {
      final p1 = widget.participants[i];
      final p1Pos = widget.positions[p1.id] ?? 0;
      final p1PrevPos = _previousPositions[p1.id] ?? 0;

      for (var j = i + 1; j < widget.participants.length; j++) {
        final p2 = widget.participants[j];
        final p2Pos = widget.positions[p2.id] ?? 0;
        final p2PrevPos = _previousPositions[p2.id] ?? 0;

        // Check if p1 overtook p2
        if (p1PrevPos < p2PrevPos && p1Pos > p2Pos) {
          final screenPos = _getParticipantScreenPosition(p1.id, center, trackRadius);
          _animationManager.triggerAnimation(
            RaceAnimationType.overtake,
            screenPos,
            participantIds: [p1.id, p2.id],
          );
        }
        // Check if p2 overtook p1
        else if (p2PrevPos < p1PrevPos && p2Pos > p1Pos) {
          final screenPos = _getParticipantScreenPosition(p2.id, center, trackRadius);
          _animationManager.triggerAnimation(
            RaceAnimationType.overtake,
            screenPos,
            participantIds: [p2.id, p1.id],
          );
        }
      }
    }
  }

  void _detectFinishes(Offset center, double trackRadius) {
    for (final participant in widget.participants) {
      final pos = widget.positions[participant.id] ?? 0;
      final prevPos = _previousPositions[participant.id] ?? 0;

      if (pos >= 100 && prevPos < 100 && !_finishedParticipants.contains(participant.id)) {
        _finishedParticipants.add(participant.id);
        
        final screenPos = _getParticipantScreenPosition(participant.id, center, trackRadius);
        _animationManager.triggerAnimation(
          RaceAnimationType.finish,
          screenPos,
          participantIds: [participant.id],
        );

        // Trigger celebration when first participant finishes
        if (_finishedParticipants.length == 1 && !_celebrationTriggered) {
          _celebrationTriggered = true;
          _animationManager.triggerAnimation(
            RaceAnimationType.celebration,
            center,
            duration: 3.0,
          );
        }
      }
    }
  }

  // Track when we last showed a close battle to avoid spam
  double _lastCloseBattleTime = 0;
  static const double _closeBattleCooldown = 3.0; // Only show every 3 seconds

  void _detectCloseBattles(Offset center, double trackRadius) {
    // Cooldown check - don't spam close battle effects
    if (_animationController.value < _lastCloseBattleTime + _closeBattleCooldown / 10) {
      return;
    }

    // Find the single closest pair of racers (not all pairs)
    String? closestP1;
    String? closestP2;
    double closestDistance = double.infinity;

    for (var i = 0; i < widget.participants.length; i++) {
      final p1 = widget.participants[i];
      final p1Pos = widget.positions[p1.id] ?? 0;
      if (p1Pos >= 100) continue; // Skip finished

      for (var j = i + 1; j < widget.participants.length; j++) {
        final p2 = widget.participants[j];
        final p2Pos = widget.positions[p2.id] ?? 0;
        if (p2Pos >= 100) continue; // Skip finished

        final distance = (p1Pos - p2Pos).abs();
        if (distance < closestDistance && distance < 2 && distance > 0) {
          closestDistance = distance;
          closestP1 = p1.id;
          closestP2 = p2.id;
        }
      }
    }

    // Only trigger for the single closest battle
    if (closestP1 != null && closestP2 != null) {
      _lastCloseBattleTime = _animationController.value;
      final midPos = Offset(
        (_getParticipantScreenPosition(closestP1, center, trackRadius).dx +
            _getParticipantScreenPosition(closestP2, center, trackRadius).dx) / 2,
        (_getParticipantScreenPosition(closestP1, center, trackRadius).dy +
            _getParticipantScreenPosition(closestP2, center, trackRadius).dy) / 2,
      );
      _animationManager.triggerAnimation(
        RaceAnimationType.closeBattle,
        midPos,
        participantIds: [closestP1, closestP2],
        duration: 0.3, // Shorter duration
      );
    }
  }

  Offset _getParticipantScreenPosition(String participantId, Offset center, double trackRadius) {
    final index = widget.participants.indexWhere((p) => p.id == participantId);
    if (index < 0) return center;

    final position = widget.positions[participantId] ?? 0;
    final progress = position / 100.0;
    final angle = -math.pi / 2 + (progress * 2 * math.pi);

    final laneOffset = (index - (widget.participants.length - 1) / 2) * (trackRadius * 0.06);
    final currentRadius = trackRadius + laneOffset;

    return Offset(
      center.dx + currentRadius * math.cos(angle),
      center.dy + currentRadius * math.sin(angle),
    );
  }

  /// Manually trigger a boost animation for a participant
  void triggerBoost(String participantId) {
    final size = _lastKnownSize;
    final center = Offset(size.width / 2, size.height / 2);
    final trackRadius = math.min(size.width, size.height) * 0.35;
    
    final screenPos = _getParticipantScreenPosition(participantId, center, trackRadius);
    _animationManager.triggerAnimation(
      RaceAnimationType.boost,
      screenPos,
      participantIds: [participantId],
    );
  }

  /// Manually trigger a stumble animation for a participant
  void triggerStumble(String participantId) {
    final size = _lastKnownSize;
    final center = Offset(size.width / 2, size.height / 2);
    final trackRadius = math.min(size.width, size.height) * 0.35;
    
    final screenPos = _getParticipantScreenPosition(participantId, center, trackRadius);
    _animationManager.triggerAnimation(
      RaceAnimationType.stumble,
      screenPos,
      participantIds: [participantId],
    );
  }

  @override
  void dispose() {
    _animationController.removeListener(_updateAnimations);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Update known size for event detection
        _lastKnownSize = Size(constraints.maxWidth, constraints.maxHeight);
        
        final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
        final trackRadius = math.min(constraints.maxWidth, constraints.maxHeight) * 0.35;

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Stack(
              children: [
                // Base track and participants
                CustomPaint(
                  painter: RaceTrackPainter(
                    participants: widget.participants,
                    positions: widget.positions,
                    leaderId: widget.leaderId,
                    animationValue: _animationController.value,
                  ),
                  size: Size.infinite,
                ),
                // Animation effects overlay
                CustomPaint(
                  painter: RaceEffectsPainter(
                    animations: _animationManager.activeAnimations,
                    animationValue: _animationController.value,
                  ),
                  size: Size.infinite,
                ),
                // Personality indicators overlay
                PersonalityIndicators(
                  participants: widget.participants,
                  positions: widget.positions,
                  trackSize: _lastKnownSize,
                  trackCenter: center,
                  trackRadius: trackRadius,
                ),
              ],
            );
          },
        );
      },
    );
  }
}
