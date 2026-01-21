import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/theme.dart';

/// Displays live race standings
/// Responsive design that adapts to screen size
class RaceLeaderboard extends StatelessWidget {
  final List<Participant> participants;
  final Map<String, double> positions;
  final List<String> finishOrder;
  final bool expandToFill;
  final bool compact; // Use compact mode for racing view

  const RaceLeaderboard({
    super.key,
    required this.participants,
    required this.positions,
    this.finishOrder = const [],
    this.expandToFill = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive width: 15% of screen width, min 180, max 280
    final panelWidth = compact 
        ? (screenWidth * 0.14).clamp(160.0, 240.0)
        : (screenWidth * 0.18).clamp(200.0, 350.0);
    
    final fontSize = compact ? 11.0 : 14.0;
    final headerFontSize = compact ? 12.0 : 16.0;
    final iconSize = compact ? 14.0 : 20.0;
    final emojiSize = compact ? 16.0 : 20.0;
    final padding = compact ? 6.0 : 12.0;
    final tilePadding = compact ? 4.0 : 8.0;

    // Sort participants: finished participants by finish order, others by position
    final sortedParticipants = [...participants];
    sortedParticipants.sort((a, b) {
      final posA = positions[a.id] ?? 0.0;
      final posB = positions[b.id] ?? 0.0;
      final aFinished = finishOrder.contains(a.id);
      final bFinished = finishOrder.contains(b.id);
      
      if (aFinished && bFinished) {
        return finishOrder.indexOf(a.id).compareTo(finishOrder.indexOf(b.id));
      }
      if (aFinished && !bFinished) return -1;
      if (!aFinished && bFinished) return 1;
      return posB.compareTo(posA);
    });

    return Container(
      width: panelWidth,
      decoration: AppTheme.neonBox(
        color: AppTheme.neonYellow,
        borderRadius: compact ? 8 : 12,
      ),
      child: Column(
        mainAxisSize: expandToFill ? MainAxisSize.max : MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(padding),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.neonYellow, width: 1),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.leaderboard, color: AppTheme.neonYellow, size: iconSize),
                SizedBox(width: compact ? 4 : 8),
                Expanded(
                  child: Text(
                    compact ? 'RACE' : 'STANDINGS',
                    style: AppTheme.neonText(
                      color: AppTheme.neonYellow,
                      fontSize: headerFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Standings list
          expandToFill
            ? Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: tilePadding / 2),
                  itemCount: sortedParticipants.length,
                  itemBuilder: (context, index) => 
                    _buildStandingTile(sortedParticipants[index], index, fontSize, emojiSize, tilePadding),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: tilePadding / 2),
                itemCount: sortedParticipants.length,
                itemBuilder: (context, index) => 
                  _buildStandingTile(sortedParticipants[index], index, fontSize, emojiSize, tilePadding),
              ),
        ],
      ),
    );
  }

  Widget _buildStandingTile(Participant participant, int index, double fontSize, double emojiSize, double tilePadding) {
    final position = positions[participant.id] ?? 0.0;
    final hasFinished = finishOrder.contains(participant.id);

    // Medal for top 3
    String rankDisplay;
    if (index == 0) {
      rankDisplay = '🥇';
    } else if (index == 1) {
      rankDisplay = '🥈';
    } else if (index == 2) {
      rankDisplay = '🥉';
    } else {
      rankDisplay = '#${index + 1}';
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: tilePadding,
        vertical: tilePadding / 2,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: tilePadding * 1.5,
        vertical: tilePadding,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(compact ? 4 : 8),
        border: index == 0
            ? Border.all(color: AppTheme.neonYellow.withOpacity(0.5))
            : null,
      ),
      child: Row(
        children: [
          // Rank/Medal
          SizedBox(
            width: compact ? 20 : 28,
            child: Text(
              rankDisplay,
              style: TextStyle(
                fontSize: index < 3 ? emojiSize - 2 : fontSize - 2,
                color: _getRankColor(index),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: compact ? 4 : 8),
          // Emoji
          Text(
            participant.icon,
            style: TextStyle(fontSize: emojiSize),
          ),
          SizedBox(width: compact ? 4 : 8),
          // Name
          Expanded(
            child: Text(
              participant.name,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Position / Finished indicator
          if (hasFinished)
            Text(
              '✓',
              style: TextStyle(
                color: AppTheme.neonGreen,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            Text(
              '${position.toStringAsFixed(0)}%',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: fontSize - 2,
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
