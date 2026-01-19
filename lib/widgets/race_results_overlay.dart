import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/theme.dart';

/// Enhanced race results overlay with animations
class RaceResultsOverlay extends StatefulWidget {
  final RaceResult raceResult;
  final List<Participant> participants;
  final List<Player>? players;
  final Map<String, Bet>? bets;

  const RaceResultsOverlay({
    super.key,
    required this.raceResult,
    required this.participants,
    this.players,
    this.bets,
  });

  @override
  State<RaceResultsOverlay> createState() => _RaceResultsOverlayState();
}

class _RaceResultsOverlayState extends State<RaceResultsOverlay>
    with TickerProviderStateMixin {
  late AnimationController _revealController;
  late AnimationController _podiumController;
  late AnimationController _confettiController;
  
  late Animation<double> _titleAnimation;
  late List<Animation<double>> _podiumAnimations;
  late Animation<double> _playerResultsAnimation;

  @override
  void initState() {
    super.initState();
    
    // Reveal controller for title
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Podium controller for podium entries
    _podiumController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    // Confetti controller
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    
    // Title animation
    _titleAnimation = CurvedAnimation(
      parent: _revealController,
      curve: Curves.elasticOut,
    );
    
    // Staggered podium animations (3rd, 2nd, 1st)
    _podiumAnimations = [
      // 3rd place - appears first
      CurvedAnimation(
        parent: _podiumController,
        curve: const Interval(0.0, 0.33, curve: Curves.bounceOut),
      ),
      // 2nd place
      CurvedAnimation(
        parent: _podiumController,
        curve: const Interval(0.25, 0.58, curve: Curves.bounceOut),
      ),
      // 1st place - appears last for drama
      CurvedAnimation(
        parent: _podiumController,
        curve: const Interval(0.5, 0.83, curve: Curves.elasticOut),
      ),
    ];
    
    // Player results animation
    _playerResultsAnimation = CurvedAnimation(
      parent: _podiumController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    );
    
    // Start animations
    _revealController.forward().then((_) {
      _podiumController.forward();
      _confettiController.repeat();
    });
  }

  @override
  void dispose() {
    _revealController.dispose();
    _podiumController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Participant? _getParticipant(String id) {
    try {
      return widget.participants.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get color for bet type
  Color _getBetTypeColor(BetType betType) {
    switch (betType) {
      case BetType.win:
        return AppTheme.neonYellow;
      case BetType.place:
        return AppTheme.neonCyan;
      case BetType.longshot:
        return AppTheme.neonPink;
    }
  }

  /// Check if a bet won based on bet type and finish order
  bool _didBetWin(Bet bet, List<String> finishOrder) {
    final participantPosition = finishOrder.indexOf(bet.participantId);
    if (participantPosition == -1) return false; // Participant didn't finish
    
    switch (bet.betType) {
      case BetType.win:
        // WIN bet: participant must finish 1st
        return participantPosition == 0;
      case BetType.place:
        // PLACE bet: participant must finish in top 3
        return participantPosition <= 2;
      case BetType.longshot:
        // LONGSHOT bet: participant must finish 1st (higher payout)
        return participantPosition == 0;
    }
  }

  /// Calculate winnings based on bet type
  int _calculateWinnings(Bet bet, bool won) {
    if (!won) return -bet.amount;
    
    switch (bet.betType) {
      case BetType.win:
        return bet.amount * 2; // 2x payout for win
      case BetType.place:
        return (bet.amount * 1.5).round(); // 1.5x payout for place
      case BetType.longshot:
        return bet.amount * 5; // 5x payout for longshot
    }
  }

  @override
  Widget build(BuildContext context) {
    final topThree = widget.raceResult.finishOrder.take(3).toList();
    final finishOrder = widget.raceResult.finishOrder;

    return Stack(
      children: [
        // Confetti background
        AnimatedBuilder(
          animation: _confettiController,
          builder: (context, child) {
            return CustomPaint(
              painter: ConfettiPainter(
                progress: _confettiController.value,
              ),
              size: Size.infinite,
            );
          },
        ),

        // Main content
        Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title with reveal animation
                ScaleTransition(
                  scale: _titleAnimation,
                  child: Column(
                    children: [
                      Text(
                        '🏆 RACE RESULTS 🏆',
                        style: AppTheme.neonText(
                          color: AppTheme.neonYellow,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.neonYellow.withOpacity(0.3),
                              AppTheme.neonYellow.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Round Complete!',
                          style: TextStyle(
                            color: AppTheme.neonYellow.withOpacity(0.9),
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Podium
                SizedBox(
                  height: 300,
                  width: 500,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Podium blocks
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // 2nd place podium
                          _buildPodiumBlock(2, 100, AppTheme.neonCyan),
                          const SizedBox(width: 8),
                          // 1st place podium
                          _buildPodiumBlock(1, 140, AppTheme.neonYellow),
                          const SizedBox(width: 8),
                          // 3rd place podium
                          _buildPodiumBlock(3, 70, AppTheme.neonOrange),
                        ],
                      ),
                      
                      // Participants on podium
                      if (topThree.length >= 2)
                        Positioned(
                          left: 70,
                          bottom: 100,
                          child: _buildPodiumParticipant(
                            topThree[1],
                            1,
                            '🥈',
                          ),
                        ),
                      if (topThree.isNotEmpty)
                        Positioned(
                          left: 200,
                          bottom: 140,
                          child: _buildPodiumParticipant(
                            topThree[0],
                            2,
                            '🥇',
                          ),
                        ),
                      if (topThree.length >= 3)
                        Positioned(
                          right: 70,
                          bottom: 70,
                          child: _buildPodiumParticipant(
                            topThree[2],
                            0,
                            '🥉',
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Player bet results
                if (widget.players != null && widget.bets != null)
                  FadeTransition(
                    opacity: _playerResultsAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(_playerResultsAnimation),
                      child: _buildPlayerResults(finishOrder),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPodiumBlock(int place, double height, Color color) {
    return AnimatedBuilder(
      animation: _podiumController,
      builder: (context, child) {
        final animIndex = place == 1 ? 2 : (place == 2 ? 1 : 0);
        final scale = _podiumAnimations[animIndex].value;
        
        return Transform.scale(
          scale: scale,
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 100,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withOpacity(0.8),
                  color.withOpacity(0.4),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$place',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: color,
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPodiumParticipant(String participantId, int animIndex, String medal) {
    final participant = _getParticipant(participantId);
    if (participant == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _podiumController,
      builder: (context, child) {
        final animation = _podiumAnimations[animIndex];
        final scale = animation.value;
        final bounce = math.sin(animation.value * math.pi * 2) * 5;
        
        return Transform.translate(
          offset: Offset(0, -scale * 30 + (animIndex == 2 ? bounce : 0)),
          child: Transform.scale(
            scale: scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Medal
                Text(
                  medal,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 4),
                // Participant icon with glow
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: animIndex == 2
                        ? [
                            BoxShadow(
                              color: AppTheme.neonYellow.withOpacity(0.8),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    participant.icon,
                    style: TextStyle(
                      fontSize: animIndex == 2 ? 56 : 44,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Name
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    participant.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayerResults(List<String> finishOrder) {
    final players = widget.players ?? [];
    final bets = widget.bets ?? {};
    
    if (players.isEmpty) return const SizedBox.shrink();

    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.neonBox(
        color: AppTheme.neonCyan,
        borderRadius: 16,
      ),
      child: Column(
        children: [
          Text(
            '💰 BET RESULTS 💰',
            style: AppTheme.neonText(
              color: AppTheme.neonCyan,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: players.map((player) {
              final bet = bets[player.id];
              final won = bet != null && _didBetWin(bet, finishOrder);
              final winnings = bet != null ? _calculateWinnings(bet, won) : 0;
              
              return _buildPlayerResultCard(player, bet, won, winnings);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerResultCard(Player player, Bet? bet, bool won, int winnings) {
    final participant = bet != null ? _getParticipant(bet.participantId) : null;
    
    return Container(
      width: 170,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: bet == null
              ? Colors.grey.withOpacity(0.3)
              : (won ? AppTheme.neonGreen : Colors.red).withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Player name
          Text(
            player.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          
          if (bet == null) ...[
            Text(
              'No bet',
              style: TextStyle(
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
            ),
          ] else ...[
            // Bet type badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getBetTypeColor(bet.betType).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _getBetTypeColor(bet.betType).withOpacity(0.5),
                ),
              ),
              child: Text(
                bet.betType.value,
                style: TextStyle(
                  color: _getBetTypeColor(bet.betType),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Bet info
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  participant?.icon ?? '❓',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 6),
                Text(
                  '\$${bet.amount}',
                  style: const TextStyle(
                    color: AppTheme.neonYellow,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Result
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (won ? AppTheme.neonGreen : Colors.red).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    won ? '🎉' : '😢',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    won ? '+\$${winnings.abs()}' : '-\$${winnings.abs()}',
                    style: TextStyle(
                      color: won ? AppTheme.neonGreen : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          // New balance
          Text(
            'Balance: \$${player.balance}',
            style: TextStyle(
              color: player.balance > 0 ? AppTheme.neonGreen : Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Confetti painter for celebration effect
class ConfettiPainter extends CustomPainter {
  final double progress;
  final math.Random _random = math.Random(42); // Fixed seed for consistency

  ConfettiPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      Colors.pink,
      Colors.cyan,
      Colors.yellow,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];

    for (var i = 0; i < 80; i++) {
      final startX = _random.nextDouble() * size.width;
      final speed = 0.5 + _random.nextDouble() * 0.5;
      
      final particleProgress = ((progress * speed + i * 0.01) % 1.0);
      
      final x = startX + math.sin(particleProgress * math.pi * 4 + i) * 50;
      final y = -50 + (size.height + 100) * particleProgress;
      
      final rotation = particleProgress * math.pi * 6 + i;
      final opacity = particleProgress < 0.8 ? 0.8 : (1 - particleProgress) * 4;
      
      final confettiPaint = Paint()
        ..color = colors[i % colors.length].withOpacity(opacity.clamp(0.0, 1.0));

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      
      // Draw rectangle confetti
      canvas.drawRect(
        const Rect.fromLTWH(-8, -4, 16, 8),
        confettiPaint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => 
      oldDelegate.progress != progress;
}
