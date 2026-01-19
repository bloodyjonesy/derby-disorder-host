import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/theme.dart';

/// Displays the current game phase and timer
class PhaseIndicator extends StatelessWidget {
  final GameState gameState;
  final int? timer;

  const PhaseIndicator({
    super.key,
    required this.gameState,
    this.timer,
  });

  String _getPhaseName() {
    switch (gameState) {
      case GameState.lobby:
        return 'LOBBY';
      case GameState.paddock:
        return 'PADDOCK';
      case GameState.wager:
        return 'BETTING';
      case GameState.sabotage:
        return 'SABOTAGE';
      case GameState.racing:
        return 'RACING';
      case GameState.results:
        return 'RESULTS';
    }
  }

  Color _getPhaseColor() {
    switch (gameState) {
      case GameState.lobby:
        return AppTheme.neonCyan;
      case GameState.paddock:
        return AppTheme.neonGreen;
      case GameState.wager:
        return AppTheme.neonYellow;
      case GameState.sabotage:
        return AppTheme.neonOrange;
      case GameState.racing:
        return AppTheme.neonPink;
      case GameState.results:
        return AppTheme.neonCyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getPhaseColor();

    return Container(
      constraints: const BoxConstraints(maxWidth: 140), // Prevent overflow
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: AppTheme.neonBox(
        color: color,
        borderRadius: 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getPhaseName(),
            style: AppTheme.neonText(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          if (timer != null) ...[
            const SizedBox(height: 2),
            Text(
              '${timer}s',
              style: AppTheme.neonText(
                color: AppTheme.neonYellow,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
