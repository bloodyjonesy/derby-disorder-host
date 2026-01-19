import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// A single floating cheer emoji
class _CheerEmoji {
  final String emoji;
  final Offset startPosition;
  final double endY;
  final double horizontalDrift;
  final double rotation;
  final double scale;
  final int id;

  _CheerEmoji({
    required this.emoji,
    required this.startPosition,
    required this.endY,
    required this.horizontalDrift,
    required this.rotation,
    required this.scale,
    required this.id,
  });
}

/// Displays floating cheer emojis when players cheer
class CheerAnimation extends StatefulWidget {
  final Stream<String> cheerStream; // Stream of playerIds who cheered
  final List<String> playerIds; // To determine which side of screen
  
  const CheerAnimation({
    super.key,
    required this.cheerStream,
    required this.playerIds,
  });

  @override
  State<CheerAnimation> createState() => _CheerAnimationState();
}

class _CheerAnimationState extends State<CheerAnimation>
    with SingleTickerProviderStateMixin {
  final List<_CheerEmoji> _activeEmojis = [];
  final math.Random _random = math.Random();
  int _emojiIdCounter = 0;
  StreamSubscription<String>? _subscription;
  late AnimationController _controller;

  static const List<String> cheerEmojis = ['🎉', '🎊', '🥳', '✨', '⭐', '🔥', '💯', '👏'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _subscription = widget.cheerStream.listen(_onCheer);
  }

  void _onCheer(String playerId) {
    // Find player index to determine spawn position
    final playerIndex = widget.playerIds.indexOf(playerId);
    final baseX = 100.0 + (playerIndex * 10); // Spawn from left side (player leaderboard area)
    
    // Create 2-3 emojis per cheer
    final emojiCount = 2 + _random.nextInt(2);
    for (var i = 0; i < emojiCount; i++) {
      final emoji = _CheerEmoji(
        emoji: cheerEmojis[_random.nextInt(cheerEmojis.length)],
        startPosition: Offset(
          baseX + _random.nextDouble() * 100,
          200 + _random.nextDouble() * 300,
        ),
        endY: -100,
        horizontalDrift: (_random.nextDouble() - 0.5) * 200,
        rotation: _random.nextDouble() * math.pi * 2,
        scale: 0.8 + _random.nextDouble() * 0.6,
        id: _emojiIdCounter++,
      );
      
      setState(() {
        _activeEmojis.add(emoji);
      });

      // Remove after animation completes
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _activeEmojis.removeWhere((e) => e.id == emoji.id);
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: _activeEmojis.map((emoji) {
              // Calculate progress based on when this emoji was added
              final lifeProgress = (_controller.value * 1.5) % 1.0;
              
              return Positioned(
                left: emoji.startPosition.dx + (emoji.horizontalDrift * lifeProgress),
                top: emoji.startPosition.dy + ((emoji.endY - emoji.startPosition.dy) * lifeProgress),
                child: Opacity(
                  opacity: (1.0 - lifeProgress).clamp(0.0, 1.0),
                  child: Transform.rotate(
                    angle: emoji.rotation + (lifeProgress * math.pi),
                    child: Transform.scale(
                      scale: emoji.scale * (1.0 + lifeProgress * 0.5),
                      child: Text(
                        emoji.emoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
