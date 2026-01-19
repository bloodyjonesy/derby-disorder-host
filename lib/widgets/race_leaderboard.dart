import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/theme.dart';

/// Displays live race standings
class RaceLeaderboard extends StatelessWidget {
  final List<Participant> participants;
  final Map<String, double> positions;
  final bool expandToFill; // When true, expands to fill available height

  const RaceLeaderboard({
    super.key,
    required this.participants,
    required this.positions,
    this.expandToFill = true, // Default to true since mainly used in racing view
  });

  @override
  Widget build(BuildContext context) {
    // Sort participants by position
    final sortedParticipants = [...participants];
    sortedParticipants.sort((a, b) {
      final posA = positions[a.id] ?? 0.0;
      final posB = positions[b.id] ?? 0.0;
      return posB.compareTo(posA); // Descending order
    });

    return Container(
      width: 350,
      decoration: AppTheme.neonBox(
        color: AppTheme.neonYellow,
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
                bottom: BorderSide(color: AppTheme.neonYellow, width: 1),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.leaderboard, color: AppTheme.neonYellow, size: 20),
                const SizedBox(width: 8),
                Text(
                  'LIVE STANDINGS',
                  style: AppTheme.neonText(
                    color: AppTheme.neonYellow,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Standings list
          expandToFill
            ? Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: sortedParticipants.length,
                  itemBuilder: (context, index) => _buildStandingTile(sortedParticipants[index], index),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: sortedParticipants.length,
                itemBuilder: (context, index) => _buildStandingTile(sortedParticipants[index], index),
              ),
        ],
      ),
    );
  }

  Widget _buildStandingTile(Participant participant, int index) {
    final position = positions[participant.id] ?? 0.0;

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
        border: index == 0
            ? Border.all(color: AppTheme.neonYellow.withOpacity(0.5))
            : null,
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _getRankColor(index).withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '#${index + 1}',
              style: TextStyle(
                color: _getRankColor(index),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Emoji
          Text(
            participant.icon,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          // Name
          Expanded(
            child: Text(
              participant.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Position
          Text(
            '${position.toStringAsFixed(1)}m',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return AppTheme.neonYellow;
      case 1:
        return AppTheme.neonCyan;
      case 2:
        return AppTheme.neonOrange;
      default:
        return AppTheme.textSecondary;
    }
  }
}
