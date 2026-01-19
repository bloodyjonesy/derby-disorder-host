import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/theme.dart';

/// Displays active side bets between players
class SideBetsDisplay extends StatelessWidget {
  final List<SideBet> sideBets;
  final List<Player> players;
  final List<Participant> participants;
  final bool showResults;

  const SideBetsDisplay({
    super.key,
    required this.sideBets,
    required this.players,
    required this.participants,
    this.showResults = false,
  });

  String _getPlayerName(String id) {
    try {
      return players.firstWhere((p) => p.id == id).name;
    } catch (_) {
      return 'Unknown';
    }
  }

  Participant? _getParticipant(String id) {
    try {
      return participants.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (sideBets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: AppTheme.neonBox(
        color: AppTheme.neonCyan,
        borderRadius: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.neonCyan.withOpacity(0.2),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Text('🎲', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  'SIDE BETS',
                  style: AppTheme.neonText(
                    color: AppTheme.neonCyan,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${sideBets.length} active',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bets list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sideBets.length,
            itemBuilder: (context, index) {
              final bet = sideBets[index];
              return _buildSideBetCard(bet);
            },
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSideBetCard(SideBet bet) {
    final challengerName = _getPlayerName(bet.challengerId);
    final targetName = _getPlayerName(bet.targetId);
    final challengerPick = _getParticipant(bet.challengerPickId);
    final targetPick = _getParticipant(bet.targetPickId);

    final bool? won = bet.challengerWon;
    final hasResult = showResults && won != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasResult
            ? (won! ? AppTheme.neonGreen.withOpacity(0.1) : Colors.red.withOpacity(0.1))
            : Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: hasResult
            ? Border.all(
                color: won! ? AppTheme.neonGreen.withOpacity(0.5) : Colors.red.withOpacity(0.5),
              )
            : null,
      ),
      child: Column(
        children: [
          // Players row
          Row(
            children: [
              // Challenger
              Expanded(
                child: Column(
                  children: [
                    Text(
                      challengerName,
                      style: TextStyle(
                        color: hasResult && won!
                            ? AppTheme.neonGreen
                            : (hasResult && !won ? Colors.red : AppTheme.neonCyan),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (challengerPick != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(challengerPick.icon, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text(
                            challengerPick.name,
                            style: TextStyle(
                              color: Color(int.parse(challengerPick.color.replaceFirst('#', '0xFF'))),
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                    if (hasResult && won!) ...[
                      const SizedBox(height: 4),
                      const Text('👑 WINNER', style: TextStyle(fontSize: 10, color: AppTheme.neonGreen)),
                    ],
                  ],
                ),
              ),

              // VS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    const Text(
                      'VS',
                      style: TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '🍺',
                      style: TextStyle(fontSize: hasResult ? 20 : 16),
                    ),
                  ],
                ),
              ),

              // Target
              Expanded(
                child: Column(
                  children: [
                    Text(
                      targetName,
                      style: TextStyle(
                        color: hasResult && !won!
                            ? AppTheme.neonGreen
                            : (hasResult && won ? Colors.red : AppTheme.neonPink),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (targetPick != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(targetPick.icon, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text(
                            targetPick.name,
                            style: TextStyle(
                              color: Color(int.parse(targetPick.color.replaceFirst('#', '0xFF'))),
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                    if (hasResult && !won!) ...[
                      const SizedBox(height: 4),
                      const Text('👑 WINNER', style: TextStyle(fontSize: 10, color: AppTheme.neonGreen)),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // Stakes
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.neonYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Stakes: ${bet.stakes}',
              style: const TextStyle(
                color: AppTheme.neonYellow,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Result
          if (hasResult) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                won!
                    ? '$targetName must ${bet.stakes}!'
                    : '$challengerName must ${bet.stakes}!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Compact side bet indicator
class SideBetBadge extends StatelessWidget {
  final int count;

  const SideBetBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.neonCyan.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neonCyan.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎲', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            '$count side bet${count > 1 ? 's' : ''}',
            style: const TextStyle(
              color: AppTheme.neonCyan,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
