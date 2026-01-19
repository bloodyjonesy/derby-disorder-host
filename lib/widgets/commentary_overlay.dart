import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/theme.dart';

/// Types of commentary events
enum CommentaryType {
  raceStart,
  leadChange,
  overtake,
  closeBattle,
  breakaway,
  stumble,
  boost,
  halfwayPoint,
  finalStretch,
  photoFinish,
  winner,
  runnerUp,
}

/// A single commentary message
class CommentaryMessage {
  final String text;
  final CommentaryType type;
  final DateTime timestamp;
  final double priority; // 0-1, higher = more important

  CommentaryMessage({
    required this.text,
    required this.type,
    this.priority = 0.5,
  }) : timestamp = DateTime.now();
}

/// Generates contextual race commentary
class CommentaryGenerator {
  final List<Participant> participants;
  final math.Random _random = math.Random();
  
  String? _lastLeaderId;
  final Set<String> _announcedOvertakes = {};
  bool _announcedHalfway = false;
  bool _announcedFinalStretch = false;
  final Set<String> _announcedFinishers = {};
  double _lastMaxPosition = 0;

  CommentaryGenerator({required this.participants});

  /// Get participant name by ID
  String _getName(String id) {
    final participant = participants.cast<Participant?>().firstWhere(
      (p) => p?.id == id,
      orElse: () => null,
    );
    return participant?.name ?? 'Unknown';
  }

  /// Get participant icon by ID
  String _getIcon(String id) {
    final participant = participants.cast<Participant?>().firstWhere(
      (p) => p?.id == id,
      orElse: () => null,
    );
    return participant?.icon ?? '❓';
  }

