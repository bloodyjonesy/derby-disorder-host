import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/theme.dart';

/// Displays the player leaderboard with balances and bets
/// Responsive design that adapts to screen size
class PlayerLeaderboard extends StatelessWidget {
  final List<Player> players;
  final Map<String, Bet> bets;
  final List<Participant> participants;
  final bool expandToFill;
  final bool compact; // Use compact mode for racing view

  const PlayerLeaderboard({
    super.key,
    required this.players,
    required this.bets,
    required this.participants,
    this.expandToFill = false,
    this.compact = false,
  });

  String _getBetText(String playerId) {
    final bet = bets[playerId];
    if (bet == null) return 'No bet';

    final participant = participants.firstWhere(
      (p) => p.id == bet.participantId,
      orElse: () => participants.first,
    );
    
    // Compact version shows less text
    if (compact) {
      return '${participant.icon} \$${bet.amount}';
    }
    return '\$${bet.amount} ${bet.betType.value.toLowerCase()} on ${participant.name}';
  }

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
    final padding = compact ? 6.0 : 12.0;
    final tilePadding = compact ? 4.0 : 8.0;

    return Container(
      width: panelWidth,
      decoration: AppTheme.neonBox(
        color: AppTheme.neonCyan,
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
                bottom: BorderSide(color: AppTheme.neonCyan, width: 1),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.people, color: AppTheme.neonCyan, size: iconSize),
                SizedBox(width: compact ? 4 : 8),
                Text(
                  'PLAYERS',
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
                      'Waiting...',
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
                    itemBuilder: (context, index) => _buildPlayerTile(index, fontSize, tilePadding),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(vertical: tilePadding / 2),
                  itemCount: players.length,
                  itemBuilder: (context, index) => _buildPlayerTile(index, fontSize, tilePadding),
                ),
        ],
      ),
    );
  }

  Widget _buildPlayerTile(int index, double fontSize, double tilePadding) {
    final player = players[index];
    final betText = _getBetText(player.id);

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
      ),
      child: Row(
        children: [
          // Rank - smaller in compact mode
          if (!compact)
            Container(
              width: 24,
              height: 24,
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
          if (!compact) const SizedBox(width: 8),
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
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          '👁',
                          style: TextStyle(fontSize: fontSize),
                        ),
                      )
                    else if (player.isBroke)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          '💸',
                          style: TextStyle(fontSize: fontSize),
                        ),
                      ),
                  ],
                ),
                if (!compact) ...[
                  const SizedBox(height: 2),
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
