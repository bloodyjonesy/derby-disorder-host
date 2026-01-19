import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/theme.dart';

/// Displays the player leaderboard with balances and bets
class PlayerLeaderboard extends StatelessWidget {
  final List<Player> players;
  final Map<String, Bet> bets;
  final List<Participant> participants;
  final bool expandToFill; // When true, expands to fill available height (for racing view)

  const PlayerLeaderboard({
    super.key,
    required this.players,
    required this.bets,
    required this.participants,
    this.expandToFill = false,
  });

  String _getBetText(String playerId) {
    final bet = bets[playerId];
    if (bet == null) return 'No bet';

    final participant = participants.firstWhere(
      (p) => p.id == bet.participantId,
      orElse: () => participants.first,
    );
    
    return '${bet.betType.value.toLowerCase()} on ${participant.name}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      decoration: AppTheme.neonBox(
        color: AppTheme.neonCyan,
        borderRadius: 12,
      ),
      child: Column(
        mainAxisSize: expandToFill ? MainAxisSize.max : MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.neonCyan, width: 1),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.people, color: AppTheme.neonCyan, size: 20),
                const SizedBox(width: 8),
                Text(
                  'PLAYERS',
                  style: AppTheme.neonText(
                    color: AppTheme.neonCyan,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Player list
          if (players.isEmpty)
            expandToFill
              ? const Expanded(
                  child: Center(
                    child: Text(
                      'Waiting for players...',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                )
              : const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Waiting for players...',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                )
          else
            expandToFill
              ? Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: players.length,
                    itemBuilder: (context, index) => _buildPlayerTile(index),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: players.length,
                  itemBuilder: (context, index) => _buildPlayerTile(index),
                ),
        ],
      ),
    );
  }

  Widget _buildPlayerTile(int index) {
    final player = players[index];
    final betText = _getBetText(player.id);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.neonPink.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '#${index + 1}',
              style: const TextStyle(
                color: AppTheme.neonPink,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name and bet
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      player.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (player.isBroke)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.neonRed.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'BROKE',
                          style: TextStyle(
                            color: AppTheme.neonRed,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  betText,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Balance
          Text(
            '\$${player.balance}',
            style: const TextStyle(
              color: AppTheme.neonGreen,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
