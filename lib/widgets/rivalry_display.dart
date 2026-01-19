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
      padding: const EdgeInsets.all(14),
      constraints: const BoxConstraints(maxWidth: 300),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚔️', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                'FEATURED BATTLE',
                style: AppTheme.neonText(color: AppTheme.neonYellow, fontSize: 14),
              ),
              const SizedBox(width: 6),
              const Text('⚔️', style: TextStyle(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: _buildPlayerSide(player1, rivalry.winnerId == player1.id, rivalry.loserId == player1.id, rivalry.player1Profit, AppTheme.neonPink)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('VS', style: AppTheme.neonText(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Expanded(child: _buildPlayerSide(player2, rivalry.winnerId == player2.id, rivalry.loserId == player2.id, rivalry.player2Profit, AppTheme.neonCyan)),
            ],
          ),
          if (!showResult) ...[
            const SizedBox(height: 10),
            Text('🍺 Loser drinks! 🍺', style: TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayerSide(Player player, bool isWinner, bool isLoser, int profit, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.2),
            border: Border.all(color: isWinner ? AppTheme.neonGreen : (isLoser ? Colors.red : color), width: 2),
          ),
          child: Center(child: Text(player.name.isNotEmpty ? player.name[0].toUpperCase() : '?', style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold))),
        ),
        const SizedBox(height: 4),
        Text(player.name, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
        if (showResult && (isWinner || isLoser))
          Text(isWinner ? '👑' : '🍺', style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}

class RivalryBanner extends StatelessWidget {
  final String player1Name;
  final String player2Name;

  const RivalryBanner({super.key, required this.player1Name, required this.player2Name});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 180),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.neonPink.withOpacity(0.3), AppTheme.neonCyan.withOpacity(0.3)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.neonYellow.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⚔️', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Flexible(child: Text('$player1Name vs $player2Name', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
