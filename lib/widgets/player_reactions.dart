import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/theme.dart';

/// Shows player reactions during the race based on their bet's position
class PlayerReactions extends StatefulWidget {
  final List<Player> players;
  final Map<String, Bet> bets;
  final List<Participant> participants;
  final Map<String, double> positions;
  final String? leaderId;

  const PlayerReactions({
    super.key,
    required this.players,
    required this.bets,
    required this.participants,
    required this.positions,
    required this.leaderId,
  });

  @override
  State<PlayerReactions> createState() => _PlayerReactionsState();
}

class _PlayerReactionsState extends State<PlayerReactions>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Participant? _getParticipant(String id) {
    try {
      return widget.participants.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get the rank of a participant (1 = first place)
  int _getParticipantRank(String participantId) {
    final sortedByPosition = widget.positions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    for (var i = 0; i < sortedByPosition.length; i++) {
      if (sortedByPosition[i].key == participantId) {
        return i + 1;
      }
    }
    return widget.participants.length;
  }

  /// Get emotion based on bet's current ranking
  _PlayerEmotion _getEmotion(String? participantId) {
    if (participantId == null) {
      return _PlayerEmotion.neutral;
    }
    
    final rank = _getParticipantRank(participantId);
    final totalParticipants = widget.participants.length;
    
    if (rank == 1) {
      return _PlayerEmotion.ecstatic;
    } else if (rank == 2) {
      return _PlayerEmotion.hopeful;
    } else if (rank <= totalParticipants / 2) {
      return _PlayerEmotion.neutral;
    } else if (rank <= totalParticipants - 1) {
      return _PlayerEmotion.worried;
    } else {
      return _PlayerEmotion.devastated;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter to only players who placed bets
    final playersWithBets = widget.players.where((p) => widget.bets.containsKey(p.id)).toList();
    
    if (playersWithBets.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '📣 CROWD',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Player avatars
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: playersWithBets.map((player) {
                final bet = widget.bets[player.id];
                final participant = bet != null ? _getParticipant(bet.participantId) : null;
                final emotion = _getEmotion(bet?.participantId);
                
                return _PlayerReactionAvatar(
                  player: player,
                  participant: participant,
                  emotion: emotion,
                  animationValue: _animationController.value,
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

enum _PlayerEmotion {
  ecstatic,   // 🤩 Their pick is winning
  hopeful,    // 😊 Their pick is in 2nd
  neutral,    // 😐 Middle of pack
  worried,    // 😰 Not looking good
  devastated, // 😭 Last place
}

class _PlayerReactionAvatar extends StatelessWidget {
  final Player player;
  final Participant? participant;
  final _PlayerEmotion emotion;
  final double animationValue;

  const _PlayerReactionAvatar({
    required this.player,
    required this.participant,
    required this.emotion,
    required this.animationValue,
  });

  String _getEmotionEmoji() {
    switch (emotion) {
      case _PlayerEmotion.ecstatic:
        return '🤩';
      case _PlayerEmotion.hopeful:
        return '😊';
      case _PlayerEmotion.neutral:
        return '😐';
      case _PlayerEmotion.worried:
        return '😰';
      case _PlayerEmotion.devastated:
        return '😭';
    }
  }

  Color _getEmotionColor() {
    switch (emotion) {
      case _PlayerEmotion.ecstatic:
        return AppTheme.neonGreen;
      case _PlayerEmotion.hopeful:
        return AppTheme.neonCyan;
      case _PlayerEmotion.neutral:
        return Colors.grey;
      case _PlayerEmotion.worried:
        return AppTheme.neonOrange;
      case _PlayerEmotion.devastated:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Bounce animation for ecstatic players
    final bounceOffset = emotion == _PlayerEmotion.ecstatic
        ? math.sin(animationValue * math.pi * 4) * 5
        : (emotion == _PlayerEmotion.worried
            ? math.sin(animationValue * math.pi * 6) * 2
            : 0.0);

    return Transform.translate(
      offset: Offset(0, bounceOffset),
      child: Container(
        width: 70,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getEmotionColor().withOpacity(0.5),
            width: 2,
          ),
          boxShadow: emotion == _PlayerEmotion.ecstatic
              ? [
                  BoxShadow(
                    color: _getEmotionColor().withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Player name
            Text(
              player.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            // Emotion emoji
            Text(
              _getEmotionEmoji(),
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 4),
            // Their bet (participant icon)
            if (participant != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    participant!.icon,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
