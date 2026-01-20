import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/theme.dart';

/// Displays tournament standings during/after a tournament
class TournamentStandings extends StatelessWidget {
  final TournamentState tournament;
  final bool showChampion;

  const TournamentStandings({
    super.key,
    required this.tournament,
    this.showChampion = false,
  });

  @override
  Widget build(BuildContext context) {
    final sortedStandings = List<TournamentStanding>.from(tournament.standings)
      ..sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

    return Container(
      constraints: const BoxConstraints(maxWidth: 500, maxHeight: 400),
      decoration: AppTheme.neonBox(
        color: AppTheme.neonPurple,
        borderRadius: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.neonPurple, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🏆', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(
                  showChampion && tournament.championId != null
                      ? 'TOURNAMENT CHAMPION!'
                      : 'TOURNAMENT STANDINGS',
                  style: AppTheme.neonText(
                    color: AppTheme.neonPurple,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('🏆', style: TextStyle(fontSize: 24)),
              ],
            ),
          ),
          
          // Race progress
          if (!showChampion)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Race ${tournament.currentRace} of ${tournament.totalRaces}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),

          // Standings list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: sortedStandings.length,
              itemBuilder: (context, index) {
                final standing = sortedStandings[index];
                final isChampion = standing.playerId == tournament.championId;
                
                return _buildStandingRow(standing, index + 1, isChampion);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandingRow(TournamentStanding standing, int rank, bool isChampion) {
    Color rankColor;
    String medal;
    
    switch (rank) {
      case 1:
        rankColor = AppTheme.neonYellow;
        medal = '🥇';
        break;
      case 2:
        rankColor = Colors.grey[300]!;
        medal = '🥈';
        break;
      case 3:
        rankColor = AppTheme.neonOrange;
        medal = '🥉';
        break;
      default:
        rankColor = AppTheme.textSecondary;
        medal = '$rank';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isChampion 
            ? AppTheme.neonYellow.withOpacity(0.15)
            : AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: isChampion 
            ? Border.all(color: AppTheme.neonYellow, width: 2)
            : null,
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 40,
            child: Text(
              medal,
              style: TextStyle(
                fontSize: rank <= 3 ? 24 : 16,
                color: rankColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Player name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      standing.playerName,
                      style: TextStyle(
                        color: isChampion ? AppTheme.neonYellow : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (isChampion) ...[
                      const SizedBox(width: 8),
                      const Text('👑', style: TextStyle(fontSize: 16)),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${standing.raceWins} win${standing.raceWins == 1 ? '' : 's'} • \$${standing.totalEarnings} earned',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Points
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${standing.totalPoints} pts',
              style: TextStyle(
                color: rankColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
