import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/theme.dart';

/// Displays the current rivalry/featured battle between two players
class RivalryDisplay extends StatelessWidget {
  final Rivalry rivalry;
  final Player player1;
  final Player player2;
  final bool showResult;

  const RivalryDisplay({
    super.key,
    required this.rivalry,
    required this.player1,
    required this.player2,
    this.showResult = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.neonPink.withOpacity(0.2),
            Colors.black.withOpacity(0.5),
            AppTheme.neonCyan.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.neonYellow.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('⚔️', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                'FEATURED BATTLE',
                style: AppTheme.neonText(
                  color: AppTheme.neonYellow,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Text('⚔️', style: TextStyle(fontSize: 24)),
            ],
          ),
          const SizedBox(height: 16),
          
          // Players
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPlayerSide(
                player: player1,
                isWinner: showResult && rivalry.winnerId == player1.id,
                isLoser: showResult && rivalry.loserId == player1.id,
                profit: rivalry.player1Profit,
                color: AppTheme.neonPink,
              ),
              
              // VS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text(
                      'VS',
                      style: AppTheme.neonText(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (showResult) ...[
                      const SizedBox(height: 8),
                      Text(
                        'LOSER DRINKS!',
                        style: TextStyle(
                          color: AppTheme.neonPink,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              _buildPlayerSide(
                player: player2,
                isWinner: showResult && rivalry.winnerId == player2.id,
                isLoser: showResult && rivalry.loserId == player2.id,
                profit: rivalry.player2Profit,
                color: AppTheme.neonCyan,
              ),
            ],
          ),
          
          // Stakes
          if (!showResult) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '🍺 Whoever profits less this race DRINKS! 🍺',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayerSide({
    required Player player,
    required bool isWinner,
    required bool isLoser,
    required int profit,
    required Color color,
  }) {
    return Column(
      children: [
        // Winner/Loser badge
        if (isWinner)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.neonGreen.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '👑 WINNER',
              style: TextStyle(
                color: AppTheme.neonGreen,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else if (isLoser)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '🍺 DRINKS!',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else
          const SizedBox(height: 24),
        
        const SizedBox(height: 8),
        
        // Player avatar/icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.2),
            border: Border.all(
              color: isWinner ? AppTheme.neonGreen : (isLoser ? Colors.red : color),
              width: 3,
            ),
            boxShadow: isWinner
                ? [
                    BoxShadow(
                      color: AppTheme.neonGreen.withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
              style: TextStyle(
                color: color,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Player name
        Text(
          player.name,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        // Profit (if showing results)
        if (profit != 0) ...[
          const SizedBox(height: 4),
          Text(
            '${profit >= 0 ? '+' : ''}\$${profit}',
            style: TextStyle(
              color: profit >= 0 ? AppTheme.neonGreen : Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}

/// Compact rivalry banner for display during phases
class RivalryBanner extends StatelessWidget {
  final String player1Name;
  final String player2Name;

  const RivalryBanner({
    super.key,
    required this.player1Name,
    required this.player2Name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.neonPink.withOpacity(0.3),
            AppTheme.neonYellow.withOpacity(0.3),
            AppTheme.neonCyan.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.neonYellow.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⚔️', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            '$player1Name vs $player2Name',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          const Text('⚔️', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