  /// Generate commentary based on current race state
  List<CommentaryMessage> generateCommentary({
    required Map<String, double> positions,
    required String? leaderId,
    bool raceJustStarted = false,
    bool raceFinished = false,
  }) {
    final messages = <CommentaryMessage>[];

    // Race start
    if (raceJustStarted) {
      messages.add(CommentaryMessage(
        text: _pickRandom([
          "And they're OFF! 🏁",
          "The race has BEGUN! 🚀",
          "Here we GO! 💨",
          "They're racing! Let the chaos begin! 🎪",
        ]),
        type: CommentaryType.raceStart,
        priority: 1.0,
      ));
      _lastLeaderId = leaderId;
      return messages;
    }

    // Get current max position for progress tracking
    final maxPosition = positions.values.fold(0.0, math.max);

    // Lead change
    if (leaderId != null && leaderId != _lastLeaderId && _lastLeaderId != null) {
      final name = _getName(leaderId);
      final icon = _getIcon(leaderId);
      messages.add(CommentaryMessage(
        text: _pickRandom([
          "$icon $name takes the LEAD!",
          "$icon $name surges to the front!",
          "It's $name $icon out in front now!",
          "$icon NEW LEADER: $name!",
          "$name $icon storms into first place!",
        ]),
        type: CommentaryType.leadChange,
        priority: 0.9,
      ));
      _lastLeaderId = leaderId;
    }

    // Check for close battles (2 or more within 3 positions of each other near the front)
    final sortedPositions = positions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    if (sortedPositions.length >= 2) {
      final top2Gap = sortedPositions[0].value - sortedPositions[1].value;
      if (top2Gap < 2 && top2Gap > 0 && maxPosition > 30 && maxPosition < 95) {
        final p1 = _getName(sortedPositions[0].key);
        final p2 = _getName(sortedPositions[1].key);
        final key = '${sortedPositions[0].key}-${sortedPositions[1].key}-${(maxPosition / 10).floor()}';
        
        if (!_announcedOvertakes.contains(key)) {
          messages.add(CommentaryMessage(
            text: _pickRandom([
              "Neck and neck between $p1 and $p2!",
              "$p1 and $p2 are battling it out!",
              "What a fight between $p1 and $p2!",
              "They're side by side! $p1 vs $p2!",
            ]),
            type: CommentaryType.closeBattle,
            priority: 0.7,
          ));
          _announcedOvertakes.add(key);
        }
      }
    }

    // Check for breakaway (leader 10+ ahead of second place)
    if (sortedPositions.length >= 2) {
      final gap = sortedPositions[0].value - sortedPositions[1].value;
      if (gap > 10 && maxPosition > 20 && maxPosition < 80) {
        final leader = _getName(sortedPositions[0].key);
        final key = 'breakaway-${(maxPosition / 20).floor()}';
        
        if (!_announcedOvertakes.contains(key)) {
          messages.add(CommentaryMessage(
            text: _pickRandom([
              "$leader is pulling away from the pack!",
              "Huge lead for $leader!",
              "$leader is leaving everyone in the dust!",
              "Can anyone catch $leader?!",
            ]),
            type: CommentaryType.breakaway,
            priority: 0.6,
          ));
          _announcedOvertakes.add(key);
        }
      }
    }

    // Halfway point
    if (!_announcedHalfway && maxPosition >= 50 && _lastMaxPosition < 50) {
      messages.add(CommentaryMessage(
        text: _pickRandom([
          "We're at the HALFWAY mark! 🏃",
          "Halfway there! Who's got the stamina?",
          "50% complete - anything can happen!",
        ]),
        type: CommentaryType.halfwayPoint,
        priority: 0.5,
      ));
      _announcedHalfway = true;
    }

    // Final stretch
    if (!_announcedFinalStretch && maxPosition >= 80 && _lastMaxPosition < 80) {
      final leader = leaderId != null ? _getName(leaderId) : 'The leader';
      messages.add(CommentaryMessage(
        text: _pickRandom([
          "Into the FINAL STRETCH! 🔥",
          "The finish line is in sight!",
          "$leader can smell victory!",
          "Here comes the finale!",
        ]),
        type: CommentaryType.finalStretch,
        priority: 0.8,
      ));
      _announcedFinalStretch = true;
    }

    // Finishers
    for (final entry in positions.entries) {
      if (entry.value >= 100 && !_announcedFinishers.contains(entry.key)) {
        final name = _getName(entry.key);
        final icon = _getIcon(entry.key);
        final place = _announcedFinishers.length + 1;
        
        if (place == 1) {
          messages.add(CommentaryMessage(
            text: _pickRandom([
              "🏆 $icon $name WINS THE RACE! 🏆",
              "🥇 VICTORY for $name! $icon",
              "🎉 $name $icon crosses first! CHAMPION!",
            ]),
            type: CommentaryType.winner,
            priority: 1.0,
          ));
        } else if (place == 2) {
          messages.add(CommentaryMessage(
            text: "$icon $name takes second! 🥈",
            type: CommentaryType.runnerUp,
            priority: 0.7,
          ));
        } else if (place == 3) {
          messages.add(CommentaryMessage(
            text: "$icon $name finishes third! 🥉",
            type: CommentaryType.runnerUp,
            priority: 0.6,
          ));
        }
        
        _announcedFinishers.add(entry.key);
      }
    }

    // Photo finish detection
    if (raceFinished && _announcedFinishers.length >= 2) {
      final finishedList = _announcedFinishers.toList();
      if (finishedList.length >= 2) {
        final firstPos = positions[finishedList[0]] ?? 100;
        final secondPos = positions[finishedList[1]] ?? 100;
        if ((firstPos - secondPos).abs() < 2) {
          messages.add(CommentaryMessage(
            text: "PHOTO FINISH! 📸 That was CLOSE!",
            type: CommentaryType.photoFinish,
            priority: 0.9,
          ));
        }
      }
    }

    _lastMaxPosition = maxPosition;
    return messages;
  }

  String _pickRandom(List<String> options) {
    return options[_random.nextInt(options.length)];
  }

