import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/theme.dart';

/// Displays the player leaderboard with balances and bets
/// Fully reactive design that adapts to any screen size
class PlayerLeaderboard extends StatelessWidget {
  final List<Player> players;
  final Map<String, Bet> bets;
  final List<Participant> participants;
  final bool expandToFill;

  const PlayerLeaderboard({
    super.key,
    required this.players,
    required this.bets,
    required this.participants,
    this.expandToFill = false,
  });

  String _getBetText(String playerId, bool isCompact) {
    final bet = bets[playerId];
    if (bet == null) return isCompact ? '—' : 'No bet';

    final participant = participants.firstWhere(
      (p) => p.id == bet.participantId,
      orElse: () => participants.first,
    );
    
    if (isCompact) {
      return '${participant.icon} \$${bet.amount}';
    }
    return '\$${bet.amount} ${bet.betType.value.toLowerCase()} on ${participant.name}';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Reactive sizing based on available width
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;
        
        // Determine if we should use compact mode based on available space
        final isCompact = availableWidth < 280 || availableHeight < 500;
        final isVeryCompact = availableWidth < 200;
        
        // Scale font sizes based on available width
        final scaleFactor = (availableWidth / 250).clamp(0.7, 1.2);
        final fontSize = (isCompact ? 11.0 : 14.0) * scaleFactor;
        final headerFontSize = (isCompact ? 12.0 : 16.0) * scaleFactor;
        final iconSize = (isCompact ? 14.0 : 20.0) * scaleFactor;
        final padding = (isCompact ? 6.0 : 12.0) * scaleFactor;
        final tilePadding = (isCompact ? 4.0 : 8.0) * scaleFactor;

        return Container(
          decoration: AppTheme.neonBox(
            color: AppTheme.neonCyan,
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
                    bottom: BorderSide(color: AppTheme.neonCyan, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.people, color: AppTheme.neonCyan, size: iconSize),
                    SizedBox(width: isCompact ? 4 : 8),
                    if (!isVeryCompact)
                      Text(
                        isCompact ? 'PLAYERS' : 'PLAYERS',
                        style: AppTheme.neonText(
                          color: AppTheme.neonCyan,
                          fontSize: headerFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              // Player list
              if (players.isEmpty)
                expandToFill
                  ? Expanded(
                      child: Center(
                        child: Text(
                          isCompact ? '...' : 'Waiting...',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: fontSize,
                          ),
                        ),
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.all(padding),
                      child: Text(
                        'Waiting for players...',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: fontSize,
                        ),
                      ),
                    )
              else
                expandToFill
                  ? Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: tilePadding / 2),
                        itemCount: players.length,
                        itemBuilder: (context, index) => _buildPlayerTile(
                          index, fontSize, tilePadding, isCompact, isVeryCompact, scaleFactor,
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(vertical: tilePadding / 2),
                      itemCount: players.length,
                      itemBuilder: (context, index) => _buildPlayerTile(
                        index, fontSize, tilePadding, isCompact, isVeryCompact, scaleFactor,
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlayerTile(
    int index, 
    double fontSize, 
    double tilePadding, 
    bool isCompact,
    bool isVeryCompact,
    double scaleFactor,
  ) {
    final player = players[index];
    final betText = _getBetText(player.id, isCompact);

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
      ),
      child: Row(
        children: [
          // Rank - hide in very compact mode
          if (!isVeryCompact) ...[
            Container(
              width: 22 * scaleFactor,
              height: 22 * scaleFactor,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.neonPink.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '#${index + 1}',
                style: TextStyle(
                  color: AppTheme.neonPink,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize - 2,
                ),
              ),
            ),
            SizedBox(width: 6 * scaleFactor),
          ],
          // Name and bet
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        player.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (player.isViewer)
                      Text('👁', style: TextStyle(fontSize: fontSize))
                    else if (player.isBroke)
                      Text('💸', style: TextStyle(fontSize: fontSize)),
                  ],
                ),
                if (!isVeryCompact) ...[
                  SizedBox(height: 2 * scaleFactor),
                  Text(
                    betText,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: fontSize - 2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          // Balance
          SizedBox(width: 4 * scaleFactor),
          Text(
            '\$${player.balance}',
            style: TextStyle(
              color: AppTheme.neonGreen,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
