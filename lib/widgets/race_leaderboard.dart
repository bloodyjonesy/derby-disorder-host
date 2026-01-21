import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/theme.dart';
import '../utils/responsive.dart';

/// Displays live race standings
/// Fully reactive design that adapts to any screen size
class RaceLeaderboard extends StatelessWidget {
  final List<Participant> participants;
  final Map<String, double> positions;
  final List<String> finishOrder;
  final bool expandToFill;

  const RaceLeaderboard({
    super.key,
    required this.participants,
    required this.positions,
    this.finishOrder = const [],
    this.expandToFill = true,
  });

  @override
  Widget build(BuildContext context) {
    // Get global scale factor for screen size
    final globalScale = Responsive.scale(context);
    
    // Sort participants: finished by finish order, others by position
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

    return LayoutBuilder(
      builder: (context, constraints) {
        // Reactive sizing based on available space
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;
        
        // Determine compact mode based on available space AND global scale
        final isCompact = availableWidth < 280 * globalScale || availableHeight < 500 * globalScale;
        final isVeryCompact = availableWidth < 200 * globalScale;
        
        // Scale factor based on available width AND global scale
        final localScale = (availableWidth / (250 * globalScale)).clamp(0.7, 1.2);
        final scaleFactor = localScale * globalScale;
        final fontSize = (isCompact ? 11.0 : 14.0) * scaleFactor;
        final headerFontSize = (isCompact ? 12.0 : 16.0) * scaleFactor;
        final iconSize = (isCompact ? 14.0 : 20.0) * scaleFactor;
        final emojiSize = (isCompact ? 16.0 : 20.0) * scaleFactor;
        final padding = (isCompact ? 6.0 : 12.0) * scaleFactor;
        final tilePadding = (isCompact ? 4.0 : 8.0) * scaleFactor;

        return Container(
          decoration: AppTheme.neonBox(
            color: AppTheme.neonYellow,
            borderRadius: isCompact ? 8 : 12,
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
                    SizedBox(width: isCompact ? 4 : 8),
                    if (!isVeryCompact)
                      Expanded(
                        child: Text(
                          isCompact ? 'RACE' : 'STANDINGS',
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
                      itemBuilder: (context, index) => _buildStandingTile(
                        sortedParticipants[index], 
                        index, 
                        fontSize, 
                        emojiSize, 
                        tilePadding,
                        isCompact,
                        isVeryCompact,
                        scaleFactor,
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(vertical: tilePadding / 2),
                    itemCount: sortedParticipants.length,
                    itemBuilder: (context, index) => _buildStandingTile(
                      sortedParticipants[index], 
                      index, 
                      fontSize, 
                      emojiSize, 
                      tilePadding,
                      isCompact,
                      isVeryCompact,
                      scaleFactor,
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStandingTile(
    Participant participant, 
    int index, 
    double fontSize, 
    double emojiSize, 
    double tilePadding,
    bool isCompact,
    bool isVeryCompact,
    double scaleFactor,
  ) {
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
        borderRadius: BorderRadius.circular(isCompact ? 4 : 8),
        border: index == 0
            ? Border.all(color: AppTheme.neonYellow.withOpacity(0.5))
            : null,
      ),
      child: Row(
        children: [
          // Rank/Medal
          SizedBox(
            width: 20 * scaleFactor,
            child: Text(
              rankDisplay,
              style: TextStyle(
                fontSize: index < 3 ? emojiSize - 4 : fontSize - 2,
                color: _getRankColor(index),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 4 * scaleFactor),
          // Emoji
          Text(
            participant.icon,
            style: TextStyle(fontSize: emojiSize),
          ),
          SizedBox(width: 4 * scaleFactor),
          // Name - hide in very compact mode
          if (!isVeryCompact)
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
            )
          else
            const Spacer(),
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