  void reset() {
    _lastLeaderId = null;
    _announcedOvertakes.clear();
    _announcedHalfway = false;
    _announcedFinalStretch = false;
    _announcedFinishers.clear();
    _lastMaxPosition = 0;
  }
}

/// Widget that displays live commentary during races
class CommentaryOverlay extends StatefulWidget {
  final List<Participant> participants;
  final Map<String, double> positions;
  final String? leaderId;
  final bool isRacing;

  const CommentaryOverlay({
    super.key,
    required this.participants,
    required this.positions,
    required this.leaderId,
    required this.isRacing,
  });

  @override
  State<CommentaryOverlay> createState() => _CommentaryOverlayState();
}

class _CommentaryOverlayState extends State<CommentaryOverlay>
    with SingleTickerProviderStateMixin {
  late CommentaryGenerator _generator;
  final List<CommentaryMessage> _activeMessages = [];
  Timer? _updateTimer;
  bool _wasRacing = false;

  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _generator = CommentaryGenerator(participants: widget.participants);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    // Check for commentary every 500ms
    _updateTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _checkForCommentary();
    });
  }

  @override
  void didUpdateWidget(CommentaryOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Reset when race restarts
    if (widget.isRacing && !_wasRacing) {
      _generator.reset();
      _activeMessages.clear();
      // Generate race start message
      final startMessages = _generator.generateCommentary(
        positions: widget.positions,
        leaderId: widget.leaderId,
        raceJustStarted: true,
      );
      _addMessages(startMessages);
    }
    
    _wasRacing = widget.isRacing;
  }

  void _checkForCommentary() {
    if (!widget.isRacing) return;
    
    final messages = _generator.generateCommentary(
      positions: widget.positions,
      leaderId: widget.leaderId,
    );
    
    _addMessages(messages);
  }

  void _addMessages(List<CommentaryMessage> messages) {
    if (messages.isEmpty) return;
    
    setState(() {
      for (final msg in messages) {
        _activeMessages.add(msg);
        // Auto-remove after display time (based on priority)
        final displayDuration = Duration(
          milliseconds: (2500 + msg.priority * 1500).toInt(),
        );
        Future.delayed(displayDuration, () {
          if (mounted) {
            setState(() {
              _activeMessages.remove(msg);
            });
          }
        });
      }
      
      // Keep only last 3 messages
      while (_activeMessages.length > 3) {
        _activeMessages.removeAt(0);
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_activeMessages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 120,
      left: 0,
      right: 0,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _activeMessages.map((msg) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, (1 - value) * -20),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getTypeColor(msg.type).withOpacity(0.9),
                      _getTypeColor(msg.type).withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: _getTypeColor(msg.type).withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Text(
                  msg.text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _getFontSize(msg.type),
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 4,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getTypeColor(CommentaryType type) {
    switch (type) {
      case CommentaryType.raceStart:
        return AppTheme.neonGreen;
      case CommentaryType.winner:
        return AppTheme.neonYellow;
      case CommentaryType.leadChange:
        return AppTheme.neonCyan;
      case CommentaryType.closeBattle:
        return AppTheme.neonPink;
      case CommentaryType.breakaway:
        return AppTheme.neonPink;
      case CommentaryType.photoFinish:
        return AppTheme.neonYellow;
      case CommentaryType.halfwayPoint:
      case CommentaryType.finalStretch:
        return Colors.orange;
      case CommentaryType.runnerUp:
        return Colors.blueGrey;
      default:
        return AppTheme.neonCyan;
    }
  }

  double _getFontSize(CommentaryType type) {
    switch (type) {
      case CommentaryType.winner:
        return 28;
      case CommentaryType.raceStart:
      case CommentaryType.leadChange:
      case CommentaryType.photoFinish:
        return 24;
      case CommentaryType.finalStretch:
        return 22;
      default:
        return 20;
    }
  }
}
